function [] = movie_HEP(id,age)
%% This function preprocesses EEG data and segments epochs.
% It segments EEG data based on the T-wave onset of simultaneously recorded ECG.
% Epochs are extracted within the time window [-0.2, 0.6] seconds around the T wave onset.

participantnumber  = id;
age = age;
icapruning        = 1;
replacearg        = 1;
epochlength       = 0.6; % in s

%% define the folders/paths
folderBase          = '';
programs            = fullfile(folderBase,'brain-heart interplay/HEP',filesep);
datapath            = fullfile(folderBase,'sample_data/raw_eeg',filesep);
outputfolder        = fullfile(programs,'HEP_Seg',filesep);
erplist             = fullfile(programs,'HEP_list',filesep);
ecgpath             = fullfile(folderBase,'brain-heart interplay/ecg_processed',filesep);
addpath(programs);

Finaldataset = ['movie ' num2str(participantnumber) ' HEP_seg.set'];
if exist([outputfolder Finaldataset]) & replacearg == 0;
    disp([Finaldataset ' already exists! change replacearg to 1 if needs to replace it.']);
    return
end

%% 1) read the raw .vhdr file
% Load in the EEG data;
eeglab;close %run 'eeglab' to load all default paths and functions when a new matlan is opened;
EEG = pop_loadbv([datapath num2str(participantnumber)], ['/' num2str(participantnumber) '_movie.vhdr'], [], []);

%% remove the ECG channel from EEG
EEG = pop_select( EEG,'nochannel',[64 65]); % 64 ECG 65 EDA

%% Data filtering with the continuous data of the EEG data
% 1) notch filtering with Zapline
EEG = pop_zapline_plus(EEG, 'noisefreqs','line','coarseFreqDetectPowerDiff',4,'chunkLength',0,'adaptiveNremove',1,'fixedNremove',1,'plotResults',0);

% 2）notch filtering with CleanLine
% This will run cleanline on all channels, scanning for lines +/- 1 Hz around the 50 and 100 Hz frequencies. 
% Each epoch will be cleaned individually and epochs containing lines that are significantly sinusoidal at 
% the p<=0.01 level will be cleaned. 
EEG = pop_cleanline(EEG, 'bandwidth',2,'chanlist',[1:EEG.nbchan] ,'computepower',1,'linefreqs',[50],'newversion',0,'normSpectrum',0,'p',0.01,'pad',2,'plotfigures',0,'scanforlines',1,'sigtype','Channels','taperbandwidth',2,'tau',100,'verb',1,'winsize',4,'winstep',1);

% 3) bandpass filter with the ERPLAB IIR butterworth filter
% for more information: https://github.com/lucklab/erplab/wiki/Filtering
EEG  = pop_basicfilter(EEG,  1:EEG.nbchan , 'Boundary', 'boundary', 'Cutoff', [0.5 30], 'Design', 'butter', 'Filter', 'bandpass', 'Order',  8 ); 

chanlocs = EEG.chanlocs;
nbchan   = EEG.nbchan;

%% create and import eventlist
%% 2) Eventlist; 
erplistname = [erplist 'movie ' num2str(participantnumber) ' HEPlist.txt'];
if exist(erplistname)
    delete(erplistname)
end

% load the ECG fiducial points (for Rs and Ts)
ecgfilename = ['movie ' num2str(participantnumber) ' ecg_fpt.mat']; 
load([ecgpath ecgfilename],'ecg_fpt');

% exclude outlier beats
Rs   = ecg_fpt.Rs;
Ts   = ecg_fpt.Ts;
IRIs = diff(ecg_fpt.Rs);
ITIs = diff(ecg_fpt.Ts);

outlIRIs         = IRIs>mean(IRIs)+2*std(IRIs);
IRIs(outlIRIs) = [];
ITIs(outlIRIs) = [];
Rs_out = zeros(size(Rs));
for i = 1:length(outlIRIs)
    if outlIRIs(i)
        Rs_out(i) = 1;
        if i < length(outlIRIs)
            Rs_out(i+1) = 1;
        end
    end
end
Rs(find(Rs_out)) = [];
Ts(find(Rs_out)) = [];
   
