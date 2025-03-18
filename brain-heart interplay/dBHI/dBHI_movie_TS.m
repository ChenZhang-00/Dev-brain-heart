function [] = dBHI_movie_TS(id,age)
% This function computes the directional brain-heart interplay 
% across different EEG bands and HRV components during three movie viewing conditions.

%% Load EEG and ECG time series
replace = 1;
% File name and path;
EEGpath         = '/brain-heart interplay/movie_EEG_TS/';
EEGfilename     = ['ID ' num2str(id) ' Age ' num2str(age) ' EEG_pow TS.mat'];
disp(['load ' EEGpath EEGfilename]);

load([EEGpath EEGfilename], 'movie_EEG_TS'); % movie_EEG_TS, happy/fear/neutral × alpha/beta/delta/gamma/theta

ECGpath         = '/brain-heart interplay/movie_ECG_TS/';
ECGfilename     = [num2str(id) '_movie_ECG_TS.mat'];
disp(['load ' ECGpath ECGfilename]);

ECG_TS = load([ECGpath ECGfilename]); % happy, fear, neutral × lf, hf

%% happy/neutral/fear × lf/hf × a/b/d/g/t
% happy
happy_alpha = reshape(movie_EEG_TS.happy.alpha, [63,177]);
happy_EEGa  = happy_alpha(:,1:176);

happy_beta = reshape(movie_EEG_TS.happy.beta, [63,177]);
happy_EEGb  = happy_beta(:,1:176);

happy_delta = reshape(movie_EEG_TS.happy.delta, [63,177]);
happy_EEGd  = happy_delta(:,1:176);

happy_gamma = reshape(movie_EEG_TS.happy.gamma, [63,177]);
happy_EEGg  = happy_gamma(:,1:176);

happy_theta = reshape(movie_EEG_TS.happy.theta, [63,177]);
happy_EEGt  = happy_theta(:,1:176);

happy_lf = ECG_TS.happy_lf(1,1:176);
happy_hf = ECG_TS.happy_hf(1,1:176);
happy_RR = ECG_TS.happy_RR;
% fear
fear_alpha = reshape(movie_EEG_TS.fear.alpha, [63,177]);
fear_EEGa  = fear_alpha(:,1:176);

fear_beta = reshape(movie_EEG_TS.fear.beta, [63,177]);
fear_EEGb  = fear_beta(:,1:176);

fear_delta = reshape(movie_EEG_TS.fear.delta, [63,177]);
fear_EEGd  = fear_delta(:,1:176);

fear_gamma = reshape(movie_EEG_TS.fear.gamma, [63,177]);
fear_EEGg  = fear_gamma(:,1:176);

fear_theta = reshape(movie_EEG_TS.fear.theta, [63,177]);
fear_EEGt  = fear_theta(:,1:176);

fear_lf = ECG_TS.fear_lf(1,1:176);
fear_hf = ECG_TS.fear_hf(1,1:176);
fear_RR = ECG_TS.fear_RR;
% neutral
neutral_alpha = reshape(movie_EEG_TS.neutral.alpha, [63,177]);
neutral_EEGa  = neutral_alpha(:,1:176);

neutral_beta = reshape(movie_EEG_TS.neutral.beta, [63,177]);
neutral_EEGb  = neutral_beta(:,1:176);

neutral_delta = reshape(movie_EEG_TS.neutral.delta, [63,177]);
neutral_EEGd  = neutral_delta(:,1:176);

neutral_gamma = reshape(movie_EEG_TS.neutral.gamma, [63,177]);
neutral_EEGg  = neutral_gamma(:,1:176);

neutral_theta = reshape(movie_EEG_TS.neutral.theta, [63,177]);
neutral_EEGt  = neutral_theta(:,1:176);

neutral_lf = ECG_TS.neutral_lf(1,1:176);
neutral_hf = ECG_TS.neutral_hf(1,1:176);
neutral_RR = ECG_TS.neutral_RR;

Fs = 1;
%% dBHI timeseires computations
% happy
[ha_LFToAlpha, ha_AlphaToHF, ha_AlphaToLF] = dBHI_model_child(happy_EEGa,happy_lf,Fs,happy_RR, 15);
[ha_HFToAlpha, ha_AlphaToHF, ha_AlphaToLF] = dBHI_model_child(happy_EEGa,happy_hf,Fs,happy_RR, 15);

[ha_LFToBeta, ha_BetaToHF, ha_BetaToLF] = dBHI_model_child(happy_EEGb,happy_lf,Fs,happy_RR, 15);
[ha_HFToBeta, ha_BetaToHF, ha_BetaToLF] = dBHI_model_child(happy_EEGb,happy_hf,Fs,happy_RR, 15);

