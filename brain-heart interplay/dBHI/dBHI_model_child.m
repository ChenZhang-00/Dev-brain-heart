function [HeartToBrain, BrainToLF, BrainToHF, HeartToBrain_sigma, HeartToBrain_mc]...
    = dBHI_model_child(TFR_EEG, TFR_HRV, FS, RR, win_RR, window)
% This function quantifies the children's directional Brain-Heart Interplay (BHI) 
% through the model proposed by Catrambone et al.(2019) [1].

% INPUT variables:
% TFR_EEG = Time course of EEG power spectral density (PSD). This must be a matrix (Dimension: Channels X time)
%           samples. Each series in each row should be filtered in the desired frequency band of
%           interest (psi)
% TFR_HRV = Time course of HRV PSD (Dimension: 1 X time). This should be filtered in the
% desired frequency band of interest (phi: e.g., LF or HF band)
% FS      = Sampling Frequency of the two TFRs
% RR      = HRV series (expressed in seconds)
% win_RR  = windows length (expressed in seconds) in which the heartbeat generation model (IPFM) is
% reconstructed (default = 15s)
% window  = windows length (in seconds) in which the parameters are
% calculated (default: window*FS >= 15 )

% OUTPUT variables:
% - HeartToBrain = Functional coupling index (c_rrTOeeg(T)) from 
% HRV Phi-band to EEG Psi-band
% - BrainToHF, BrainToLF  = Functional coupling indices from  
%  EEG Psi-band to  HRV-LF or  HRV-HF bands
% - HeartToBrain_sigma, HeartToBrain_mc = model parameters to be used for fitting evaluation [1]
% 
% This software assumes that input series 
% are all artifact free, e.g., heartbeat dynamics free of algotirhmic and/or physiological artifacts; e.g.
% EEG series free of artifacts from eye blink, movement, etc.
% ---------------------------------------------------------------------------------------------
%  This code implements the theoretical dissertation published in:
%  [1] Catrambone Vincenzo, Alberto Greco, Nicola Vanello, Enzo Pasquale Scilingo,
%  and Gaetano Valenza. "Time-Resolved Directional Brain-Heart Interplay Measurement 
%  Through Synthetic Data Generation Models." 
%  Annals of biomedical engineering 47, no. 6 (2019): 1479-1489.
% ---------------------------------------------------------------------------------------------
% Copyright (C) 2019 Vincenzo Catrambone, Gaetano Valenza
% 
% This program is a free software; you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free Software
% Foundation; either version 3 of the License, or (at your option) any later
% version.
% ---------------------------------------------------------------------------------------------

%% checking input variables
if nargin<5
    disp('Three arguments are needed at least: the PSD time course of EEG and HRV signal; and the HRV time series');
    return
elseif nargin >= 5 && nargin < 6
    switch nargin
        case 5
            win_RR = 15; window = ceil(15/FS);
        case 6
            window = ceil(15/FS);
    end 
elseif nargin > 6
    disp('Too many input arguments');
    return
end

[r,c] = size(TFR_HRV);
if (c==1)&&(r~=1)
    TFR_HRV = TFR_HRV';
elseif ((r~=1)&&(c~=1))||(length(size(TFR_HRV))>2)
    error('Time course of HRV PSD must be a row vector: 1 X time points')
end

if length(size(TFR_EEG))>2
    error('Time course of EEG PSD must be a 2D matrix: Channels X time points')
end
[Nch,Nt] = size(TFR_EEG);
if (Nt==1)&&(Nch~=1)
    TFR_EEG = TFR_EEG';
    [Nch,Nt] = size(TFR_EEG);
end

if (c~=Nt)
    error('The two PSDs, i.e. of EEG and HRV, must be homologously sampled and related to the same time vector, so they must have the same length.');
end

if (log10(abs(median(RR)))<-1)||(log10(abs(median(RR)))>0.7)
    error('HRV signal measure unit must be in seconds!')
end

wind = window*FS; % FS is 1Hz here and wondow is 15s
if wind < 15
    window = ceil(15/FS);
    wind = window*FS;
    disp(['The time window used for BHI estimation has been modified to ' num2str(window)...
        'secs, as minimum window allowing robust results with the chosen sampling rate']);
end

%% RR model parameter estimation
omega_lf = 2*pi*0.13;               % LF central frequency
omega_hf = 2*pi*0.34;               % HF central Frequency
rr_cum = cumsum(RR);                % cumulative sum of IBI

index_old = 1;
index_new = find(rr_cum > 1 + win_RR,1)-1; % start from 1-s, end of 15-s window
CS = zeros(fix(rr_cum(end)-win_RR),1); % n of 15-s window
CP = CS;