% R peaks in different emotions
for i = 1: length(EEG.event(:))
    eventmarker = EEG.event(i).type;
    switch eventmarker
        case 'boundary'
        case 'S  1'
            fear_onset = EEG.event(i).latency;
        case 'S  2'
            fear_end = EEG.event(i).latency;
        case 'S  3'
            neutral_onset = EEG.event(i).latency;
        case 'S  4'
            neutral_end = EEG.event(i).latency;
        case 'S  5'
            happy_onset = EEG.event(i).latency;
        case 'S  6'
            happy_end = EEG.event(i).latency;
    end
end
clear i

Fear_R_onset = find(Rs > fear_onset, 1,"first");
Fear_R_end = find(Rs < fear_end, 1, "last");
Fear_R = Rs(Fear_R_onset:Fear_R_end); Fear_T = Ts(Fear_R_onset:Fear_R_end);

Happy_R_onset = find(Rs > happy_onset, 1,"first");
Happy_R_end = find(Rs < happy_end, 1, "last");
Happy_R = Rs(Happy_R_onset:Happy_R_end); Happy_T = Ts(Happy_R_onset:Happy_R_end);

Neutral_R_onset = find(Rs > neutral_onset, 1,"first");
Neutral_R_end = find(Rs < neutral_end, 1, "last");
Neutral_R = Rs(Neutral_R_onset:Neutral_R_end);Neutral_T = Ts(Neutral_R_onset:Neutral_R_end);
Neutral_T = Ts(Neutral_R_onset:Neutral_R_end);Neutral_T = Ts(Neutral_R_onset:Neutral_R_end);

bepoch = 0; diff_=0; enable=1; dura = 0;
srate = EEG.srate;

load("/movie_emotion_editing/emo_epoch_rating.mat");
High_Fear_T = emo_epoch_rating.High_Fear.Time;
Low_Fear_T = emo_epoch_rating.Low_Fear.Time;
High_Happy_T = emo_epoch_rating.High_Happy.Time;
Low_Happy_T = emo_epoch_rating.Low_Happy.Time;

High_Fe_R = []; Low_Fe_R = [];
High_Ha_R = []; Low_Ha_R = [];
High_Fe_T = []; Low_Fe_T = [];
High_Ha_T = []; Low_Ha_T = [];
Fe_R = (Fear_R - fear_onset)./srate; % in seconds
Ha_R = (Happy_R -happy_onset) ./srate; % in seconds

for i = 1:length(High_Fear_T)
    H_Fear_R = Fear_R(Fe_R >= High_Fear_T(i) & Fe_R <= High_Fear_T(i)+1);
    H_Fear_T = Fear_T(Fe_R >= High_Fear_T(i) & Fe_R <= High_Fear_T(i)+1);
    High_Fe_R = [High_Fe_R; H_Fear_R]; 
    High_Fe_T = [High_Fe_T; H_Fear_T];
end

for i = 1:length(Low_Fear_T)
    L_Fear_R = Fear_R(Fe_R >= Low_Fear_T(i) & Fe_R <= Low_Fear_T(i)+1);
    Low_Fe_R = [Low_Fe_R; L_Fear_R];

    L_Fear_T = Fear_T(Fe_R >= Low_Fear_T(i) & Fe_R <= Low_Fear_T(i)+1);
    Low_Fe_T = [Low_Fe_T; L_Fear_T];
end

for i = 1:length(High_Happy_T)
    H_Happy_R = Happy_R(Ha_R >= High_Happy_T(i) & Ha_R <= High_Happy_T(i)+1);
    High_Ha_R = [High_Ha_R; H_Happy_R];

    H_Happy_T = Happy_T(Ha_R >= High_Happy_T(i) & Ha_R <= High_Happy_T(i)+1);
    High_Ha_T = [High_Ha_T; H_Happy_T];
end
for i = 1:length(Low_Happy_T)
    L_Happy_R = Happy_R(Ha_R >= Low_Happy_T(i) & Ha_R <= Low_Happy_T(i)+1);
    Low_Ha_R = [Low_Ha_R; L_Happy_R];

    L_Happy_T = Happy_T(Ha_R >= Low_Happy_T(i) & Ha_R <= Low_Happy_T(i)+1);
    Low_Ha_T = [Low_Ha_T; L_Happy_T];