[ha_LFToDelta, ha_DeltaToHF, ha_DeltaToLF] = dBHI_model_child(happy_EEGd,happy_lf,Fs,happy_RR, 15);
[ha_HFToDelta, ha_DeltaToHF, ha_DeltaToLF] = dBHI_model_child(happy_EEGd,happy_hf,Fs,happy_RR, 15);

[ha_LFToGamma, ha_GammaToHF, ha_GammaToLF] = dBHI_model_child(happy_EEGg,happy_lf,Fs,happy_RR, 15);
[ha_HFToGamma, ha_GammaToHF, ha_GammaToLF] = dBHI_model_child(happy_EEGg,happy_hf,Fs,happy_RR, 15);

[ha_LFToTheta, ha_ThetaToHF, ha_ThetaToLF] = dBHI_model_child(happy_EEGt,happy_lf,Fs,happy_RR, 15);
[ha_HFToTheta, ha_ThetaToHF, ha_ThetaToLF] = dBHI_model_child(happy_EEGt,happy_hf,Fs,happy_RR, 15);

% fearful
[fe_LFToAlpha, fe_AlphaToHF, fe_AlphaToLF] = dBHI_model_child(fear_EEGa,fear_lf,Fs,fear_RR, 15);
[fe_HFToAlpha, fe_AlphaToHF, fe_AlphaToLF] = dBHI_model_child(fear_EEGa,fear_hf,Fs,fear_RR, 15);

[fe_LFToBeta, fe_BetaToHF, fe_BetaToLF] = dBHI_model_child(fear_EEGb,fear_lf,Fs,fear_RR, 15);
[fe_HFToBeta, fe_BetaToHF, fe_BetaToLF] = dBHI_model_child(fear_EEGb,fear_hf,Fs,fear_RR, 15);

[fe_LFToDelta, fe_DeltaToHF, fe_DeltaToLF] = dBHI_model_child(fear_EEGd,fear_lf,Fs,fear_RR, 15);
[fe_HFToDelta, fe_DeltaToHF, fe_DeltaToLF] = dBHI_model_child(fear_EEGd,fear_hf,Fs,fear_RR, 15);

[fe_LFToGamma, fe_GammaToHF, fe_GammaToLF] = dBHI_model_child(fear_EEGg,fear_lf,Fs,fear_RR, 15);
[fe_HFToGamma, fe_GammaToHF, fe_GammaToLF] = dBHI_model_child(fear_EEGg,fear_hf,Fs,fear_RR, 15);

[fe_LFToTheta, fe_ThetaToHF, fe_ThetaToLF] = dBHI_model_child(fear_EEGt,fear_lf,Fs,fear_RR, 15);
[fe_HFToTheta, fe_ThetaToHF, fe_ThetaToLF] = dBHI_model_child(fear_EEGt,fear_hf,Fs,fear_RR, 15);

% neutral
[ne_LFToAlpha, ne_AlphaToHF, ne_AlphaToLF] = dBHI_model_child(neutral_EEGa,neutral_lf,Fs,neutral_RR, 15);
[ne_HFToAlpha, ne_AlphaToHF, ne_AlphaToLF] = dBHI_model_child(neutral_EEGa,neutral_hf,Fs,neutral_RR, 15);

[ne_LFToBeta, ne_BetaToHF, ne_BetaToLF] = dBHI_model_child(neutral_EEGb,neutral_lf,Fs,neutral_RR, 15);
[ne_HFToBeta, ne_BetaToHF, ne_BetaToLF] = dBHI_model_child(neutral_EEGb,neutral_hf,Fs,neutral_RR, 15);

[ne_LFToDelta, ne_DeltaToHF, ne_DeltaToLF] = dBHI_model_child(neutral_EEGd,neutral_lf,Fs,neutral_RR, 15);
[ne_HFToDelta, ne_DeltaToHF, ne_DeltaToLF] = dBHI_model_child(neutral_EEGd,neutral_hf,Fs,neutral_RR, 15);

[ne_LFToGamma, ne_GammaToHF, ne_GammaToLF] = dBHI_model_child(neutral_EEGg,neutral_lf,Fs,neutral_RR, 15);
[ne_HFToGamma, ne_GammaToHF, ne_GammaToLF] = dBHI_model_child(neutral_EEGg,neutral_hf,Fs,neutral_RR, 15);

[ne_LFToTheta, ne_ThetaToHF, ne_ThetaToLF] = dBHI_model_child(neutral_EEGt,neutral_lf,Fs,neutral_RR, 15);
[ne_HFToTheta, ne_ThetaToHF, ne_ThetaToLF] = dBHI_model_child(neutral_EEGt,neutral_hf,Fs,neutral_RR, 15);