for i = 1:fix(rr_cum(end)-win_RR) % sliding 15-window in the RR series
    HR = 1/mean(RR(index_old+1:index_new));                                % Time-varying Heart Rate in each sliding window
    gamma = sin(omega_hf/(2*HR))-sin(omega_lf/(2*HR));                     % gamma parameter of the IFPM model
    MM = [sin(omega_hf/(2*HR))*omega_lf*HR/(sin(omega_lf/(2*HR))*4)   -sqrt(2)*omega_lf*HR/(8*sin(omega_lf/(2*HR)));
        -sin(omega_lf/(2*HR))*omega_hf*HR/(sin(omega_hf/(2*HR))*4)    sqrt(2)*omega_hf*HR/(8*sin(omega_hf/(2*HR)))];
    % estimation of the Poincare plot indices
    L = max(RR(index_old:index_new))-min(RR(index_old:index_new));    % length of the Poincare plot  
    W = sqrt(2)*max(abs(RR(index_old+1:index_new)-RR(index_old:index_new-1))); % width of the Poincare plot
    CC = 1/gamma*MM*[L; W];
    CS(i) = CC(1);   CP(i) = CC(2);  % CS:sympathetic, CP:parasympathetic, time-varying coupling constants
    index_old = find(rr_cum > i,1); % next second
    index_new = find(rr_cum > i + win_RR,1)-1;
end

% normalization of the parameters for computational reasons and interpolation
CSr = CS'/std(CS);  CPr = CP'/std(CP);
CSr = interp1(1:length(CSr), CSr, 1/FS:1/FS:Nt/FS, 'spline'); % interpolate the position of window edge
CPr = interp1(1:length(CPr), CPr, 1/FS:1/FS:Nt/FS, 'spline');
TFR_EEG = (sqrt(TFR_EEG));

%% model running for each EEG channel
if Nch > 1
    parfor ch = 1:Nch % parallel running for each channel
        [HeartToBrain(ch,:), BrainToLF(ch,:), BrainToHF(ch,:),HeartToBrain_sigma(ch,:),HeartToBrain_mc(ch,:)] = ...
            BHI_InsideModel2(TFR_EEG(ch,:), TFR_HRV, CPr, CSr, wind);
    end
else
    [HeartToBrain, BrainToLF, BrainToHF, HeartToBrain_sigma,HeartToBrain_mc] = ...
        BHI_InsideModel2(TFR_EEG, TFR_HRV, CPr, CSr, wind);
end

end

function [HToB, BToLF, BToHF, HToB_sigma, HToB_mc] = BHI_InsideModel2(TFR_ch, TFR_rr, CPr, CSr, window)

Nt = length(TFR_ch); % time in seconds of the signal
Cs1 = 0.25; Cp1 = 0.24; 

for i = 1:window
%% EEG parameter estimation, during the first period in which the RR model connot be calculated
% System Identification Toolbox is needed to use iddata
%  DAT = IDDATA(Y,U,Ts) to create a data object with output Y and input U and sample time Ts. Default Ts = 1.
arx_data = iddata(TFR_ch(i:i+window)', TFR_rr(i:i+window)', 1);                     % iddata-format is necessary for the arx function
model_eegP = arx(arx_data,[1 1 1]);                                                 % here the model is estimated
HToB_sigma(i) = sqrt(model_eegP.NoiseVariance); HToB_mc(i) = -model_eegP.A(2);      % the parameters are extracted
HToB(i) = model_eegP.B(2);
medianTime_P_eeg(1,i) = median(TFR_ch(i:i+window));                                 % this operation is needed for the following RR-model
end

%% after a first period (equal to the window length), both the inverse models are running, so the parameters are parallelly calculated 
for i = window+1:min([length(CPr),Nt-window, length(TFR_rr)-window])
    
    %% ARX EEG parameter estimation
    arx_data = iddata(TFR_ch(i:i+window)', TFR_rr(i:i+window)',1); 
    model_eegP = arx(arx_data,[1 1 1]);
    HToB_sigma(i) = sqrt(model_eegP.NoiseVariance); HToB_mc(i) = -model_eegP.A(2);
    HToB(i) = model_eegP.B(2);
    medianTime_P_eeg(1,i) = median(TFR_ch(i:i+window)); % use mean

    %% IPFM RR parameter estimation, the interaction are modelled separately with all the EEG bands
    % RR model start from window+1s, 16s here
    if i-window <= length(CPr)-window-1
        % Brain to HF
        BToHF(i-window) = median((CPr(i-window:i)-Cp1)./medianTime_P_eeg(i-window:i));
        % Brain to LF
        BToLF(i-window) = median((CSr(i-window:i)-Cs1)./medianTime_P_eeg(i-window:i));
    else
        % Brain to HF
        BToHF(i-window) = BToHF(i-window-1);
        % Brain to LF
        BToLF(i-window) = BToLF(i-window-1);
    end
end

end