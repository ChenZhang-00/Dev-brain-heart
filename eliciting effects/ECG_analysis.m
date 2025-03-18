
%% This script computes each child's cardiac activities (IBI, LF-HRV, and HF-HRV) 
% during movie viewing and outputs the results to movie_heart.csv.
% It also computes the average cardiac dynamics across all children and 
% outputs the results to movie_Heart_dynamics.csv.

% read in children's info
child_info = readtable("\child_info.csv");

% Get cardiac index(IBI, LF-HRV, and HF-HRV) of all children
ha_LF = []; ha_HF = [];
fe_LF = []; fe_HF = [];
ne_LF = []; ne_HF = [];
ha_IBI_4 = []; fe_IBI_4 = []; ne_IBI_4 = []; 
ha_IBI = []; fe_IBI = []; ne_IBI = []; 
id_list = [];

ECG_TS_path = '\brain-heart interplay\movie_ECG_TS';

for i = 1:length(child_info.ID)
    id = child_info.ID(i);
    age = child_info.Age_month(i);

    ECG_TS_name = [num2str(id) '_movie_ECG_TS.mat'];
    disp(['load ' ECG_TS_path '\' ECG_TS_name]);
    ECG_TS = load([ECG_TS_path '\' ECG_TS_name]);

    id_list = [id_list;id];
    % happy
    ha_IBI_4 = [ha_IBI_4;ECG_TS.happy_RR_res{1,1}(1:704)];
    ha_IBI = [ha_IBI;mean(ECG_TS.happy_RR)];
    ha_HF = [ha_HF;ECG_TS.happy_hf(1:176)];
    ha_LF = [ha_LF;ECG_TS.happy_lf(1:176)];
    % fearful
    fe_HF = [fe_HF;ECG_TS.fear_hf(1:176)];
    fe_LF = [fe_LF;ECG_TS.fear_lf(1:176)];
    fe_IBI_4 = [fe_IBI_4;ECG_TS.fear_RR_res{1,1}(1:704)];
    fe_IBI = [fe_IBI;mean(ECG_TS.fear_RR)];
    % neutral
    ne_LF = [ne_LF;ECG_TS.neutral_lf(1:176)];
    ne_HF = [ne_HF;ECG_TS.neutral_hf(1:176)];
    ne_IBI_4 = [ne_IBI_4;ECG_TS.neutral_RR_res{1,1}(1:704)];
    ne_IBI = [ne_IBI;mean(ECG_TS.neutral_RR)];
end

%% Calculate each child's cardiac activities
% - Average the time series along the time dimension
% - Apply log transformation for normal distribution
fe_HF_mi = log(mean(fe_HF,2)); fe_LF_mi = log(mean(fe_LF,2));
ha_HF_mi = log(mean(ha_HF,2)); ha_LF_mi = log(mean(ha_LF,2));
ne_HF_mi = log(mean(ne_HF,2)); ne_LF_mi = log(mean(ne_LF,2));
str_id = cellstr(num2str(id_list));
char_id = char(str_id);
movie_heart = table(char_id, fe_HF_mi, fe_LF_mi, ha_HF_mi,ha_LF_mi,ne_HF_mi,ne_LF_mi,fe_IBI, ha_IBI,ne_IBI, ...
    'VariableNames', {'ID', 'Fear_HF', 'Fear_LF','Happy_HF','Happy_LF', 'Neutral_HF','Neutral_LF', ...
    'Fear_IBI','Happy_IBI','Neutral_IBI'});
% write in
writetable(movie_heart, ['\eliciting effects\movie_heart.csv'],'Delimiter',',','QuoteStrings',true);

%% heart dynamics and temporal-cluster permutation test (Neutral vs. Fear, Neutral vs. Happy)
%% IBI series 
% get the mean IBI of Neutral for each child 
ne_IBI_m = mean(ne_IBI,2)*1000;
ne_IBI_mTS = repmat(ne_IBI_m, 1, 704);
IBI_time = 1:1:length(ne_IBI_mTS);

ne_IBI_TS = {};
ne_IBI_TS.time = repmat({IBI_time}, 1, length(ne_IBI_m));
for i = 1:size(ne_IBI_mTS, 1)
    ne_IBI_TS.trial{i} = ne_IBI_mTS(i, :);
end

fe_IBI_TS = {};
fe_IBI_TS.time = repmat({IBI_time}, 1, length(ne_IBI_m));
for i = 1:size(ne_IBI_mTS, 1)
    fe_IBI_TS.trial{i} = fe_IBI_4(i, :);
end

ha_IBI_TS = {};
ha_IBI_TS.time = repmat({IBI_time}, 1, length(ne_IBI_m));
for i = 1:size(ne_IBI_mTS, 1)
    ha_IBI_TS.trial{i} = ha_IBI_4(i, :);
end

FE_NE.IBI = cellfun(@(x, y) x - y, fe_IBI_TS.trial, ne_IBI_TS.trial, 'UniformOutput', false);
FN_mean = mean(cat(1, FE_NE.IBI{:}),1);
HA_NE.IBI = cellfun(@(x, y) x - y, ha_IBI_TS.trial, ne_IBI_TS.trial, 'UniformOutput', false);
HN_mean = mean(cat(1, HA_NE.IBI{:}),1);

% cluster-based permutation and for ref. https://github.com/diegocandiar/eeg_cluster_wilcoxon
addpath("\toolbox\Temporal_Cluster_Permutation");
cfg = [];
cfg.mint = 20; % minimum temporal cluster, 5s
cfg.statistic = 'dep_param'; 
cfg.alpha = 0.05; % alpha level of the permutation test
cfg.tail = 0; 
cfg.numrandomization = 10000;

% fear vs neutral IBI
stat = ft_statfun_temp_cluster(cfg, fe_IBI_TS, ne_IBI_TS) ; 
if ~isempty(stat.posclusters)    
    pos = stat.posclusterslabelmat ~= 0; 
else
    pos = false(1,length(stat.time));
end

if ~isempty(stat.negclusters)     
    neg = stat.negclusterslabelmat ~= 0;
else
    neg = false(1,length(stat.time));
end

% plot fe_IBI_4 and ne_IBI_mTS
time = 0:1:(length(ne_IBI_mTS)-1);
figure('Position', [100, 100, 2000, 400]);
FearColor = '#1172BF';
plot(time/4, FN_mean, 'Color', FearColor, 'LineWidth', 4); hold on; 
xlabel('Time');
ylabel('ΔIBI/ms');
line(xlim, [0 0], 'Color', [0.5,0.5,0.5]);
set(gca, 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1);
set(gca, 'XAxisLocation', 'bottom', 'YAxisLocation', 'left', 'TickLength', [0.01 0.01]);
% mark significant time intervals
ranges = {neg, pos};  
for i = 1:length(ranges)
    range = ranges{i};
    if any(range)  
        indices = find(range);  
        color_index = sscanf('#1172BF', '#%2x%2x%2x', [1 3]) / 255;
        for j = 1:length(indices)
            index = indices(j);
            rectangle('Position', [time(index)/4 - 0.125, min(ylim(gca)), 0.25, diff(ylim(gca))], ...
                'FaceColor', [color_index,0.3], 'EdgeColor', 'none');
        end
    end
end

fig_folder = '\eliciting effects\fig'; 
Fe_IBI_dym = fullfile(fig_folder, 'Fe_IBI_dyn.png');  % Save as PNG
print(gcf, Fe_IBI_dym, '-dpng', '-r1200');  


% happy vs neutral IBI
stat = ft_statfun_temp_cluster(cfg, ha_IBI_TS, ne_IBI_TS) ; 
if ~isempty(stat.posclusters)    
    pos = stat.posclusterslabelmat ~= 0; 
else
    pos = false(1,length(stat.time));
end

if ~isempty(stat.negclusters)     
    neg = stat.negclusterslabelmat ~= 0;
else
    neg = false(1,length(stat.time));
end
% plot ha_IBI_4 and ne_IBI_mTS
time = 0:1:(length(ne_IBI_mTS)-1);
figure('Position', [100, 100, 2000, 400]);
HappyColor = '#C60700';
plot(time/4, HN_mean, 'Color', HappyColor, 'LineWidth', 4); hold on; 
xlabel('Time');
ylabel('ΔIBI/ms');
line(xlim, [0 0], 'Color', [0.5,0.5,0.5]);
set(gca, 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1);
set(gca, 'XAxisLocation', 'bottom', 'YAxisLocation', 'left', 'TickLength', [0.01 0.01]);
% mark significant time intervals
ranges = {neg, pos}; 
for i = 1:length(ranges)
    range = ranges{i};
    if any(range)  
        indices = find(range);  
        color_index = sscanf('#C60700', '#%2x%2x%2x', [1 3]) / 255;
        for j = 1:length(indices)
            index = indices(j);
            rectangle('Position', [time(index)/4 - 0.125, min(ylim(gca)), 0.25, diff(ylim(gca))], ...
                'FaceColor', [color_index,0.3], 'EdgeColor', 'none');
        end
    end
end

Ha_IBI_dym = fullfile(fig_folder, 'Ha_IBI_dyn.png');
print(gcf, Ha_IBI_dym, '-dpng', '-r1200');  

%% HF-HRV series 
% 176, 1Hz
% log and get the median HF of Neutral for each child 
ne_HF_mi = median(real(log(ne_HF)),2)
ne_HF_mTS = repmat(ne_HF_mi, 1, 176);
% prepare data
HF_time = 1:1:length(ne_HF_mTS);
ne_HF_TS = {};
ne_HF_TS.time = repmat({HF_time}, 1, length(ne_HF_mi));
for i = 1:size(ne_HF_mTS, 1)
    ne_HF_TS.trial{i} = ne_HF_mTS(i, :);
end
fe_HF_TS = {};
fe_HF_TS.time = repmat({HF_time}, 1, length(ne_HF_mi));
fe_HF_log = real(log(fe_HF));
for i = 1:size(ne_HF_mTS, 1)
    fe_HF_TS.trial{i} = fe_HF_log(i, :);
end
ha_HF_TS = {};
ha_HF_TS.time = repmat({HF_time}, 1, length(ne_HF_mi));
ha_HF_log = real(log(ha_HF));
for i = 1:size(ne_HF_mTS, 1)
    ha_HF_TS.trial{i} = ha_HF_log(i, :);
end

%% LF-HRV series 
% 176, 1Hz
% log and get the median LF of Neutral for each child 
ne_LF_mi = median(real(log(ne_LF)),2)
ne_LF_mTS = repmat(ne_LF_mi, 1, 176);
% prepare data
LF_time = 1:1:length(ne_LF_mTS);
ne_LF_TS = {};
ne_LF_TS.time = repmat({LF_time}, 1, length(ne_LF_mi));
for i = 1:size(ne_LF_mTS, 1)
    ne_LF_TS.trial{i} = ne_LF_mTS(i, :);
end
fe_LF_TS = {};
fe_LF_TS.time = repmat({LF_time}, 1, length(ne_LF_mi));
fe_LF_log = real(log(fe_LF));
for i = 1:size(ne_LF_mTS, 1)
    fe_LF_TS.trial{i} = fe_LF_log(i, :);
end
ha_LF_TS = {};
ha_LF_TS.time = repmat({LF_time}, 1, length(ne_LF_mi));
ha_LF_log = real(log(ha_LF));
for i = 1:size(ne_LF_mTS, 1)
    ha_LF_TS.trial{i} = ha_LF_log(i, :);
end

%% save the average cardiac dynamics  substracting neutral
FE_NE.HF = cellfun(@(x, y) x - y, fe_HF_TS.trial, ne_HF_TS.trial, 'UniformOutput', false);
FN_mean_HF = mean(cat(1, FE_NE.HF{:}),1);
HA_NE.HF = cellfun(@(x, y) x - y, ha_HF_TS.trial, ne_HF_TS.trial, 'UniformOutput', false);
HN_mean_HF = mean(cat(1, HA_NE.HF{:}),1);

FE_NE.LF = cellfun(@(x, y) x - y, fe_LF_TS.trial, ne_LF_TS.trial, 'UniformOutput', false);
FE_NE_LF_matrix = cat(1, FE_NE.LF{:});
FE_NE_LF_matrix(FE_NE_LF_matrix == -Inf) = NaN;
FN_mean_LF = mean(FE_NE_LF_matrix, 1, 'omitnan');

HA_NE.LF = cellfun(@(x, y) x - y, ha_LF_TS.trial, ne_LF_TS.trial, 'UniformOutput', false);
HA_NE_LF_matrix = cat(1, HA_NE.LF{:});
HA_NE_LF_matrix(HA_NE_LF_matrix == -Inf) = NaN;
HN_mean_LF = mean(HA_NE_LF_matrix, 1, 'omitnan');

IBI_Fe_Ne_dym = mean(reshape(FN_mean, 4, []), 1);
IBI_Ha_Ne_dym = mean(reshape(HN_mean, 4, []), 1);

Time = (1:176)';
movie_Heart_dym = table(Time, IBI_Fe_Ne_dym', IBI_Ha_Ne_dym', FN_mean_HF', HN_mean_HF', FN_mean_LF', HN_mean_LF',...
    'VariableNames', {'Time', 'Fear_IBI', 'Happy_IBI','Fear_HF','Happy_HF','Fear_LF','Happy_LF'});
writetable(movie_Heart_dym,'\eliciting effects\movie_Heart_dym.csv','Delimiter',',','QuoteStrings',true);
