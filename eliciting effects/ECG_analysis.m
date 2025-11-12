% ---------------------------------------------------------------
% Compute Cardiac indexes (IBI, LF-HRV, HF-HRV) During Movie Viewing
% ---------------------------------------------------------------
% 1. Loads each child's ECG time-series data.
% 2. Computes individual and group-level cardiac metrics (IBI, LF, HF).
% 3. Performs temporal-cluster permutation tests (Neutral vs. Fear/Happy).
% 4. Saves summary results and figures.
% ---------------------------------------------------------------

%% Load child info
child_info = readtable('\all_children_info.csv');

ha_LF = []; ha_HF = [];
fe_LF = []; fe_HF = [];
ne_LF = []; ne_HF = [];
ha_IBI_4 = []; fe_IBI_4 = []; ne_IBI_4 = [];
ha_IBI = []; fe_IBI = []; ne_IBI = [];
id_list = [];

ECG_TS_path = '\movie_ECG_TS';

%% Extract cardiac features per child
for i = 1:length(child_info.ID)
    id = child_info.ID(i);
    age = child_info.Age_month(i);
    ECG_TS_name = sprintf('%d_movie_ECG_TS.mat', id);
    disp(['Loading ' ECG_TS_name '...']);

    ECG_TS = load(fullfile(ECG_TS_path, ECG_TS_name));
    id_list = [id_list; id];

    % happy
    ha_IBI_4 = [ha_IBI_4; ECG_TS.happy_RR_res{1,1}(1:704)];
    ha_IBI   = [ha_IBI; mean(ECG_TS.happy_RR)];
    ha_HF    = [ha_HF; ECG_TS.happy_hf(1:176)];
    ha_LF    = [ha_LF; ECG_TS.happy_lf(1:176)];
    % fearful
    fe_HF    = [fe_HF; ECG_TS.fear_hf(1:176)];
    fe_LF    = [fe_LF; ECG_TS.fear_lf(1:176)];
    fe_IBI_4 = [fe_IBI_4; ECG_TS.fear_RR_res{1,1}(1:704)];
    fe_IBI   = [fe_IBI; mean(ECG_TS.fear_RR)];
    % neutral
    ne_HF    = [ne_HF; ECG_TS.neutral_hf(1:176)];
    ne_LF    = [ne_LF; ECG_TS.neutral_lf(1:176)];
    ne_IBI_4 = [ne_IBI_4; ECG_TS.neutral_RR_res{1,1}(1:704)];
    ne_IBI   = [ne_IBI; mean(ECG_TS.neutral_RR)];
end

%% Compute per-child cardiac indices
fe_HF_mi = log(mean(fe_HF, 2)); fe_LF_mi = log(mean(fe_LF, 2));
ha_HF_mi = log(mean(ha_HF, 2)); ha_LF_mi = log(mean(ha_LF, 2));
ne_HF_mi = log(mean(ne_HF, 2)); ne_LF_mi = log(mean(ne_LF, 2));

movie_heart = table( ...
    cellstr(num2str(id_list)), fe_HF_mi, fe_LF_mi, ha_HF_mi, ha_LF_mi, ...
    ne_HF_mi, ne_LF_mi, fe_IBI, ha_IBI, ne_IBI, ...
    'VariableNames', {'ID','Fear_HF','Fear_LF','Happy_HF','Happy_LF', ...
                      'Neutral_HF','Neutral_LF','Fear_IBI','Happy_IBI','Neutral_IBI'} ...
);
writetable(movie_heart, '\eliciting effects\movie_heart.csv', 'Delimiter', ',', 'QuoteStrings', true);

%% Prepare IBI time series for temporal-cluster permutation
ne_IBI_m = mean(ne_IBI, 2) * 1000;
ne_IBI_mTS = repmat(ne_IBI_m, 1, 704);
IBI_time = 1:length(ne_IBI_mTS);

ne_IBI_TS = struct('time', {repmat({IBI_time}, 1, length(ne_IBI_m))}, ...
                   'trial', arrayfun(@(i) ne_IBI_mTS(i, :), 1:size(ne_IBI_mTS, 1), 'UniformOutput', false));
fe_IBI_TS = struct('time', ne_IBI_TS.time, ...
                   'trial', arrayfun(@(i) fe_IBI_4(i, :), 1:size(fe_IBI_4, 1), 'UniformOutput', false));
ha_IBI_TS = struct('time', ne_IBI_TS.time, ...
                   'trial', arrayfun(@(i) ha_IBI_4(i, :), 1:size(ha_IBI_4, 1), 'UniformOutput', false));

%% Compute group-level mean ΔIBI series
FE_NE.IBI = cellfun(@(x, y) x - y, fe_IBI_TS.trial, ne_IBI_TS.trial, 'UniformOutput', false);
FN_mean = mean(cat(1, FE_NE.IBI{:}), 1);
HA_NE.IBI = cellfun(@(x, y) x - y, ha_IBI_TS.trial, ne_IBI_TS.trial, 'UniformOutput', false);
HN_mean = mean(cat(1, HA_NE.IBI{:}), 1);

%% Temporal-cluster permutation test setup
addpath('\toolbox\Temporal_Cluster_Permutation');
cfg = struct('mint', 20, 'statistic', 'dep_param', 'alpha', 0.05, 'tail', 0, 'numrandomization', 10000);

