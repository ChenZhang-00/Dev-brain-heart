
%% This script compares HEP responses between fearful/happy and neutral movie viewing

% load toolbox required
addpath('/toolbox/fieldtrip-master');
addpath("/toolbox/Temporal_Cluster_Permutation");

% load in HEP data
filepath = '\brain-heart interplay\HEP\HEP_Seg';
setFiles = dir(fullfile(filepath, '*.set'));

% montage for frontal, central, posterior chs
Frontal = [1,32,33,34,35,62,63,5,4,37,3,36,2,61,31,60,30,29];
Central = [38,6,39,7,27,58,28,59,9,41,8,40,26,57,25,56,24,42,10,43,11,53,22,54,23,55];
Posterior = [15,14,45,13,44,12,52,21,51,20,19,46,47,48,49,50,16,17,18];
T_length = 400; % 400 samples, [-0.2, 0.6]s

result = [];
for i = 1:length(setFiles)
    HEPi = pop_loadset('filename', setFiles(i).name,'filepath', filepath); 
    ft_HEPi = eeglab2fieldtrip(HEPi, 'raw', 'none');

    cfg = [];
    cfg.trials = find(strcmp(ft_HEPi.trialinfo.codelabel, 'High_fear_T'));
    TEPi_F  = ft_timelockanalysis(cfg, ft_HEPi);
    cfg = [];
    cfg.trials = find(strcmp(ft_HEPi.trialinfo.codelabel, 'neutral_T'));
    TEPi_N = ft_timelockanalysis(cfg, ft_HEPi);
    cfg = [];    
    cfg.trials = find(strcmp(ft_HEPi.trialinfo.codelabel, 'High_happy_T'));
    TEPi_H = ft_timelockanalysis(cfg, ft_HEPi);

    TEP.High_Fear.Frontal.trial{i} = mean(TEPi_F.avg(Frontal,:),1);    
    TEP.High_Fear.Frontal.time{i} = 1:1:T_length;
    TEP.High_Happy.Frontal.trial{i} = mean(TEPi_H.avg(Frontal,:),1);
    TEP.High_Happy.Frontal.time{i} = 1:1:T_length;
    TEP.Neutral.Frontal.trial{i} = mean(TEPi_N.avg(Frontal,:),1);
    TEP.Neutral.Frontal.time{i} = 1:1:T_length;

    TEP.High_Fear.Central.trial{i} = mean(TEPi_F.avg(Central,:),1);
    TEP.High_Fear.Central.time{i} = 1:1:T_length;
    TEP.High_Happy.Central.trial{i} = mean(TEPi_H.avg(Central,:),1);
    TEP.High_Happy.Central.time{i} = 1:1:T_length;
    TEP.Neutral.Central.trial{i} = mean(TEPi_N.avg(Central,:),1);
    TEP.Neutral.Central.time{i} = 1:1:T_length;
    
    TEP.High_Fear.Posterior.trial{i} = mean(TEPi_F.avg(Posterior,:),1);
    TEP.High_Fear.Posterior.time{i} = 1:1:T_length;
    TEP.High_Happy.Posterior.trial{i} = mean(TEPi_H.avg(Posterior,:),1);
    TEP.High_Happy.Posterior.time{i} = 1:1:T_length;
    TEP.Neutral.Posterior.trial{i} = mean(TEPi_N.avg(Posterior,:),1);
    TEP.Neutral.Posterior.time{i} = 1:1:T_length;
    
    % extract HEP for each child
    ID = regexp(setFiles(i).name, '\d+', 'match')
    id = str2double(ID{1});
    % [0, 100]ms after T peak, 
    %  0-400 samples, [-200, 600]
    % [0, 100]ms correspond to [100, 150]samples
    iTEP_100_Fear_Ftl = mean(TEP.High_Fear.Frontal.trial{i}(101:150));
    iTEP_100_Happy_Ftl = mean(TEP.High_Happy.Frontal.trial{i}(101:150));
    iTEP_100_Neutral_Ftl = mean(TEP.Neutral.Frontal.trial{i}(101:150));
    iTEP_100_Fear_Ctl = mean(TEP.High_Fear.Central.trial{i}(101:150));
    iTEP_100_Happy_Ctl = mean(TEP.High_Happy.Central.trial{i}(101:150));
    iTEP_100_Neutral_Ctl = mean(TEP.Neutral.Central.trial{i}(101:150));
    iTEP_100_Fear_Ptr = mean(TEP.High_Fear.Posterior.trial{i}(101:150));
    iTEP_100_Happy_Ptr = mean(TEP.High_Happy.Posterior.trial{i}(101:150));
    iTEP_100_Neutral_Ptr = mean(TEP.Neutral.Posterior.trial{i}(101:150));
    result = [result; id, iTEP_100_Fear_Ftl, iTEP_100_Happy_Ftl, iTEP_100_Neutral_Ftl, ...
              iTEP_100_Fear_Ctl, iTEP_100_Happy_Ctl, iTEP_100_Neutral_Ctl, ...
              iTEP_100_Fear_Ptr, iTEP_100_Happy_Ptr, iTEP_100_Neutral_Ptr];
end

result_table = array2table(result, 'VariableNames', ...
    {'ID', 'TEP_100_Fear_Ftl', 'TEP_100_Happy_Ftl', 'TEP_100_Neutral_Ftl', ...
     'TEP_100_Fear_Ctl', 'TEP_100_Happy_Ctl', 'TEP_100_Neutral_Ctl', ...
     'TEP_100_Fear_Ptr', 'TEP_100_Happy_Ptr', 'TEP_100_Neutral_Ptr'});
