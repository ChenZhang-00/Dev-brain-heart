function [] = ecg_pre(id,age)
% This function preprocesses ECG data and extracts ECG features.
%
% The preprocessing steps include:
% - Baseline removal
% - Frequency filtering
% - Isoline correction
%
% After preprocessing, the annotation process detects the P wave, T wave, and QRS complex.
%
% Output:
% - Preprocessed ECG data
% - Annotations for R and T waves
%
% Required toolbox:
% - ECGdeli-master (developed by Nicolas Pilia, Claudia Nagel, and colleagues, 
%   Institute of Biomedical Engineering, Karlsruhe Institute of Technology)
%
addpath(genpath("\toolbox\ECGdeli-master"));

participantnumber  = id; % eg., 230723030
age = age; % eg., 85
replacearg = 1;

%% define the folders/paths
folderBase          = '/';
programs            = fullfile(folderBase,'brain-heart interplay',filesep);
datapath            = fullfile(folderBase,'sample_data/raw_eeg',filesep);
outputfolder        = fullfile(programs,'ecg_processed',filesep);
addpath(programs);

%% check if the final output already exists
ecg_outputfile = ['movie ' num2str(participantnumber) ' ecg_fpt.mat'];
if exist([outputfolder ecg_outputfile]) && replacearg == 0
    disp([ecg_outputfile ' already exists! change replacearg to 1 if needs to replace it.']);
    return
end

%% 1) extract the ecg raw data from the eeg file
eeglab;close 
EEG = pop_loadbv([datapath num2str(participantnumber)], ['/' num2str(participantnumber) '_movie.vhdr'], [], []);
ECG = pop_select(EEG,'channel',64);
Fs = 500; % sampling rate

ecg     = [];
ecg(:,1) = ECG.data;
ecg(:,2) = ECG.times./1000; 
ecg_raw = ['movie ' num2str(id) ' ecg_raw.mat']; 
save([outputfolder ecg_raw],'ecg');

%% 2) preprocess of the ecg data
% 1. Remove baseline wander
[ecg_filtered_baseline,~] = ECG_Baseline_Removal(ecg,Fs,1,0.5);

% 2. filter noise frequencies
% frequencies are already optimized for ECG signals (literature values):
% Lowpass: 120 Hz, Highpass: 0.3 Hz, Bandstop (49-51 Hz)
% filter settings to be modified
highpass = 1;
lowpass  = 50;
ecg_filtered_frq = ECG_High_Low_Filter(ecg_filtered_baseline,Fs,highpass,lowpass);
ecg_filtered_frq = Notch_Filter(ecg_filtered_frq,Fs,50,1); % 50hz line noise

% 3. isoline correction
% usage: [filteredsignal,offset,frequency_matrix,bins_matrix]=Isoline_Correction(signal,varargin)
[ecg_filtered_isoline,offset,~,~] = Isoline_Correction(ecg_filtered_frq);

%% Feature calculation
% produce FPT Table
% Structure of the FPT (see Pilia et al.,2021, SoftwareX for more details). Lines in the FPT represent the number of the detected beat. Column 9 is reserved (res.) for
% the J point, column 13 for a beat classification.
% Column     1    2      3     4      5  6  7  8       9    10   11     12    13
% Beatnumber P_on P_peak P_off QRS_on Q  R  S  QRS_off res. T_on T_peak T_off res.

[FPT_MultiChannel_QRS,FPT_Cell_QRS] = Annotate_ECG_Multi(ecg_filtered_isoline,Fs,'all');
highpass = 0.1;
lowpass  = 25;
ecg_filtered_isoline_T     = ECG_High_Low_Filter(ecg_filtered_isoline,Fs,highpass,lowpass);
FPT_MultiChannel_T         = FPT_MultiChannel_QRS;

%% output data
ecg_fpt = [];
ecg_fpt.Fs         = Fs;
ecg_fpt.raw        = ecg;
ecg_fpt.processed  = single(ecg_filtered_isoline);
ecg_fpt.processedT = single(ecg_filtered_isoline_T);
ecg_fpt.Rs         = single(FPT_MultiChannel_QRS(:,6));
ecg_fpt.Ts         = single(FPT_MultiChannel_T(:,11));

save([outputfolder ecg_outputfile],'ecg_fpt');

return