end

for i = 1:length(High_Fe_R) % R_peaks in Fear condition & high fear and low fear
    label  = 'High_fear_R';
    ecode  = 100;
    onset = High_Fe_R(i)./srate; % in seconds
    nHFear_R = i;
    if i == 1 
        diff_ = 0;
        string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',nHFear_R,bepoch,ecode+1,label,onset,diff_,dura,enable);
    elseif i == length(High_Fe_R)
        diff_ = High_Fe_R(i) - High_Fe_R(i-1);
        string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',nHFear_R,bepoch,ecode+2,label,onset,diff_,dura, enable);
    else
        diff_ = High_Fe_R(i) - High_Fe_R(i-1);
        string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',nHFear_R,bepoch,ecode,label,onset,diff_,dura, enable);
    end
        disp(string);
        dlmwrite(erplistname,string,'-append','delimiter',''); 
end

for i = 1:length(High_Fe_T) % T_peaks in Fear condition & high fear and low fear
    label  = 'High_fear_T';
    ecode  = 150;
    onset = High_Fe_T(i)./srate; % in seconds
    nHFear_T = i;
    if i == 1 
        diff_ = 0;
        string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',nHFear_T,bepoch,ecode+1,label,onset,diff_,dura,enable);
    elseif i == length(High_Fe_T)
        diff_ = High_Fe_T(i) - High_Fe_T(i-1);
        string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',nHFear_T,bepoch,ecode+2,label,onset,diff_,dura, enable);
    else
        diff_ = High_Fe_T(i) - High_Fe_T(i-1);
        string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',nHFear_T,bepoch,ecode,label,onset,diff_,dura, enable);
    end
        disp(string);
        dlmwrite(erplistname,string,'-append','delimiter',''); 
end

for i = 1:length(Low_Fe_R) % R_peaks in Fear condition & high fear and low fear
    label  = 'Low_fear_R';
    ecode  = 200;
    onset = Low_Fe_R(i)./srate; % in seconds
    nLFear_R = i;
    if i == 1 
        diff_ = 0;
        string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',nLFear_R,bepoch,ecode+1,label,onset,diff_,dura,enable);
    elseif i == length(Low_Fe_R)
        diff_ = Low_Fe_R(i) - Low_Fe_R(i-1);
        string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',nLFear_R,bepoch,ecode+2,label,onset,diff_,dura, enable);
    else
        diff_ = Low_Fe_R(i) - Low_Fe_R(i-1);
        string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',nLFear_R,bepoch,ecode,label,onset,diff_,dura, enable);
    end
        disp(string);
        dlmwrite(erplistname,string,'-append','delimiter',''); 
end

for i = 1:length(Low_Fe_T) % T_wave in Fear condition & high fear and low fear
    label  = 'Low_fear_T';
    ecode  = 250;
    onset = Low_Fe_T(i)./srate; % in seconds
    nLFear_T = i;
    if i == 1 
        diff_ = 0;
        string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',nLFear_T,bepoch,ecode+1,label,onset,diff_,dura,enable);
    elseif i == length(Low_Fe_T)
        diff_ = Low_Fe_T(i) - Low_Fe_T(i-1);
        string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',nLFear_T,bepoch,ecode+2,label,onset,diff_,dura, enable);
    else
        diff_ = Low_Fe_T(i) - Low_Fe_T(i-1);
        string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',nLFear_T,bepoch,ecode,label,onset,diff_,dura, enable);
    end
        disp(string);
        dlmwrite(erplistname,string,'-append','delimiter',''); 
end

for i = 1:length(High_Ha_R) % R_peaks in Happy condition & high low
    label  = 'High_happy_R';
    ecode  = 300;
    onset = High_Ha_R(i)./srate; % in seconds
    nHHappy_R = i;
    if i == 1 
        diff_ = 0;
        string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',nHHappy_R,bepoch,ecode+1,label,onset,diff_,dura,enable);
    elseif i == length(High_Ha_R)
        diff_ = High_Ha_R(i) - High_Ha_R(i-1);
        string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',nHHappy_R,bepoch,ecode+2,label,onset,diff_,dura, enable);
    else
        diff_ = High_Ha_R(i) - High_Ha_R(i-1);
        string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',nHHappy_R,bepoch,ecode,label,onset,diff_,dura, enable);
    end
        disp(string);
        dlmwrite(erplistname,string,'-append','delimiter',''); 
