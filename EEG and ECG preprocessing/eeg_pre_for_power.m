function [] = eeg_pre_for_power(id,age)
% This function preprocesses raw EEG data for power analysis.
% The preprocessing steps include:
% - Removal of 50 Hz line noise
% - Bandpass filtering (0.5–45 Hz)
% - Bad channel rejection (SD > 200 µV)
% - Artifact removal using Independent Component Analysis (ICA)

% Required toolboxes:
% - EEGLAB
% - ERPLAB
% - Zapline
% - CleanLine
% - trimOutlier

participantnumber  = id; % eg., 230723030
age = age; % eg., 85
icapruning        = 1;
replacearg        = 0;
epochlength       = 2; % EEG raw data were segmented to 2-s epochs to detect artifacts 

%% define the folders/paths
folderBase          = '/';
programs            = fullfile(folderBase,'brain-heart interplay',filesep);
datapath            = fullfile(folderBase,'sample_data/raw_eeg',filesep);
outputfolder = fullfile(programs,'eeg_cleaned_for_power',filesep);
erplist             = fullfile(programs,'movie_eeg_list',filesep);
ecgdatapath             = fullfile(programs,'ecg_processed',filesep);
addpath(programs);

%% check if the final output already exists
Finaldataset = ['movie ' num2str(participantnumber) ' eeg_for_power.set'];
if exist([outputfolder Finaldataset]) & replacearg == 0;
    disp([Finaldataset ' already exists! change replacearg to 1 if needs to replace it.']);
    return
end

%% 1) read the raw .vhdr file
% Load in the EEG data;
eeglab;close 
EEG = pop_loadbv([datapath num2str(participantnumber)], ['/' num2str(participantnumber) '_movie.vhdr'], [], []);

%% remove the ECG channel from EEG
EEG = pop_select(EEG,'nochannel',[64 65]); % 64 ECG 65 EDA

%% Data filtering with the continuous data of the EEG data
% 1) notch filtering with Zapline
EEG = pop_zapline_plus(EEG, 'noisefreqs','line','coarseFreqDetectPowerDiff',4,'chunkLength',0,'adaptiveNremove',1,'fixedNremove',1,'plotResults',0);

% 2）notch filtering with CleanLine
% This will run cleanline on all channels, scanning for lines +/- 1 Hz around the 50 and 100 Hz frequencies. 
% Each epoch will be cleaned individually and epochs containing lines that are significantly sinusoidal at 
% the p<=0.01 level will be cleaned. 
EEG = pop_cleanline(EEG, 'bandwidth',2,'chanlist',[1:EEG.nbchan] ,'computepower',1,'linefreqs',[50],'newversion',0,'normSpectrum',0,'p',0.01,'pad',2,'plotfigures',0,'scanforlines',1,'sigtype','Channels','taperbandwidth',2,'tau',100,'verb',1,'winsize',4,'winstep',1);

% 3) bandpass filter with the ERPLAB IIR butterworth filter
% order 4, [0.5 45]
EEG  = pop_basicfilter(EEG,  1:EEG.nbchan, 'Boundary', 'boundary', 'Cutoff', [0.5 45], 'Design', 'butter', 'Filter', 'bandpass', 'Order',  4); 

chanlocs = EEG.chanlocs;
nbchan   = EEG.nbchan;

% ecg
% load the ECG fiducial points (for Rs and Ts)
ecgfilename = ['movie ' num2str(participantnumber) ' ecg_fpt.mat']; 
load([ecgdatapath ecgfilename],'ecg_fpt');

%% create and import eventlist
%% 2) Eventlist; 
% 3 min for each movie clips happy/fearful/neutral
erplistname = [erplist 'movie ' num2str(participantnumber) ' erplist.txt'];
if exist(erplistname)
    delete(erplistname)
end

allevents = [];
all_lat = [];
% make sure the event in EEG is accurate
if length(EEG.event(:)) == 7
else
    disp('Events in EEG are wrong.');
    return;
