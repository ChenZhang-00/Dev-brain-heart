
%% This script computes each child's EEG power timeseries 
% (delta, theta, alpha, beta, and gamma) across three EEG scalp regions
% (frontal, central, and posterior)
% during movie viewing and outputs the average across all children to movie_brain_dyn.csv.

% load toolbox required
addpath('\toolbox\fieldtrip-master');
addpath("\toolbox\Temporal_Cluster_Permutation");

%% load in all data
% read in children's info
child_info = readtable("\child_info.csv");

% read an exemplar to get channel info.
cfg = [];
cfg.dataset = '\sample_data\raw_eeg\230723030\230723030_movie.eeg';
exmp = ft_preprocessing(cfg); % chs are in exmp.label

% montage for frontal, central, posterior chs
Frontal = [1,32,33,34,35,62,63,5,4,37,3,36,2,61,31,60,30,29];
Central = [38,6,39,7,27,58,28,59,9,41,8,40,26,57,25,56,24,42,10,43,11,53,22,54,23,55];
Posterior = [15,14,45,13,44,12,52,21,51,20,19,46,47,48,49,50,16,17,18];

T_length = 176; % 176s

for i = 1:size(child_info,1)
    id = child_info.ID(i);
    age = child_info.Age_month(i);
    % read in data
    data_path = '\brain-heart interplay\movie_EEG_TS';
    pow_name = ['ID ' num2str(id) ' Age ' num2str(age) ' EEG_pow TS.mat'];
    load([data_path '\' pow_name]); % movie_EEG_TS
    
    HA.alpha.Frontal.trial{i} =  mean(log(movie_EEG_TS.happy.alpha(Frontal, 1:176)),1);
    HA.alpha.Central.trial{i} =  mean(log(movie_EEG_TS.happy.alpha(Central, 1:176)),1);
    HA.alpha.Posterior.trial{i} =  mean(log(movie_EEG_TS.happy.alpha(Posterior, 1:176)),1);
    HA.beta.Frontal.trial{i} =  mean(log(movie_EEG_TS.happy.beta(Frontal, 1:176)),1);
    HA.beta.Central.trial{i} =  mean(log(movie_EEG_TS.happy.beta(Central, 1:176)),1);
    HA.beta.Posterior.trial{i} =  mean(log(movie_EEG_TS.happy.beta(Posterior, 1:176)),1);
    HA.delta.Frontal.trial{i} =  mean(log(movie_EEG_TS.happy.delta(Frontal, 1:176)),1);
    HA.delta.Central.trial{i} =  mean(log(movie_EEG_TS.happy.delta(Central, 1:176)),1);
    HA.delta.Posterior.trial{i} =  mean(log(movie_EEG_TS.happy.delta(Posterior, 1:176)),1);
    HA.theta.Frontal.trial{i} =  mean(log(movie_EEG_TS.happy.theta(Frontal, 1:176)),1);
    HA.theta.Central.trial{i} =  mean(log(movie_EEG_TS.happy.theta(Central, 1:176)),1);
    HA.theta.Posterior.trial{i} =  mean(log(movie_EEG_TS.happy.theta(Posterior, 1:176)),1);
    HA.gamma.Frontal.trial{i} =  mean(log(movie_EEG_TS.happy.gamma(Frontal, 1:176)),1);
    HA.gamma.Central.trial{i} =  mean(log(movie_EEG_TS.happy.gamma(Central, 1:176)),1);
    HA.gamma.Posterior.trial{i} =  mean(log(movie_EEG_TS.happy.gamma(Posterior, 1:176)),1);

    FE.alpha.Frontal.trial{i} =  mean(log(movie_EEG_TS.fear.alpha(Frontal, 1:176)),1);
    FE.alpha.Central.trial{i} =  mean(log(movie_EEG_TS.fear.alpha(Central, 1:176)),1);
    FE.alpha.Posterior.trial{i} =  mean(log(movie_EEG_TS.fear.alpha(Posterior, 1:176)),1);
    FE.beta.Frontal.trial{i} =  mean(log(movie_EEG_TS.fear.beta(Frontal, 1:176)),1);
    FE.beta.Central.trial{i} =  mean(log(movie_EEG_TS.fear.beta(Central, 1:176)),1);
    FE.beta.Posterior.trial{i} =  mean(log(movie_EEG_TS.fear.beta(Posterior, 1:176)),1);
    FE.delta.Frontal.trial{i} =  mean(log(movie_EEG_TS.fear.delta(Frontal, 1:176)),1);
    FE.delta.Central.trial{i} =  mean(log(movie_EEG_TS.fear.delta(Central, 1:176)),1);
    FE.delta.Posterior.trial{i} =  mean(log(movie_EEG_TS.fear.delta(Posterior, 1:176)),1);
    FE.theta.Frontal.trial{i} =  mean(log(movie_EEG_TS.fear.theta(Frontal, 1:176)),1);
    FE.theta.Central.trial{i} =  mean(log(movie_EEG_TS.fear.theta(Central, 1:176)),1);
    FE.theta.Posterior.trial{i} =  mean(log(movie_EEG_TS.fear.theta(Posterior, 1:176)),1);
    FE.gamma.Frontal.trial{i} =  mean(log(movie_EEG_TS.fear.gamma(Frontal, 1:176)),1);
    FE.gamma.Central.trial{i} =  mean(log(movie_EEG_TS.fear.gamma(Central, 1:176)),1);
    FE.gamma.Posterior.trial{i} =  mean(log(movie_EEG_TS.fear.gamma(Posterior, 1:176)),1);

    NE.alpha.Frontal.trial{i} =  mean(log(movie_EEG_TS.neutral.alpha(Frontal, 1:176)),1);
    NE.alpha.Central.trial{i} =  mean(log(movie_EEG_TS.neutral.alpha(Central, 1:176)),1);
    NE.alpha.Posterior.trial{i} =  mean(log(movie_EEG_TS.neutral.alpha(Posterior, 1:176)),1);
    NE.beta.Frontal.trial{i} =  mean(log(movie_EEG_TS.neutral.beta(Frontal, 1:176)),1);
    NE.beta.Central.trial{i} =  mean(log(movie_EEG_TS.neutral.beta(Central, 1:176)),1);
    NE.beta.Posterior.trial{i} =  mean(log(movie_EEG_TS.neutral.beta(Posterior, 1:176)),1);
    NE.delta.Frontal.trial{i} =  mean(log(movie_EEG_TS.neutral.delta(Frontal, 1:176)),1);
    NE.delta.Central.trial{i} =  mean(log(movie_EEG_TS.neutral.delta(Central, 1:176)),1);
    NE.delta.Posterior.trial{i} =  mean(log(movie_EEG_TS.neutral.delta(Posterior, 1:176)),1);
    NE.theta.Frontal.trial{i} =  mean(log(movie_EEG_TS.neutral.theta(Frontal, 1:176)),1);
    NE.theta.Central.trial{i} =  mean(log(movie_EEG_TS.neutral.theta(Central, 1:176)),1);
    NE.theta.Posterior.trial{i} =  mean(log(movie_EEG_TS.neutral.theta(Posterior, 1:176)),1);
    NE.gamma.Frontal.trial{i} =  mean(log(movie_EEG_TS.neutral.gamma(Frontal, 1:176)),1);
    NE.gamma.Central.trial{i} =  mean(log(movie_EEG_TS.neutral.gamma(Central, 1:176)),1);
    NE.gamma.Posterior.trial{i} =  mean(log(movie_EEG_TS.neutral.gamma(Posterior, 1:176)),1);

    HA.alpha.Frontal.time{i} = 1:1:T_length;
    HA.alpha.Central.time{i} = 1:1:T_length;
    HA.alpha.Posterior.time{i} = 1:1:T_length;
    HA.beta.Frontal.time{i} = 1:1:T_length;
    HA.beta.Central.time{i} = 1:1:T_length;
    HA.beta.Posterior.time{i} = 1:1:T_length;
    HA.delta.Frontal.time{i} = 1:1:T_length;
    HA.delta.Central.time{i} = 1:1:T_length;
    HA.delta.Posterior.time{i} = 1:1:T_length;
    HA.theta.Frontal.time{i} = 1:1:T_length;
    HA.theta.Central.time{i} = 1:1:T_length;
    HA.theta.Posterior.time{i} = 1:1:T_length;
    HA.gamma.Frontal.time{i} = 1:1:T_length;
    HA.gamma.Central.time{i} = 1:1:T_length;
    HA.gamma.Posterior.time{i} = 1:1:T_length;
    
    FE.alpha.Frontal.time{i} = 1:1:T_length;
    FE.alpha.Central.time{i} = 1:1:T_length;
    FE.alpha.Posterior.time{i} = 1:1:T_length;
    FE.beta.Frontal.time{i} = 1:1:T_length;
    FE.beta.Central.time{i} = 1:1:T_length;
    FE.beta.Posterior.time{i} = 1:1:T_length;
    FE.delta.Frontal.time{i} = 1:1:T_length;
    FE.delta.Central.time{i} = 1:1:T_length;
    FE.delta.Posterior.time{i} = 1:1:T_length;
    FE.theta.Frontal.time{i} = 1:1:T_length;
    FE.theta.Central.time{i} = 1:1:T_length;
    FE.theta.Posterior.time{i} = 1:1:T_length;
    FE.gamma.Frontal.time{i} = 1:1:T_length;
    FE.gamma.Central.time{i} = 1:1:T_length;
    FE.gamma.Posterior.time{i} = 1:1:T_length;
    
    NE.alpha.Frontal.time{i} = 1:1:T_length;
    NE.alpha.Central.time{i} = 1:1:T_length;
    NE.alpha.Posterior.time{i} = 1:1:T_length;
    NE.beta.Frontal.time{i} = 1:1:T_length;
    NE.beta.Central.time{i} = 1:1:T_length;
    NE.beta.Posterior.time{i} = 1:1:T_length;
    NE.delta.Frontal.time{i} = 1:1:T_length;
    NE.delta.Central.time{i} = 1:1:T_length;
    NE.delta.Posterior.time{i} = 1:1:T_length;
    NE.theta.Frontal.time{i} = 1:1:T_length;
    NE.theta.Central.time{i} = 1:1:T_length;
    NE.theta.Posterior.time{i} = 1:1:T_length;
    NE.gamma.Frontal.time{i} = 1:1:T_length;
    NE.gamma.Central.time{i} = 1:1:T_length;
    NE.gamma.Posterior.time{i} = 1:1:T_length;
end

% get the median of Neutral for each child
NE_mean = [];
NE_mean.alpha.Frontal.trial = cellfun(@(x) repmat(mean(x), size(x)), NE.alpha.Frontal.trial, 'UniformOutput', false);
NE_mean.beta.Frontal.trial = cellfun(@(x) repmat(mean(x), size(x)), NE.beta.Frontal.trial, 'UniformOutput', false);
NE_mean.delta.Frontal.trial = cellfun(@(x) repmat(mean(x), size(x)), NE.delta.Frontal.trial, 'UniformOutput', false);
NE_mean.theta.Frontal.trial = cellfun(@(x) repmat(mean(x), size(x)), NE.theta.Frontal.trial, 'UniformOutput', false);
NE_mean.gamma.Frontal.trial = cellfun(@(x) repmat(mean(x), size(x)), NE.gamma.Frontal.trial, 'UniformOutput', false);

NE_mean.alpha.Central.trial = cellfun(@(x) repmat(mean(x), size(x)), NE.alpha.Central.trial, 'UniformOutput', false);
NE_mean.beta.Central.trial = cellfun(@(x) repmat(mean(x), size(x)), NE.beta.Central.trial, 'UniformOutput', false);
NE_mean.delta.Central.trial = cellfun(@(x) repmat(mean(x), size(x)), NE.delta.Central.trial, 'UniformOutput', false);
NE_mean.theta.Central.trial = cellfun(@(x) repmat(mean(x), size(x)), NE.theta.Central.trial, 'UniformOutput', false);
NE_mean.gamma.Central.trial = cellfun(@(x) repmat(mean(x), size(x)), NE.gamma.Central.trial, 'UniformOutput', false);

NE_mean.alpha.Posterior.trial = cellfun(@(x) repmat(mean(x), size(x)), NE.alpha.Posterior.trial, 'UniformOutput', false);
NE_mean.beta.Posterior.trial = cellfun(@(x) repmat(mean(x), size(x)), NE.beta.Posterior.trial, 'UniformOutput', false);
NE_mean.delta.Posterior.trial = cellfun(@(x) repmat(mean(x), size(x)), NE.delta.Posterior.trial, 'UniformOutput', false);
NE_mean.theta.Posterior.trial = cellfun(@(x) repmat(mean(x), size(x)), NE.theta.Posterior.trial, 'UniformOutput', false);
NE_mean.gamma.Posterior.trial = cellfun(@(x) repmat(mean(x), size(x)), NE.gamma.Posterior.trial, 'UniformOutput', false);

NE_mean.alpha.Frontal.time = NE.alpha.Frontal.time;
NE_mean.beta.Frontal.time = NE.beta.Frontal.time;
NE_mean.delta.Frontal.time = NE.delta.Frontal.time;
NE_mean.theta.Frontal.time = NE.theta.Frontal.time;
NE_mean.gamma.Frontal.time = NE.gamma.Frontal.time;

NE_mean.alpha.Central.time = NE.alpha.Central.time;
NE_mean.beta.Central.time = NE.beta.Central.time;
NE_mean.delta.Central.time = NE.delta.Central.time;
NE_mean.theta.Central.time = NE.theta.Central.time;
NE_mean.gamma.Central.time = NE.gamma.Central.time;

NE_mean.alpha.Posterior.time = NE.alpha.Posterior.time;
NE_mean.beta.Posterior.time = NE.beta.Posterior.time;
NE_mean.delta.Posterior.time = NE.delta.Posterior.time;
NE_mean.theta.Posterior.time = NE.theta.Posterior.time;
NE_mean.gamma.Posterior.time = NE.gamma.Posterior.time;

%% plot EEG alpha for visualization
% Configuration for cluster-based permutation test
cfg = [];
cfg.mint = 5; % minimum temporal cluster, 5s
cfg.statistic = 'dep_param'; 
cfg.alpha = 0.05; % alpha level of the permutation test
cfg.tail = 0; 
cfg.numrandomization = 10000;  

% Frequency bands and their corresponding data fields
freq_bands = {'delta', 'theta', 'alpha', 'beta', 'gamma'};
regions = {'Frontal', 'Central', 'Posterior'};
emotions = {'Fear', 'Happy'};
num_bands = length(freq_bands);
% Colors for different regions
color_map = containers.Map({'r', 'b', 'k'}, {[1 0 0], [0 0 1], [0 0 0]});  % Red, Blue, Black
region_colors = {'r', 'b', 'k'};  % Red for Frontal, Blue for Central, Black for Posterior
% Define the base height for significance rectangles and decrease value
rect_height = 0.5; % Base height
decrease_per_region = 0.05; % Amount to decrease per region
% Create a figure with a 2x5 grid of subplots
figure('Position', [100, 100, 2000, 800]);
num_regions = length(regions);
i = 3; %% only alpha band for visualization
band = freq_bands{i};
for j = 1:length(emotions)
    emotion = emotions{j};
    if strcmp(emotion, 'Fear')
        condition_data = FE;
    else
        condition_data = HA;
    end
    subplot(2, 1, j);
    hold on;
    % Initialize a variable to determine max value for dynamic rect_height
    max_data_value = -inf;
    legend_handles = [];
    for k = 1:num_regions
        region = regions{k};
        % Perform the statistical test for the current band and region
        result = ft_statfun_temp_cluster(cfg, condition_data.(band).(region), NE_mean.(band).(region));
        % Identify positive and negative clusters
        if ~isempty(result.posclusters)
            pos_clusters = result.posclusterslabelmat ~= 0; 
        else
            pos_clusters = false(1, length(result.time));
        end
        if ~isempty(result.negclusters)
            neg_clusters = result.negclusterslabelmat ~= 0;
        else
            neg_clusters = false(1, length(result.time));
        end
        % Calculate the mean difference for plotting
        diff_data = cellfun(@(x, y) x - y, condition_data.(band).(region).trial, NE_mean.(band).(region).trial, 'UniformOutput', false);
        mean_diff = mean(cat(1, diff_data{:}), 1);
        % Determine the maximum data value for dynamic rect_height
        max_data_value = max(max_data_value, max(mean_diff));
        % Plot the mean difference
        time = 1:1:176;
        rgb_color = color_map(region_colors{k});  % Get the RGB color for the current region
        h = plot(time, mean_diff, 'color', rgb_color, 'LineWidth', 2.5);
        legend_handles = [legend_handles, h];
        % Define a decreasing height for each region
        significance_height = rect_height - (k - 1) * decrease_per_region; % Decrease height per region
        % Mark significant time intervals
        ranges = {neg_clusters, pos_clusters};  
        for l = 1:length(ranges)
            range = ranges{l};
            if any(range)
                indices = find(range);
                for m = 1:length(indices)
                    index = indices(m);
                    % Plot the horizontal line
                    line([time(index) - 0.5, time(index) + 0.5], ...
                         [significance_height, significance_height], ...
                         'Color', [rgb_color, 0.7], 'LineWidth', 8); % Transparent line
                end
            end
        end
    end
    
    title([emotion, ' vs. Neutral']);
    xlim([1 180]);
    ylabel([band ' power']);
    line(xlim, [0 0], 'Color', [0.5,0.5,0.5]);
    % Remove top and right borders
    set(gca, 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1);
    % Optionally adjust axis line thickness and tick marks
    set(gca, 'XAxisLocation', 'bottom', 'YAxisLocation', 'left', 'TickLength', [0.01 0.01]);
    legend(legend_handles, {'Frontal', 'Central', 'Posterior'}, 'Location', 'northeastoutside');
end

fig_folder = '\eliciting effects\fig'; 
EEGa_dym = fullfile(fig_folder, 'EEGa_dym.png');  % Save as PNG
print(gcf, EEGa_dym, '-dpng', '-r1200');

%% save 
% alpha
FE_NE.alpha.Frontal.trial = cellfun(@(x, y) x - y, FE.alpha.Frontal.trial, NE_mean.alpha.Frontal.trial, 'UniformOutput', false);
FE_NE.alpha.Central.trial = cellfun(@(x, y) x - y, FE.alpha.Central.trial, NE_mean.alpha.Central.trial, 'UniformOutput', false);
FE_NE.alpha.Posterior.trial = cellfun(@(x, y) x - y, FE.alpha.Posterior.trial, NE_mean.alpha.Posterior.trial, 'UniformOutput', false);
FN_a_F_mean = mean(cat(1, FE_NE.alpha.Frontal.trial{:}),1);
FN_a_C_mean = mean(cat(1, FE_NE.alpha.Central.trial{:}),1);
FN_a_P_mean = mean(cat(1, FE_NE.alpha.Posterior.trial{:}),1);

N_a_F_mean = mean(cat(1, NE.alpha.Frontal.trial{:}),1);
N_a_C_mean = mean(cat(1, NE.alpha.Central.trial{:}),1);
N_a_P_mean = mean(cat(1, NE.alpha.Posterior.trial{:}),1);

HA_NE.alpha.Frontal.trial = cellfun(@(x, y) x - y, HA.alpha.Frontal.trial, NE_mean.alpha.Frontal.trial, 'UniformOutput', false);
HA_NE.alpha.Central.trial = cellfun(@(x, y) x - y, HA.alpha.Central.trial, NE_mean.alpha.Central.trial, 'UniformOutput', false);
HA_NE.alpha.Posterior.trial = cellfun(@(x, y) x - y, HA.alpha.Posterior.trial, NE_mean.alpha.Posterior.trial, 'UniformOutput', false);
HN_a_F_mean = mean(cat(1, HA_NE.alpha.Frontal.trial{:}),1);
HN_a_C_mean = mean(cat(1, HA_NE.alpha.Central.trial{:}),1);
HN_a_P_mean = mean(cat(1, HA_NE.alpha.Posterior.trial{:}),1);
% gamma
FE_NE.gamma.Frontal.trial = cellfun(@(x, y) x - y, FE.gamma.Frontal.trial, NE_mean.gamma.Frontal.trial, 'UniformOutput', false);
FE_NE.gamma.Central.trial = cellfun(@(x, y) x - y, FE.gamma.Central.trial, NE_mean.gamma.Central.trial, 'UniformOutput', false);
FE_NE.gamma.Posterior.trial = cellfun(@(x, y) x - y, FE.gamma.Posterior.trial, NE_mean.gamma.Posterior.trial, 'UniformOutput', false);
FN_g_F_mean = mean(cat(1, FE_NE.gamma.Frontal.trial{:}),1);
FN_g_C_mean = mean(cat(1, FE_NE.gamma.Central.trial{:}),1);
FN_g_P_mean = mean(cat(1, FE_NE.gamma.Posterior.trial{:}),1);

N_g_F_mean = mean(cat(1, NE.gamma.Frontal.trial{:}),1);
N_g_C_mean = mean(cat(1, NE.gamma.Central.trial{:}),1);
N_g_P_mean = mean(cat(1, NE.gamma.Posterior.trial{:}),1);

HA_NE.gamma.Frontal.trial = cellfun(@(x, y) x - y, HA.gamma.Frontal.trial, NE_mean.gamma.Frontal.trial, 'UniformOutput', false);
HA_NE.gamma.Central.trial = cellfun(@(x, y) x - y, HA.gamma.Central.trial, NE_mean.gamma.Central.trial, 'UniformOutput', false);
HA_NE.gamma.Posterior.trial = cellfun(@(x, y) x - y, HA.gamma.Posterior.trial, NE_mean.gamma.Posterior.trial, 'UniformOutput', false);
HN_g_F_mean = mean(cat(1, HA_NE.gamma.Frontal.trial{:}),1);
HN_g_C_mean = mean(cat(1, HA_NE.gamma.Central.trial{:}),1);
HN_g_P_mean = mean(cat(1, HA_NE.gamma.Posterior.trial{:}),1);

% Delta band
FE_NE.delta.Frontal.trial = cellfun(@(x, y) x - y, FE.delta.Frontal.trial, NE_mean.delta.Frontal.trial, 'UniformOutput', false);
FE_NE.delta.Central.trial = cellfun(@(x, y) x - y, FE.delta.Central.trial, NE_mean.delta.Central.trial, 'UniformOutput', false);
FE_NE.delta.Posterior.trial = cellfun(@(x, y) x - y, FE.delta.Posterior.trial, NE_mean.delta.Posterior.trial, 'UniformOutput', false);
FN_d_F_mean = mean(cat(1, FE_NE.delta.Frontal.trial{:}),1);
FN_d_C_mean = mean(cat(1, FE_NE.delta.Central.trial{:}),1);
FN_d_P_mean = mean(cat(1, FE_NE.delta.Posterior.trial{:}),1);

N_d_F_mean = mean(cat(1, NE.delta.Frontal.trial{:}),1);
N_d_C_mean = mean(cat(1, NE.delta.Central.trial{:}),1);
N_d_P_mean = mean(cat(1, NE.delta.Posterior.trial{:}),1);

HA_NE.delta.Frontal.trial = cellfun(@(x, y) x - y, HA.delta.Frontal.trial, NE_mean.delta.Frontal.trial, 'UniformOutput', false);
HA_NE.delta.Central.trial = cellfun(@(x, y) x - y, HA.delta.Central.trial, NE_mean.delta.Central.trial, 'UniformOutput', false);
HA_NE.delta.Posterior.trial = cellfun(@(x, y) x - y, HA.delta.Posterior.trial, NE_mean.delta.Posterior.trial, 'UniformOutput', false);
HN_d_F_mean = mean(cat(1, HA_NE.delta.Frontal.trial{:}),1);
HN_d_C_mean = mean(cat(1, HA_NE.delta.Central.trial{:}),1);
HN_d_P_mean = mean(cat(1, HA_NE.delta.Posterior.trial{:}),1);

% Theta band
FE_NE.theta.Frontal.trial = cellfun(@(x, y) x - y, FE.theta.Frontal.trial, NE_mean.theta.Frontal.trial, 'UniformOutput', false);
FE_NE.theta.Central.trial = cellfun(@(x, y) x - y, FE.theta.Central.trial, NE_mean.theta.Central.trial, 'UniformOutput', false);
FE_NE.theta.Posterior.trial = cellfun(@(x, y) x - y, FE.theta.Posterior.trial, NE_mean.theta.Posterior.trial, 'UniformOutput', false);
FN_t_F_mean = mean(cat(1, FE_NE.theta.Frontal.trial{:}),1);
FN_t_C_mean = mean(cat(1, FE_NE.theta.Central.trial{:}),1);
FN_t_P_mean = mean(cat(1, FE_NE.theta.Posterior.trial{:}),1);

N_t_F_mean = mean(cat(1, NE.theta.Frontal.trial{:}),1);
N_t_C_mean = mean(cat(1, NE.theta.Central.trial{:}),1);
N_t_P_mean = mean(cat(1, NE.theta.Posterior.trial{:}),1);

HA_NE.theta.Frontal.trial = cellfun(@(x, y) x - y, HA.theta.Frontal.trial, NE_mean.theta.Frontal.trial, 'UniformOutput', false);
HA_NE.theta.Central.trial = cellfun(@(x, y) x - y, HA.theta.Central.trial, NE_mean.theta.Central.trial, 'UniformOutput', false);
HA_NE.theta.Posterior.trial = cellfun(@(x, y) x - y, HA.theta.Posterior.trial, NE_mean.theta.Posterior.trial, 'UniformOutput', false);
HN_t_F_mean = mean(cat(1, HA_NE.theta.Frontal.trial{:}),1);
HN_t_C_mean = mean(cat(1, HA_NE.theta.Central.trial{:}),1);
HN_t_P_mean = mean(cat(1, HA_NE.theta.Posterior.trial{:}),1);

% Beta band
FE_NE.beta.Frontal.trial = cellfun(@(x, y) x - y, FE.beta.Frontal.trial, NE_mean.beta.Frontal.trial, 'UniformOutput', false);
FE_NE.beta.Central.trial = cellfun(@(x, y) x - y, FE.beta.Central.trial, NE_mean.beta.Central.trial, 'UniformOutput', false);
FE_NE.beta.Posterior.trial = cellfun(@(x, y) x - y, FE.beta.Posterior.trial, NE_mean.beta.Posterior.trial, 'UniformOutput', false);
FN_b_F_mean = mean(cat(1, FE_NE.beta.Frontal.trial{:}),1);
FN_b_C_mean = mean(cat(1, FE_NE.beta.Central.trial{:}),1);
FN_b_P_mean = mean(cat(1, FE_NE.beta.Posterior.trial{:}),1);

N_b_F_mean = mean(cat(1, NE.beta.Frontal.trial{:}),1);
N_b_C_mean = mean(cat(1, NE.beta.Central.trial{:}),1);
N_b_P_mean = mean(cat(1, NE.beta.Posterior.trial{:}),1);

HA_NE.beta.Frontal.trial = cellfun(@(x, y) x - y, HA.beta.Frontal.trial, NE_mean.beta.Frontal.trial, 'UniformOutput', false);
HA_NE.beta.Central.trial = cellfun(@(x, y) x - y, HA.beta.Central.trial, NE_mean.beta.Central.trial, 'UniformOutput', false);
HA_NE.beta.Posterior.trial = cellfun(@(x, y) x - y, HA.beta.Posterior.trial, NE_mean.beta.Posterior.trial, 'UniformOutput', false);
HN_b_F_mean = mean(cat(1, HA_NE.beta.Frontal.trial{:}),1);
HN_b_C_mean = mean(cat(1, HA_NE.beta.Central.trial{:}),1);
HN_b_P_mean = mean(cat(1, HA_NE.beta.Posterior.trial{:}),1);

% Create the table
Time = (1:176)';
movie_eeg_dyn_ave = table(Time, FN_a_F_mean', FN_a_C_mean', FN_a_P_mean', HN_a_F_mean', HN_a_C_mean', HN_a_P_mean', ...
    N_a_F_mean', N_a_C_mean', N_a_P_mean', FN_g_F_mean', FN_g_C_mean', FN_g_P_mean', HN_g_F_mean', HN_g_C_mean', HN_g_P_mean',...
    N_g_F_mean', N_g_C_mean', N_g_P_mean', FN_d_F_mean', FN_d_C_mean', FN_d_P_mean', HN_d_F_mean', HN_d_C_mean', HN_d_P_mean', ...
    N_d_F_mean', N_d_C_mean', N_d_P_mean', FN_t_F_mean', FN_t_C_mean', FN_t_P_mean', HN_t_F_mean', HN_t_C_mean', HN_t_P_mean', ...
    N_t_F_mean', N_t_C_mean', N_t_P_mean', FN_b_F_mean', FN_b_C_mean', FN_b_P_mean', HN_b_F_mean', HN_b_C_mean', HN_b_P_mean', ...
    N_b_F_mean', N_b_C_mean', N_b_P_mean',...
    'VariableNames', {'Time','Fear_Falpha', 'Fear_Calpha', 'Fear_Palpha', ...
    'Happy_Falpha', 'Happy_Calpha', 'Happy_Palpha', ...
    'Neutral_Falpha', 'Neutral_Calpha', 'Neutral_Palpha', ...
    'Fear_Fgamma', 'Fear_Cgamma', 'Fear_Pgamma', ...
    'Happy_Fgamma', 'Happy_Cgamma', 'Happy_Pgamma', ...
    'Neutral_Fgamma', 'Neutral_Cgamma', 'Neutral_Pgamma', ...
    'Fear_Fdelta', 'Fear_Cdelta', 'Fear_Pdelta', ...
    'Happy_Fdelta', 'Happy_Cdelta', 'Happy_Pdelta', ...
    'Neutral_Fdelta', 'Neutral_Cdelta', 'Neutral_Pdelta', ...
    'Fear_Ftheta', 'Fear_Ctheta', 'Fear_Ptheta', ...
    'Happy_Ftheta', 'Happy_Ctheta', 'Happy_Ptheta', ...
    'Neutral_Ftheta', 'Neutral_Ctheta', 'Neutral_Ptheta', ...
    'Fear_Fbeta', 'Fear_Cbeta', 'Fear_Pbeta', ...
    'Happy_Fbeta', 'Happy_Cbeta', 'Happy_Pbeta', ...
    'Neutral_Fbeta', 'Neutral_Cbeta', 'Neutral_Pbeta'});
% Write to CSV
writetable(movie_eeg_dyn_ave,'\eliciting effects\movie_brain_dyn.csv','Delimiter',',','QuoteStrings',true);