end

for i = 1:length(High_Ha_T) % T_peaks in Happy condition & high low
    label  = 'High_happy_T';
    ecode  = 350;
    onset = High_Ha_T(i)./srate; % in seconds
    nHHappy_T = i;
    if i == 1 
        diff_ = 0;
        string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',nHHappy_T,bepoch,ecode+1,label,onset,diff_,dura,enable);
    elseif i == length(High_Ha_T)
        diff_ = High_Ha_T(i) - High_Ha_T(i-1);
        string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',nHHappy_T,bepoch,ecode+2,label,onset,diff_,dura, enable);
    else
        diff_ = High_Ha_T(i) - High_Ha_T(i-1);
        string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',nHHappy_T,bepoch,ecode,label,onset,diff_,dura, enable);
    end
        disp(string);
        dlmwrite(erplistname,string,'-append','delimiter',''); 
end

for i = 1:length(Low_Ha_R) % R_peaks in Fear condition & high fear and low fear
    label  = 'Low_Happy_R';
    ecode  = 400;
    onset = Low_Ha_R(i)./srate; % in seconds
    nLHappy_R = i;
    if i == 1 
        diff_ = 0;
        string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',nLHappy_R,bepoch,ecode+1,label,onset,diff_,dura,enable);
    elseif i == length(Low_Ha_R)
        diff_ = Low_Ha_R(i) - Low_Ha_R(i-1);
        string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',nLHappy_R,bepoch,ecode+2,label,onset,diff_,dura, enable);
    else
        diff_ = Low_Ha_R(i) - Low_Ha_R(i-1);
        string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',nLHappy_R,bepoch,ecode,label,onset,diff_,dura, enable);
    end
        disp(string);
        dlmwrite(erplistname,string,'-append','delimiter',''); 
end

for i = 1:length(Low_Ha_T) % T_peaks in Fear condition & high fear and low fear
    label  = 'Low_Happy_T';
    ecode  = 450;
    onset = Low_Ha_T(i)./srate; % in seconds
    nLHappy_T = i;
    if i == 1 
        diff_ = 0;
        string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',nLHappy_T,bepoch,ecode+1,label,onset,diff_,dura,enable);
    elseif i == length(Low_Ha_T)
        diff_ = Low_Ha_T(i) - Low_Ha_T(i-1);
        string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',nLHappy_T,bepoch,ecode+2,label,onset,diff_,dura, enable);
    else
        diff_ = Low_Ha_T(i) - Low_Ha_T(i-1);
        string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',nLHappy_T,bepoch,ecode,label,onset,diff_,dura, enable);
    end
        disp(string);
        dlmwrite(erplistname,string,'-append','delimiter',''); 
end

for i = 1:length(Neutral_R) % R_peaks in Neutral condition
    label  = 'neutral_R';
    ecode  = 500;
    onset = Neutral_R(i)./srate; % in seconds
    nNeutral_R = i;
    if i == 1 
        diff_ = 0;
        string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',nNeutral_R,bepoch,ecode+1,label,onset,diff_,dura,enable);
    elseif i == length(Neutral_R)
        diff_ = Neutral_R(i) - Neutral_R(i-1);
        string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',nNeutral_R,bepoch,ecode+2,label,onset,diff_,dura, enable);
    else
        diff_ = Neutral_R(i) - Neutral_R(i-1);
        string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',nNeutral_R,bepoch,ecode,label,onset,diff_,dura, enable);
    end
        disp(string);
        dlmwrite(erplistname,string,'-append','delimiter',''); 
end