end

for i = 1: length(EEG.event(:))
    eventmarker = EEG.event(i).type;
    switch eventmarker
        case 'boundary'
        case 'S  1'
            fear_onset = EEG.event(i).latency;
            allevents  = [allevents;eventmarker];
            all_lat    = [all_lat,EEG.event(i).latency];
        case 'S  2'
            fear_end = EEG.event(i).latency;
        case 'S  3'
            neutral_onset = EEG.event(i).latency;
            allevents  = [allevents;eventmarker];
            all_lat    = [all_lat,EEG.event(i).latency];
        case 'S  4'
            neutral_end = EEG.event(i).latency;
        case 'S  5'
            happy_onset = EEG.event(i).latency;
            allevents  = [allevents;eventmarker];
            all_lat    = [all_lat,EEG.event(i).latency];
        case 'S  6'
            happy_end = EEG.event(i).latency;
    end
end

nseconds    = 180; % 3 min for each movie clip
srate       = EEG.srate; % 500 hz
nepochs     = nseconds/epochlength; % 2s, epoch

for i = 1:size(allevents,1)
    eventmarker = allevents(i,:);
    if strcmp(eventmarker,'S  1')
        label  = 'fear';
        ecode  = 100;
    elseif strcmp(eventmarker,'S  3')
        label  = 'neutral';
        ecode  = 200;
    elseif strcmp(eventmarker,'S  5')
        label  = 'happy';
        ecode  = 300;
    end

    lat1 = all_lat(i);
    item = 0; bepoch = 0; diff_=0; dura=1000*epochlength; enable=1;

    for ii = 1:nepochs
        onset = epochlength*(ii-1) + lat1./srate; % in seconds
        item  = item +1;
        if ii == 1
            string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',item,bepoch,ecode+1,label,onset,diff_,dura,enable);
        else
            string=sprintf('%i %i %i %s %f %.2f %.1f 00000000 00000000 %i [    ]',item,bepoch,ecode,label,onset,diff_,dura,enable);
        end
        disp(string);
        dlmwrite(erplistname,string,'-append','delimiter','');       
    end
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

%% import the eventlist and replace the old one
EEG_reECG = pop_importeegeventlist(EEG_reECG, erplistname, 'ReplaceEventList', 'on' );

% segmentation using the ERPLAB 'pop_epochbin' function
binlistname = fullfile(programs,'Binlists','movie_binlist.txt');
EEG_reECG   = pop_binlister(EEG_reECG, 'BDF', binlistname, 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' ); 
segdura     = 1000*epochlength;
EEG_reECG   = pop_epochbin( EEG_reECG, [0  segdura],  'none');  % baseline correction

%% artifacts detection and rejection 
% 1. Remove the extraordinarily bad channels with trimOutlier
% remove bad channels with SD > 200
stdAllPnts  = std(EEG_reECG.data(:,:),0,2);
channelSdLowerBound = -10;
channelSdUpperBound = 200;
[a b]               = sort(stdAllPnts,'descend');
badChanMask         = (stdAllPnts < channelSdLowerBound) | (stdAllPnts > channelSdUpperBound);
badChanIdx          = find(badChanMask);

if length(badChanIdx) > 8
    badChanIdx = b(1:8);
end

if any(badChanIdx)
    badChanName = {EEG_reECG.chanlocs(badChanIdx).labels};
    
    % Save the clean channel mask.
    EEG_reECG.etc.trimOutlier.cleanChannelMask = ~badChanMask;
    
    EEG_reECG = pop_select(EEG_reECG, 'nochannel', badChanIdx);
    disp(sprintf('\nThe following channels were replaced:'));
    disp(badChanName)
else
    % Save the clean channel mask.
    EEG_reECG.etc.trimOutlier.cleanChannelMask = logical(ones(EEG_reECG.nbchan,1));    
    disp(sprintf('\nNo channel removed.'))
end

% 2. optional: run ICA 
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

% 3. traditional artifacts detection and "rejection" (just marked not excluded)
%1) artifact dection with absolute values
EEG_reECG  = pop_artextval(EEG_reECG, 'Channel',1:EEG_reECG.nbchan,'Flag', 1,'Threshold',[-150 150],'Twindow',[0 segdura]); 
disp(['num of epochs with artifacts is: ' num2str(sum(EEG_reECG.reject.rejmanual))]);
%2) artifact detection with Moving window peak to peak threshold: Moving window width: 200 ms. Window step: 50.
EEG_reECG  = pop_artmwppth( EEG_reECG, 'Channel', 1:EEG_reECG.nbchan, 'Flag',3, 'Threshold', 150, 'Twindow', [0 segdura], 'Windowsize', 100, 'Windowstep', 50);
disp(['num of epochs with artifacts is: ' num2str(sum(EEG_reECG.reject.rejmanual))]);

