% ---------------------------------------------------------------
% Extract EEG Power Time Series and averaged acorss regions
% ---------------------------------------------------------------
% 1. Loads EEG time-series data for each child.
% 2. Computes log-transformed EEG power and averages within regions.
% 3. Saves region-level time series for further analysis.
% ---------------------------------------------------------------

%% Configuration
child_info = readtable("\all_children_info.csv");
data_path = '\movie_EEG_TS';
save_path = '\EEG_pow_region';

% Channel groups
Frontal   = [1,32,33,34,35,62,63,5,4,37,3,36,2,61,31,60,30,29];
Central   = [38,6,39,7,27,58,28,59,9,41,8,40,26,57,25,56,24,42,10,43,11,53,22,54,23,55];
Posterior = [15,14,45,13,44,12,52,21,51,20,19,46,47,48,49,50,16,17,18];
montage = struct('Frontal', Frontal, 'Central', Central, 'Posterior', Posterior);

emos = {'happy', 'fear', 'neutral'};
bands = {'delta', 'theta', 'alpha'};
regions = fieldnames(montage);
T_length = 176;

%% Process each subject
for i = 1:height(child_info)
    id = child_info.ID(i);
    age = child_info.Age_month(i);
    pow_name = sprintf('ID %d Age %d EEG_pow TS.mat', id, age);
    file_path = fullfile(data_path, pow_name);

    load(file_path, 'movie_EEG_TS');  % load EEG time series
    EEG_pow_region = struct();

    % Compute regional mean log power
    for e = 1:numel(emos)
        emo = emos{e};
        for f = 1:numel(bands)
            band = bands{f};
            for r = 1:numel(regions)
                region = regions{r};
                ch_idx = montage.(region);
                pow_data = movie_EEG_TS.(emo).(band)(ch_idx, 1:T_length);
                EEG_pow_region.(emo).(band).(region) = mean(log(pow_data), 1);
            end
        end
    end

    % Save result
    save_name = sprintf('ID %d Age %d EEG_pow.mat', id, age);
    save(fullfile(save_path, save_name), 'EEG_pow_region');
end