for i = 1:length(Neutral_T) % T_peaks in Neutral condition
    label  = 'neutral_T';
    ecode  = 550;
    onset = Neutral_T(i)./srate; % in seconds
    nNeutral_T = i;
    if i == 1 
        diff_ = 0;
        string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',nNeutral_T,bepoch,ecode+1,label,onset,diff_,dura,enable);
    elseif i == length(Neutral_T)
        diff_ = Neutral_T(i) - Neutral_T(i-1);
        string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',nNeutral_T,bepoch,ecode+2,label,onset,diff_,dura, enable);
    else
        diff_ = Neutral_T(i) - Neutral_T(i-1);
        string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',nNeutral_T,bepoch,ecode,label,onset,diff_,dura, enable);
    end
        disp(string);
        dlmwrite(erplistname,string,'-append','delimiter',''); 
end

%% regress EEG data on processed ECG to eliminate the cardiac artefacts
% only clean data from movie onset and end 
processed_ECG = ecg_fpt.processed(EEG.event(2).latency:EEG.event(end).latency,1); %% onset of movie to end
EEG1 = EEG.data(:,EEG.event(2).latency:EEG.event(end).latency);
EEG1 = transpose(EEG1);
rEEG = []; % residual EEG
for i = 1:size(EEG1,2) % i means the ith channel in EEG
    b = []; bint = [];
    [b, bint, r]  = regress(EEG1(:,i),processed_ECG); % r is the residual
    r_T = transpose(r);
    rEEG = [rEEG;r_T];
end

EEG_reECG = EEG;
EEG_reECG.data(:,EEG.event(2).latency:EEG.event(end).latency) = rEEG; %% use EEG_reECG data in later process


EEG_reECG = pop_importeegeventlist(EEG_reECG, erplistname, 'ReplaceEventList', 'on' );

% segmentation using the ERPLAB 'pop_epochbin' function
binlistname = fullfile(folderBase,'brain-heart interplay/Binlists','movie_HEP_binlist.txt');
EEG_reECG         = pop_binlister(EEG_reECG, 'BDF', binlistname, 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' ); % GUI: 24-Oct-2017 15:26:01
segdura     = 1000*epochlength;
EEG_reECG         = pop_epochbin(EEG_reECG, [-200  segdura], 'pre');  % baseline correction for all

%% artifacts detection and rejection 
% 1. Remove the extraordinarily bad channels with trimOutlier
% remove bad channels with SD
stdAllPnts  = std(EEG_reECG.data(:,:),0,2); % sd for each channel
channelSdLowerBound = -10;
channelSdUpperBound = 200;
[a b]               = sort(stdAllPnts,'descend'); % a is sd, b is channel No.
badChanMask         = (stdAllPnts < channelSdLowerBound) | (stdAllPnts > channelSdUpperBound);
badChanIdx          = find(badChanMask);
if length(badChanIdx) > 8
    badChanIdx = b(1:8);
end
if any(badChanIdx)
    badChanName = {EEG_reECG.chanlocs(badChanIdx).labels};
    EEG_reECG.etc.trimOutlier.cleanChannelMask = ~badChanMask;
    EEG_reECG = pop_select(EEG_reECG, 'nochannel', badChanIdx);
    disp(sprintf('\nThe following channels were replaced:'));
    disp(badChanName)
else
    EEG_reECG.etc.trimOutlier.cleanChannelMask = logical(ones(EEG_reECG.nbchan,1));    
    disp(sprintf('\nNo channel removed.'))
end

% 2. run ICA 
if icapruning 
    EEG_reECG = pop_runica(EEG_reECG, 'icatype', 'runica', 'extended', 1, 'stop', 1E-7, 'interupt','off');
    cfg = [];
    cfg.opts.noplot      = 1;
    cfg.focalcomp.enable = 1;
    cfg.autocorr.enable  = 1;
    cfg.trialfoc.enable  = 1;
    cfg.SNR.enable       = 1;
    cfg.chancorr.enable  = 1;
    cfg.EOGcorr.enable   = 0;     
    manualjudgment       = 0;
    if manualjudgment
        [EEG_reECG com] = SASICA();
    else
        [EEG_reECG, com]  = eeg_SASICA(EEG_reECG,cfg);
        icarejcomps = find(EEG_reECG.reject.gcompreject);
        rejectfield = EEG_reECG.reject;
        EEG_reECG         = pop_subcomp(EEG_reECG, icarejcomps, 0);
        EEG_reECG.reject  = rejectfield;
        disp(['The following ICA components were removed:' num2str(icarejcomps)])
    end
end 

% 3. traditional artifacts detection and "rejection" 
%1) artifact dection with absolute values
EEG_reECG  = pop_artextval(EEG_reECG, 'Channel',1:EEG_reECG.nbchan,'Flag', 1,'Threshold',[-150 150],'Twindow',[-200 segdura]); 
disp(['num of epochs with artifacts is: ' num2str(sum(EEG_reECG.reject.rejmanual))]);
%2) artifact detection with Moving window peak to peak threshold: Moving window width: 200 ms. Window step: 50.
EEG_reECG  = pop_artmwppth( EEG_reECG, 'Channel' , 1:EEG_reECG.nbchan, 'Flag',3, 'Threshold', 150, 'Twindow', [-200 segdura], 'Windowsize', 100, 'Windowstep', 50);
disp(['num of epochs with artifacts is: ' num2str(sum(EEG_reECG.reject.rejmanual))]);