%% channel interpolation
maxbadchs2replace     = 13 - length(badChanIdx); % 13 is like 20% of 63 channels
EEG_bfchinterpolation = EEG_reECG;
numEpochs = EEG_reECG.trials;
tmpData = EEG_reECG.data;
for i=1:numEpochs
    outputstring = ['trial#' num2str(i) ' has ' num2str(sum(EEG_reECG.reject.rejmanualE(:,i))) ' badchs:']; % trial idx + total number of bad channels  
    for j=1:EEG_reECG.nbchan
        if EEG_reECG.reject.rejmanualE(j,i)
            outputstring = [outputstring ' ' num2str(j)];
        end
    end
    disp(outputstring);
    
    % only replace a channel when the total number of bad ones does not exceed the threshold;
    badChans = [];
    if sum(EEG_reECG.reject.rejmanualE(:,i)) > maxbadchs2replace
        disp(['too many bad channels']);
    else % do interpolation
        EEGi = pop_selectevent(EEG_reECG, 'epoch', i, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'off');
        badChanNum = find(EEG_reECG.reject.rejmanualE(:,i)); % find which channels are bad for this epoch
        EEGi_interp = eeg_interp(EEGi, badChanNum); % interpolate the bad chans for this epoch
        tmpData(:,:,i) = EEGi_interp.data; % store interpolated data into matrix
        
        EEG_reECG.reject.rejmanual(i) = 0;
        EEG_reECG.reject.rejmanualE(badChanNum,i) = 0;
    end
end

EEG_reECG.data = tmpData;

EEG_reECG = pop_syncroartifacts(EEG_reECG, 'Direction','eeglab2erplab');
pop_summary_AR_eeg_detection(EEG_bfchinterpolation,''); % before interpolation
pop_summary_AR_eeg_detection(EEG_reECG,'');

% the EEG.reject structure will be erased whenever there is any change occured to the dataset, so save it now and use it before ERP average;
rejectstruct = EEG_reECG.reject;

%% Interpolate the overall bad channels that were removed from the beginning;
tempdata                = zeros(nbchan,EEG_reECG.pnts,EEG_reECG.trials,'single');
goodChans               = ~ismember([1:nbchan],badChanIdx);
tempdata(goodChans,:,:) = EEG_reECG.data;
EEG_reECG.data                = tempdata;
EEG_reECG.chanlocs            = chanlocs;
EEG_reECG.nbchan              = nbchan;
EEG_reECG                     = eeg_interp(EEG_reECG,badChanIdx);

EEG_reECG.reject   = rejectstruct;

%% Re-referencing to average;
EEG_reECG = pop_reref(EEG_reECG, []);

%% Save the cleaned data in Fieldtrip format;
EEG_FT = eeglab2fieldtrip(EEG_reECG,'preprocessing','none');
FT_filename = ['movie ID ' num2str(participantnumber) ' Age ' num2str(age) ' FT_EEG.mat'];
save([outputfolder FT_filename],'EEG_FT');% save 

return 