%% save movie_dBHI

% happy
movie_dBHI.happy.LF2a = ha_LFToAlpha;
movie_dBHI.happy.HF2a = ha_HFToAlpha;
movie_dBHI.happy.a2LF = ha_AlphaToLF;
movie_dBHI.happy.a2HF = ha_AlphaToHF;

movie_dBHI.happy.LF2b = ha_LFToBeta;
movie_dBHI.happy.HF2b = ha_HFToBeta;
movie_dBHI.happy.b2LF = ha_BetaToLF;
movie_dBHI.happy.b2HF = ha_BetaToHF;

movie_dBHI.happy.LF2d = ha_LFToDelta;
movie_dBHI.happy.HF2d = ha_HFToDelta;
movie_dBHI.happy.d2LF = ha_DeltaToLF;
movie_dBHI.happy.d2HF = ha_DeltaToHF;

movie_dBHI.happy.LF2g = ha_LFToGamma;
movie_dBHI.happy.HF2g = ha_HFToGamma;
movie_dBHI.happy.g2LF = ha_GammaToLF;
movie_dBHI.happy.g2HF = ha_GammaToHF;

movie_dBHI.happy.LF2t = ha_LFToTheta;
movie_dBHI.happy.HF2t = ha_HFToTheta;
movie_dBHI.happy.t2LF = ha_ThetaToLF;
movie_dBHI.happy.t2HF = ha_ThetaToHF;

% fearful
movie_dBHI.fear.LF2a = fe_LFToAlpha;
movie_dBHI.fear.HF2a = fe_HFToAlpha;
movie_dBHI.fear.a2LF = fe_AlphaToLF;
movie_dBHI.fear.a2HF = fe_AlphaToHF;

movie_dBHI.fear.LF2b = fe_LFToBeta;
movie_dBHI.fear.HF2b = fe_HFToBeta;
movie_dBHI.fear.b2LF = fe_BetaToLF;
movie_dBHI.fear.b2HF = fe_BetaToHF;

movie_dBHI.fear.LF2d = fe_LFToDelta;
movie_dBHI.fear.HF2d = fe_HFToDelta;
movie_dBHI.fear.d2LF = fe_DeltaToLF;
movie_dBHI.fear.d2HF = fe_DeltaToHF;

movie_dBHI.fear.LF2g = fe_LFToGamma;
movie_dBHI.fear.HF2g = fe_HFToGamma;
movie_dBHI.fear.g2LF = fe_GammaToLF;
movie_dBHI.fear.g2HF = fe_GammaToHF;

movie_dBHI.fear.LF2t = fe_LFToTheta;
movie_dBHI.fear.HF2t = fe_HFToTheta;
movie_dBHI.fear.t2LF = fe_ThetaToLF;
movie_dBHI.fear.t2HF = fe_ThetaToHF;

% neutral
movie_dBHI.neutral.LF2a = ne_LFToAlpha;
movie_dBHI.neutral.HF2a = ne_HFToAlpha;
movie_dBHI.neutral.a2LF = ne_AlphaToLF;
movie_dBHI.neutral.a2HF = ne_AlphaToHF;

movie_dBHI.neutral.LF2b = ne_LFToBeta;
movie_dBHI.neutral.HF2b = ne_HFToBeta;
movie_dBHI.neutral.b2LF = ne_BetaToLF;
movie_dBHI.neutral.b2HF = ne_BetaToHF;

movie_dBHI.neutral.LF2d = ne_LFToDelta;
movie_dBHI.neutral.HF2d = ne_HFToDelta;
movie_dBHI.neutral.d2LF = ne_DeltaToLF;
movie_dBHI.neutral.d2HF = ne_DeltaToHF;

movie_dBHI.neutral.LF2g = ne_LFToGamma;
movie_dBHI.neutral.HF2g = ne_HFToGamma;
movie_dBHI.neutral.g2LF = ne_GammaToLF;
movie_dBHI.neutral.g2HF = ne_GammaToHF;

movie_dBHI.neutral.LF2t = ne_LFToTheta;
movie_dBHI.neutral.HF2t = ne_HFToTheta;
movie_dBHI.neutral.t2LF = ne_ThetaToLF;
movie_dBHI.neutral.t2HF = ne_ThetaToHF;

outputpath = '/brain-heart interplay/movie_dBHI_TS/';
outputname = ['ID ' num2str(id) ' Age ' num2str(age) ' movie_dBHI_TS.mat'];

if exist([outputpath outputname]) & replace == 0
else
    save([outputpath outputname],'movie_dBHI');
end

return