%% channel interpolation
maxbadchs2replace     = 13 - length(badChanIdx); % 13 is like 20% of 63 channels
EEG_reECG_bfchinterpolation = EEG_reECG;
numEpochs = EEG_reECG.trials;
tmpData = EEG_reECG.data;
for i=1:numEpochs
    outputstring = ['trial#' num2str(i) ' has ' num2str(sum(EEG_reECG.reject.rejmanualE(:,i))) ' badchs:']; % trial idx + total number of bad channels  
    for j=1:EEG_reECG.nbchan
        if EEG_reECG.reject.rejmanualE(j,i)
            outputstring=[outputstring ' ' num2str(j)];
        end
    end
    disp(outputstring);
    
    % only replace a channel when the total number of bad ones does not exceed the threshold;
    badChans = [];
    if sum(EEG_reECG.reject.rejmanualE(:,i)) > maxbadchs2replace
        disp(['too many bad channels']);
    else %do interpolation
        EEG_reECGi = pop_selectevent(EEG_reECG, 'epoch', i, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'off');
        badChanNum = find(EEG_reECG.reject.rejmanualE(:,i)); % find which channels are bad for this epoch
        EEG_reECGi_interp = eeg_interp(EEG_reECGi, badChanNum); % interpolate the bad chans for this epoch
        tmpData(:,:,i) = EEG_reECGi_interp.data; % store interpolated data into matrix
        
        EEG_reECG.reject.rejmanual(i) = 0;
        EEG_reECG.reject.rejmanualE(badChanNum,i) = 0;
    end
end

EEG_reECG.data = tmpData;

EEG_reECG = pop_syncroartifacts(EEG_reECG, 'Direction','eeglab2erplab');
pop_summary_AR_eeg_detection(EEG_reECG_bfchinterpolation,'');
pop_summary_AR_eeg_detection(EEG_reECG,'');
rejectstruct = EEG_reECG.reject;

%% Interpolate the overall bad channels
tempdata                = zeros(nbchan,EEG_reECG.pnts,EEG_reECG.trials,'single');
goodChans               = ~ismember([1:nbchan],badChanIdx);
tempdata(goodChans,:,:) = EEG_reECG.data;
EEG_reECG.data          = tempdata;
EEG_reECG.chanlocs      = chanlocs;
EEG_reECG.nbchan        = nbchan;
EEG_reECG               = eeg_interp(EEG_reECG,badChanIdx);

EEG_reECG.reject   = rejectstruct;

%% Re-referencing to average;
EEG_reECG = pop_reref(EEG_reECG, []);

%% Save the cleaned data in EEGLAB format;
EEG_reECG  = pop_saveset(EEG_reECG, 'filename', Finaldataset, 'filepath', outputfolder);

%% Do erp average and save the erp set
ERP = pop_averager(EEG_reECG , 'Criterion', 'good', 'ExcludeBoundary', 'on', 'SEM', 'on' );
% save
erpname= strrep(Finaldataset,'.set','_Averaged.erp');
ERP = pop_savemyerp(ERP, 'erpname', erpname, 'filename', erpname, 'filepath', outputfolder, 'Warning', 'off'); 

return 