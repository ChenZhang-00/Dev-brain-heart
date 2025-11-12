function [] = movie_EEG_TF(id, age)
% This function performs power analysis on EEG data using short-time Fourier transform (STFT).
%
% Analysis settings:
% - Method: STFT with Hanning taper
% - Frequency range: 1 to 45 Hz (0.5 Hz steps)
% - Time window length: 2 seconds
% - Window overlap: 50% (1-second step size)
% - Time range: 1 to 177 seconds (1-second resolution, covering [0, 178s])
%
% Output:
% - EEG power time series
%
% Required toolbox:
% - FieldTrip

addpath('/toolbox/fieldtrip-master');

id = id;
age = age;
replace = 1;        

% check if the output files already exist;
outputpath = '/brain-heart interplay/movie_EEG_TS/';
outputname = ['ID ' num2str(id) ' Age ' num2str(age) ' EEG_pow TS.mat'];

if exist([outputpath outputname]) & replace == 0;disp([outputname ' already exists.']);return;end

%% Global Variables
global EEG_FT EEG_freq;
ft_defaults;

%% Load EEG datasets;
% File name and path;
ftpath     = '/brain-heart interplay/eeg_cleaned_for_power/';
ftfilename = ['movie ID ' num2str(id) ' Age ' num2str(age) ' FT_EEG.mat']; % 
disp(['load ' ftpath ftfilename]);

load([ftpath ftfilename],'EEG_FT'); 

cfg                = [];
cfg.trials         = find(EEG_FT.trialinfo.bini == 2); % happy
EEG_FT_Ha     = ft_selectdata(cfg,EEG_FT); % happy trials

cfg                = [];
cfg.trials         = find(EEG_FT.trialinfo.bini == 1); % fearful
EEG_FT_Fe     = ft_selectdata(cfg,EEG_FT); % fear trials

cfg                = [];
cfg.trials         = find(EEG_FT.trialinfo.bini == 3); % neutral
EEG_FT_Ne     = ft_selectdata(cfg,EEG_FT); % neutral trials

Ha_nepoch = numel(EEG_FT_Ha.trial);
Fe_nepoch = numel(EEG_FT_Fe.trial);
Ne_nepoch = numel(EEG_FT_Ne.trial);

if Ha_nepoch == 89
    re_Ha_clip = cell2mat(EEG_FT_Ha.trial); % reconstruct the continuous EEG data of happy clip
    re_time = [0:0.002:177.998]; % 89000
    EEG_FT_Ha.trial = re_Ha_clip;
    EEG_FT_Ha.time = re_time;
else
    disp('Happy epochs do noe equal 89');
    return;
end

if Fe_nepoch == 89
    re_Fe_clip = cell2mat(EEG_FT_Fe.trial); % reconstruct the continuous EEG data of fearful clip
    re_time = [0:0.002:177.998]; % 89000
    EEG_FT_Fe.trial = re_Fe_clip;
    EEG_FT_Fe.time = re_time;
else
    disp('Fear epochs do noe equal 89');
    return;
end

if Ne_nepoch == 89
    re_Ne_clip = cell2mat(EEG_FT_Ne.trial); % reconstruct the continuous EEG data of Neutral clip
    re_time = [0:0.002:177.998]; % 89000
    EEG_FT_Ne.trial = re_Ne_clip;
    EEG_FT_Ne.time = re_time;
else
    disp('Neutral epochs do noe equal 89');
    return;
end

% re-construct EEG data with 3 continuous movie clips
EEG_FT_movie = EEG_FT;
EEG_FT_movie.trial = {EEG_FT_Ha.trial,EEG_FT_Fe.trial,EEG_FT_Ne.trial};
EEG_FT_movie.time = {EEG_FT_Ha.time,EEG_FT_Fe.time,EEG_FT_Ne.time};
% trialinfo table
bepoch = [1;2;3];
bini = [2;1;3];
binlabel = {'B2(happy)';'B1(fear)';'B3(neutral)'};
codelabel = {'happy';'fear';'neutral'};
duration = [178000;178000;178000];
enable = [1;1;1];
flag = [0;0;0];
item = [1;2;3];
type = {'B2(happy)';'B1(fear)';'B3(neutral)'};

EEG_FT_movie.trialinfo = table(bepoch, bini, binlabel, codelabel, duration,enable, flag, item, type);

% compute the spectrogram pow time series
% short-time Fourier transform, hanning taper, sliding window of 2s with a 50% overlap 
cfg              = [];
cfg.output       = 'pow';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 1:0.5:45;                     % analysis 1 to 45 Hz in steps of 0.5 Hz
cfg.t_ftimwin    = ones(length(cfg.foi),1).*2;   % length of time window = 2 sec
cfg.toi          = 1:1:177;                      % [0, 178s], overlap for '50%', slide for 1s/step

cfg.trials         = find(EEG_FT_movie.trialinfo.bini == 2); % happy
TFR_Ha = ft_freqanalysis(cfg, EEG_FT_movie);

cfg.trials         = find(EEG_FT_movie.trialinfo.bini == 1); % fearful
TFR_Fe = ft_freqanalysis(cfg, EEG_FT_movie);

cfg.trials         = find(EEG_FT_movie.trialinfo.bini == 3); % neutral
TFR_Ne = ft_freqanalysis(cfg, EEG_FT_movie);


%% integrated within 3 frequency bands
% delta(1-4Hz) theta(4-7Hz) alpha(7-12Hz)
Ha_delta = sum(TFR_Ha.powspctrm(:,1:find(TFR_Ha.freq==4),:),2);
Ha_theta = sum(TFR_Ha.powspctrm(:,find(TFR_Ha.freq==4):find(TFR_Ha.freq==7),:),2);
Ha_alpha = sum(TFR_Ha.powspctrm(:,find(TFR_Ha.freq==7):find(TFR_Ha.freq==12),:),2);

Fe_delta = sum(TFR_Fe.powspctrm(:,1:find(TFR_Fe.freq==4),:),2);
Fe_theta = sum(TFR_Fe.powspctrm(:,find(TFR_Fe.freq==4):find(TFR_Fe.freq==7),:),2);
Fe_alpha = sum(TFR_Fe.powspctrm(:,find(TFR_Fe.freq==7):find(TFR_Fe.freq==12),:),2);

Ne_delta = sum(TFR_Ne.powspctrm(:,1:find(TFR_Ne.freq==4),:),2);
Ne_theta = sum(TFR_Ne.powspctrm(:,find(TFR_Ne.freq==4):find(TFR_Ne.freq==7),:),2);
Ne_alpha = sum(TFR_Ne.powspctrm(:,find(TFR_Ne.freq==7):find(TFR_Ne.freq==12),:),2);

% save in movie_EEG_TS
movie_EEG_TS.happy.delta = Ha_delta;
movie_EEG_TS.happy.theta = Ha_theta;
movie_EEG_TS.happy.alpha = Ha_alpha;

movie_EEG_TS.fear.delta = Fe_delta;
movie_EEG_TS.fear.theta = Fe_theta;
movie_EEG_TS.fear.alpha = Fe_alpha;

movie_EEG_TS.neutral.delta = Ne_delta;
movie_EEG_TS.neutral.theta = Ne_theta;
movie_EEG_TS.neutral.alpha = Ne_alpha;

if exist([outputpath outputname]) & replace == 0
else
    save([outputpath outputname],'movie_EEG_TS');
end

return