%% Fear vs. Neutral IBI
stat = ft_statfun_temp_cluster(cfg, fe_IBI_TS, ne_IBI_TS);
[pos, neg] = deal(false(1, length(stat.time)));
if ~isempty(stat.posclusters), pos = stat.posclusterslabelmat ~= 0; end
if ~isempty(stat.negclusters), neg = stat.negclusterslabelmat ~= 0; end

% Plot
time = 0:(length(ne_IBI_mTS)-1);
figure('Position', [100, 100, 2000, 400]);
FearColor = '#1172BF';
plot(time/4, FN_mean, 'Color', FearColor, 'LineWidth', 4); hold on;
xlabel('Time'); ylabel('\DeltaIBI (ms)');
line(xlim, [0 0], 'Color', [0.5 0.5 0.5]);
set(gca, 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1);
% Highlight significant intervals
ranges = {neg, pos};
for i = 1:length(ranges)
    idx = find(ranges{i});
    if ~isempty(idx)
        c = sscanf(FearColor, '#%2x%2x%2x', [1 3]) / 255;
        for j = idx
            rectangle('Position', [time(j)/4 - 0.125, min(ylim), 0.25, diff(ylim)], ...
                      'FaceColor', [c, 0.3], 'EdgeColor', 'none');
        end
    end
end
print(gcf, '\eliciting effects\fig\Fe_IBI_dyn.png', '-dpng', '-r1200');

%% Happy vs. Neutral IBI
stat = ft_statfun_temp_cluster(cfg, ha_IBI_TS, ne_IBI_TS);
[pos, neg] = deal(false(1, length(stat.time)));
if ~isempty(stat.posclusters), pos = stat.posclusterslabelmat ~= 0; end
if ~isempty(stat.negclusters), neg = stat.negclusterslabelmat ~= 0; end

time = 0:(length(ne_IBI_mTS)-1);
figure('Position', [100, 100, 2000, 400]);
HappyColor = '#C60700';
plot(time/4, HN_mean, 'Color', HappyColor, 'LineWidth', 4); hold on;
xlabel('Time'); ylabel('\DeltaIBI (ms)');
line(xlim, [0 0], 'Color', [0.5 0.5 0.5]);
set(gca, 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1);
ranges = {neg, pos};
for i = 1:length(ranges)
    idx = find(ranges{i});
    if ~isempty(idx)
        c = sscanf(HappyColor, '#%2x%2x%2x', [1 3]) / 255;
        for j = idx
            rectangle('Position', [time(j)/4 - 0.125, min(ylim), 0.25, diff(ylim)], ...
                      'FaceColor', [c, 0.3], 'EdgeColor', 'none');
        end
    end
end
print(gcf, '\eliciting effects\fig\Ha_IBI_dyn.png', '-dpng', '-r1200');

%% Compute and save group-level HF/LF differences (vs. neutral)
ne_HF_mi = median(real(log(ne_HF)), 2);
ne_LF_mi = median(real(log(ne_LF)), 2);
ne_HF_mTS = repmat(ne_HF_mi, 1, 176);
ne_LF_mTS = repmat(ne_LF_mi, 1, 176);

HF_time = 1:length(ne_HF_mTS);
LF_time = 1:length(ne_LF_mTS);

ne_HF_TS = struct('trial', arrayfun(@(i) ne_HF_mTS(i, :), 1:size(ne_HF_mTS, 1), 'UniformOutput', false));
ne_LF_TS = struct('trial', arrayfun(@(i) ne_LF_mTS(i, :), 1:size(ne_LF_mTS, 1), 'UniformOutput', false));

fe_HF_log = real(log(fe_HF));
ha_HF_log = real(log(ha_HF));
fe_LF_log = real(log(fe_LF));
ha_LF_log = real(log(ha_LF));

FE_NE.HF = cellfun(@(x, y) x - y, num2cell(fe_HF_log, 2), ne_HF_TS.trial, 'UniformOutput', false);
HA_NE.HF = cellfun(@(x, y) x - y, num2cell(ha_HF_log, 2), ne_HF_TS.trial, 'UniformOutput', false);
FE_NE.LF = cellfun(@(x, y) x - y, num2cell(fe_LF_log, 2), ne_LF_TS.trial, 'UniformOutput', false);
HA_NE.LF = cellfun(@(x, y) x - y, num2cell(ha_LF_log, 2), ne_LF_TS.trial, 'UniformOutput', false);

FN_mean_HF = mean(cat(1, FE_NE.HF{:}), 1);
HN_mean_HF = mean(cat(1, HA_NE.HF{:}), 1);
FN_mean_LF = mean(cat(1, FE_NE.LF{:}), 1, 'omitnan');
HN_mean_LF = mean(cat(1, HA_NE.LF{:}), 1, 'omitnan');

IBI_Fe_Ne_dym = mean(reshape(FN_mean, 4, []), 1);
IBI_Ha_Ne_dym = mean(reshape(HN_mean, 4, []), 1);

Time = (1:176)';
movie_Heart_dym = table(Time, ...
    IBI_Fe_Ne_dym', IBI_Ha_Ne_dym', FN_mean_HF', HN_mean_HF', FN_mean_LF', HN_mean_LF', ...
    'VariableNames', {'Time','Fear_IBI','Happy_IBI','Fear_HF','Happy_HF','Fear_LF','Happy_LF'});
writetable(movie_Heart_dym, '\eliciting effects\movie_Heart_dym.csv', 'Delimiter', ',', 'QuoteStrings', true);