writetable(result_table, '\brain-heart interplay\HEP\HEP_for_each.csv','QuoteStrings', true );

%% comparisons of HEP between fearful/happy and neutral
% cluster-based permutation 
cfg = [];
cfg.mint = 10; % minimum temporal cluster 20ms
cfg.statistic = 'dep_param'; 
cfg.alpha = 0.05; % alpha level of the permutation test
cfg.tail = 0; 
cfg.numrandomization = 10000;  

% Fear vs. Neutral
TEP_stat.FvsN.Frontal = ft_statfun_temp_cluster(cfg, TEP.High_Fear.Frontal, TEP.Neutral.Frontal);
TEP_stat.FvsN.Central = ft_statfun_temp_cluster(cfg, TEP.High_Fear.Central, TEP.Neutral.Central);
TEP_stat.FvsN.Posterior = ft_statfun_temp_cluster(cfg, TEP.High_Fear.Posterior, TEP.Neutral.Posterior);
% Happy vs. Neutral
TEP_stat.HvsN.Frontal = ft_statfun_temp_cluster(cfg, TEP.High_Happy.Frontal, TEP.Neutral.Frontal);
TEP_stat.HvsN.Central = ft_statfun_temp_cluster(cfg, TEP.High_Happy.Central, TEP.Neutral.Central);
TEP_stat.HvsN.Posterior = ft_statfun_temp_cluster(cfg, TEP.High_Happy.Posterior, TEP.Neutral.Posterior);

%% plot TEP
folder_fig = '\brain-heart interplay\HEP\fig'
Montage = {'Frontal', 'Central', 'Posterior'};  % Frontal, Central, Posterior
conditions = {'Fear', 'Happy', 'Neutral'};
colors = {'b', 'r', 'k'}; 
alphaValue = 0.8;  

for ii = 1:3
    Montagei = Montage{ii};
    figure('Position', [0, 0, 1000, 400]);
    hold on;
    
    time = 0:1:(T_length-1);

    m_TEP = [];
    m_TEP.High_Fear = mean(cat(1, TEP.High_Fear.(Montagei).trial{:}), 1);
    m_TEP.High_Happy = mean(cat(1, TEP.High_Happy.(Montagei).trial{:}), 1);
    m_TEP.Neutral = mean(cat(1, TEP.Neutral.(Montagei).trial{:}), 1);
    
    xlim([0 time(end)]);  
    line(xlim, [0 0], 'Color', [0.5, 0.5, 0.5], 'LineWidth', 4, 'LineStyle', '--');
    line([100 100], ylim, 'Color', [0.5, 0.5, 0.5], 'LineStyle', '--', 'LineWidth', 4);

    plot(time, m_TEP.High_Fear, 'Color', colors{1}, 'LineWidth', 4);
    plot(time, m_TEP.High_Happy, 'Color', colors{2}, 'LineWidth', 4);
    plot(time, m_TEP.Neutral, 'Color', colors{3}, 'LineWidth', 4);
    
    pos_FvsN = TEP_stat.FvsN.(Montagei).posclusterslabelmat ~= 0;
    neg_FvsN = TEP_stat.FvsN.(Montagei).negclusterslabelmat ~= 0;
    pos_HvsN = TEP_stat.HvsN.(Montagei).posclusterslabelmat ~= 0;
    neg_HvsN = TEP_stat.HvsN.(Montagei).negclusterslabelmat ~= 0;

    data = [m_TEP.High_Fear, m_TEP.High_Happy, m_TEP.Neutral];
    max_y = max(data(:));
    min_y = min(data(:));
    y_margin = 0.2 * (max_y - min_y);
    ylim([min_y - y_margin, max_y + y_margin]);

    y = ylim(gca);
    offset_FvsN = 0.05 * diff(y);  
    offset_HvsN = 0.1 * diff(y);   
    
    % mark significant temporal clusters between fear and neutral
    if any(pos_FvsN | neg_FvsN)
        indices = find(pos_FvsN | neg_FvsN);
        for idx = 1:length(indices)
            rectangle('Position', [time(indices(idx)) - 0.5, y(2) - offset_FvsN, 1, diff(y) * 0.04], ...
                      'FaceColor', [colors{1}, alphaValue], 'EdgeColor', 'none');
        end
    end
    
    % mark significant temporal clusters between happy and neutral
    if any(pos_HvsN | neg_HvsN)
        indices = find(pos_HvsN | neg_HvsN);
        for idx = 1:length(indices)
            rectangle('Position', [time(indices(idx)) - 0.5, y(2) - offset_HvsN, 1, diff(y) * 0.04], ...
                      'FaceColor', [colors{2}, alphaValue], 'EdgeColor', 'none');
        end
    end

    title([Montagei ' - TEP']);
    xticks([0 50 100 150 200 250 300 350 400]);  
    xticklabels({'-200', '-100', '0', '100', '200', '300', '400', '500', '600'}); 
    hold off;

    set(gca, 'LineWidth', 3);
    set(gca, 'TickDir', 'out');
    set(gcf, 'Position', [100, 100, 1200, 400]); 
    % filename = fullfile(folder_fig, strcat('TEP_', Montagei, '.png'));  
    % print(gcf, filename, '-dpng', '-r1200'); 
end
