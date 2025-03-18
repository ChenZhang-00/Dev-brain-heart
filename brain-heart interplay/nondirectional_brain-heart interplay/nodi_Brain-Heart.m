
%% nondirectional brain-heart interplay 
% This script calculates the Pearson's correlation between 
% EEG and cardiac activity for each child.

% read in children's info
child_info = readtable("\child_info.csv");

ECG_TS_folder = "\brain-heart interplay\movie_ECG_TS\";
EEG_TS_folder = "\brain-heart interplay\movie_EEG_TS\";

% montage for frontal, central, posterior chs
Frontal = [1,32,33,34,35,62,63,5,4,37,3,36,2,61,31,60,30,29];
Central = [38,6,39,7,27,58,28,59,9,41,8,40,26,57,25,56,24,42,10,43,11,53,22,54,23,55];
Posterior = [15,14,45,13,44,12,52,21,51,20,19,46,47,48,49,50,16,17,18];

% Initialize an empty cell array to store results
results = {};  % Each row will be one subject, and each column will correspond to a different correlation coefficient.

% Define the frequency bands, emotions, and regions for easy access
freq_bands = {'alpha', 'beta', 'delta', 'theta', 'gamma'};
emotions = {'happy', 'fear'};
regions = {'Frontal', 'Central', 'Posterior'};

% Iterate over the subjects
for i = 1:size(child_info, 1)
    IDi = child_info.ID(i);
    age = child_info.Age_month(i);

    % ECG_TS
    ECG_TS_file = [num2str(IDi) '_movie_ECG_TS.mat'];
    load(ECG_TS_folder + ECG_TS_file); % fear_hf; fear_lf; fear_RR_res{1,1} - 4Hz
    FENE.lgHF = log(fear_hf(1:176) + 1) - log(mean(neutral_hf(1:176)) + 1);
    FENE.lgLF = log(fear_lf(1:176) + 1) - log(mean(neutral_lf(1:176)) + 1);
    FENE.IBI = mean(reshape(fear_RR_res{1,1}(1:704), 4, []), 1) / 1000 - mean(neutral_RR);
    HANE.lgHF = log(happy_hf(1:176) + 1) - log(mean(neutral_hf(1:176)) + 1);
    HANE.lgLF = log(happy_lf(1:176) + 1) - log(mean(neutral_lf(1:176)) + 1);
    HANE.IBI = mean(reshape(happy_RR_res{1,1}(1:704), 4, []), 1) / 1000 - mean(neutral_RR);

    % EEG_TS
    EEG_TS_file = ['ID ' num2str(IDi) ' Age ' num2str(age) ' EEG_pow TS.mat'];
    load(EEG_TS_folder + EEG_TS_file);

    % Initialize correlation variables for this subject
    r_HANE_values = [];
    r_FENE_values = [];

    % Iterate through the emotions, frequency bands, and regions
    for emotion_idx = 1:length(emotions)
        for freq_idx = 1:length(freq_bands)
            for region_idx = 1:length(regions)
                emotion = emotions{emotion_idx};
                freq_band = freq_bands{freq_idx};
                region = regions{region_idx};

                % Compute the trial data (log-transformed differences)
                trial_data = mean(log(movie_EEG_TS.(emotion).(freq_band)(eval(region), 1:176)), 1) - mean(log(movie_EEG_TS.neutral.(freq_band)(eval(region), 1:176)), 'all');

                if strcmp(emotion, 'happy')
                    HANE.(freq_band).(region) = trial_data;
                    % Pearson correlation for happy emotion
                    r_HANE_values = [r_HANE_values, ...
                        corr(trial_data', HANE.lgHF'), ...  % r_HANE_<freq_band>_<region>_HF
                        corr(trial_data', HANE.lgLF'), ...  % r_HANE_<freq_band>_<region>_LF
                        corr(trial_data', HANE.IBI')];     % r_HANE_<freq_band>_<region>_IBI
                elseif strcmp(emotion, 'fear')
                    FENE.(freq_band).(region) = trial_data;
                    % Pearson correlation for fear emotion
                    r_FENE_values = [r_FENE_values, ...
                        corr(trial_data', FENE.lgHF'), ...  % r_FENE_<freq_band>_<region>_HF
                        corr(trial_data', FENE.lgLF'), ...  % r_FENE_<freq_band>_<region>_LF
                        corr(trial_data', FENE.IBI')];     % r_FENE_<freq_band>_<region>_IBI
                end
            end
        end
    end

    % Create a row for this subject with the corresponding ID and correlation values
    result_row = {IDi};
    
    % Add the correlations for HANE (happy)
    for freq_idx = 1:length(freq_bands)
        for region_idx = 1:length(regions)
            result_row = [result_row, ...
                r_HANE_values((freq_idx - 1) * length(regions) + region_idx * 3 - 2), ...  % r_HANE_<freq_band>_<region>_HF
                r_HANE_values((freq_idx - 1) * length(regions) + region_idx * 3 - 1), ...  % r_HANE_<freq_band>_<region>_LF
                r_HANE_values((freq_idx - 1) * length(regions) + region_idx * 3)];         % r_HANE_<freq_band>_<region>_IBI
        end
    end

    % Add the correlations for FENE (fear)
    for freq_idx = 1:length(freq_bands)
        for region_idx = 1:length(regions)
            result_row = [result_row, ...
                r_FENE_values((freq_idx - 1) * length(regions) + region_idx * 3 - 2), ...  % r_FENE_<freq_band>_<region>_HF
                r_FENE_values((freq_idx - 1) * length(regions) + region_idx * 3 - 1), ...  % r_FENE_<freq_band>_<region>_LF
                r_FENE_values((freq_idx - 1) * length(regions) + region_idx * 3)];         % r_FENE_<freq_band>_<region>_IBI
        end
    end

    % Append the result_row to the results cell array
    results = [results; result_row];
end

% Define column names based on frequency bands, regions, and the types of correlation (HF, LF, IBI)
column_names = {'ID'};
for freq_idx = 1:length(freq_bands)
    for region_idx = 1:length(regions)
        column_names = [column_names, ...
            strcat('r_HANE_', freq_bands{freq_idx}, '_', regions{region_idx}, '_HF'), ...
            strcat('r_HANE_', freq_bands{freq_idx}, '_', regions{region_idx}, '_LF'), ...
            strcat('r_HANE_', freq_bands{freq_idx}, '_', regions{region_idx}, '_IBI'), ...
            strcat('r_FENE_', freq_bands{freq_idx}, '_', regions{region_idx}, '_HF'), ...
            strcat('r_FENE_', freq_bands{freq_idx}, '_', regions{region_idx}, '_LF'), ...
            strcat('r_FENE_', freq_bands{freq_idx}, '_', regions{region_idx}, '_IBI')];
    end
end

% save
result_table = cell2table(results, 'VariableNames', column_names);
writetable(result_table, '\brain-heart interplay\nondirectional_brain-heart interplay\nondi_BH_r.csv',"QuoteStrings","all");

