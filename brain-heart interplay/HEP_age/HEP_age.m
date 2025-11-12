% ---------------------------------------------------------------
% Heart-Evoked Potential (HEP) by Age Group  
% ---------------------------------------------------------------
% 1. Loads EEG datasets and groups children by age.
% 2. Extracts time-domain HEPs (Fear, Happy, Neutral) per subject.
% 3. Computes group-level averages for Frontal, Central, Posterior regions.
% 4. Performs cluster-based permutation tests (Fear/Happy vs Neutral).
% 5. Plots group-level HEP waveforms with significance highlights.
% ---------------------------------------------------------------

%% === Basic Setup ===
clear; clc;
addpath(genpath('/toolbox/fieldtrip-master'));
addpath("/toolbox/Temporal_Cluster_Permutation");
ft_defaults;

% Load subject info and assign to age groups
child_info = readtable("/all_children_info.csv");
assign_age_group = @(age_month) ...
    categorical( ...
        (age_month >= 60 & age_month <= 83) * 1 + ...
        (age_month >= 84 & age_month <= 107) * 2 + ...
        (age_month >= 108 & age_month <= 131) * 3, ...
        1:3, {'G1 (5-6y)','G2 (7-8y)','G3 (9-10y)'} ...
    );
child_info.Age_group = assign_age_group(child_info.Age_month);

% Paths
filepath = '/HEP_Seg';
savepath = fullfile(filepath, 'group_HEP');
if ~exist(savepath, 'dir'), mkdir(savepath); end

% Channel groups
Frontal   = [1,32,33,34,35,62,63,5,4,37,3,36,2,61,31,60,30,29];
Central   = [38,6,39,7,27,58,28,59,9,41,8,40,26,57,25,56,24,42,10,43,11,53,22,54,23,55];
Posterior = [15,14,45,13,44,12,52,21,51,20,19,46,47,48,49,50,16,17,18];
Montage   = {'Frontal','Central','Posterior'};
T_length  = 400;  % sampling points


%% === Step 1: Compute and Save Group-Level HEP Data ===
age_groups = categories(child_info.Age_group);

for g = 1:numel(age_groups)
    group_name = age_groups{g};
    fprintf('\nProcessing age group: %s\n', group_name);
    group_ids = child_info.ID(child_info.Age_group == group_name);

    % Initialize structure for storing subject-level HEPs
    HEP.High_Fear  = struct();
    HEP.High_Happy = struct();
    HEP.Neutral    = struct();

    for subj = 1:numel(group_ids)
        id = group_ids(subj);
        set_name = sprintf('movie %d HEP_seg.set', id);
        set_path = fullfile(filepath, set_name);
        if ~isfile(set_path)
            fprintf('Missing file for ID %d\n', id);
            continue;
        end

        % Load and convert EEGLAB -> FieldTrip
        HEPi = pop_loadset('filename', set_name, 'filepath', filepath);
        ft_HEPi = eeglab2fieldtrip(HEPi, 'raw', 'none');

        % Extract trials by emotion
        cfg = [];
        cfg.trials = find(strcmp(ft_HEPi.trialinfo.codelabel, 'High_fear_T'));
        HEPi_F = ft_timelockanalysis(cfg, ft_HEPi);
        cfg.trials = find(strcmp(ft_HEPi.trialinfo.codelabel, 'neutral_T'));
        HEPi_N = ft_timelockanalysis(cfg, ft_HEPi);
        cfg.trials = find(strcmp(ft_HEPi.trialinfo.codelabel, 'High_happy_T'));
        HEPi_H = ft_timelockanalysis(cfg, ft_HEPi);

        % Average across regional montages
        for m = 1:numel(Montage)
            switch Montage{m}
                case 'Frontal',   ch_idx = Frontal;
                case 'Central',   ch_idx = Central;
                case 'Posterior', ch_idx = Posterior;
            end
            HEP.High_Fear.(Montage{m}).trial{subj}  = mean(HEPi_F.avg(ch_idx,:),1);
            HEP.High_Fear.(Montage{m}).time{subj}   = 1:T_length;
            HEP.High_Happy.(Montage{m}).trial{subj} = mean(HEPi_H.avg(ch_idx,:),1);
            HEP.High_Happy.(Montage{m}).time{subj}  = 1:T_length;
            HEP.Neutral.(Montage{m}).trial{subj}    = mean(HEPi_N.avg(ch_idx,:),1);
            HEP.Neutral.(Montage{m}).time{subj}     = 1:T_length;
        end
    end

    % Save group HEP data
    save(fullfile(savepath, sprintf('HEP_%s.mat', group_name)), 'HEP');
end


%% === Step 2: Cluster-Based Permutation Tests and Visualization ===
colors = {'b','r','k'};  % Fear, Happy, Neutral
alphaValue = 0.8;
age_groups = {'G1 (5-6y)','G2 (7-8y)','G3 (9-10y)'};

for m = 1:numel(Montage)
    Montagei = Montage{m};
    fprintf('\nPlotting montage: %s\n', Montagei);

    % Determine y-axis range across groups
    all_vals = [];
    for g = 1:numel(age_groups)
        group_name = age_groups{g};
        load(fullfile(savepath, sprintf('HEP_%s.mat', group_name)), 'HEP');
        m_HEP.High_Fear  = mean(cat(1, HEP.High_Fear.(Montagei).trial{:}), 1);
        m_HEP.High_Happy = mean(cat(1, HEP.High_Happy.(Montagei).trial{:}), 1);
        m_HEP.Neutral    = mean(cat(1, HEP.Neutral.(Montagei).trial{:}), 1);
        all_vals = [all_vals, m_HEP.High_Fear, m_HEP.High_Happy, m_HEP.Neutral];
    end
    y_limits = [min(all_vals), max(all_vals)];
    y_margin = 0.1 * diff(y_limits);
    y_limits = [y_limits(1)-y_margin, y_limits(2)+y_margin];

    % Plot HEP per age group
    figure('Position',[100,100,1200,900],'Name',Montagei);
    for g = 1:numel(age_groups)
        group_name = age_groups{g};
        load(fullfile(savepath, sprintf('HEP_%s.mat', group_name)), 'HEP');

        % Cluster permutation
        cfg = struct('mint',10,'statistic','dep_param','alpha',0.05,'tail',0,'numrandomization',10000);
        HEP_stat.FvsN = ft_statfun_temp_cluster(cfg, HEP.High_Fear.(Montagei), HEP.Neutral.(Montagei));
        HEP_stat.HvsN = ft_statfun_temp_cluster(cfg, HEP.High_Happy.(Montagei), HEP.Neutral.(Montagei));

        % Compute mean traces
        m_HEP.High_Fear  = mean(cat(1, HEP.High_Fear.(Montagei).trial{:}), 1);
        m_HEP.High_Happy = mean(cat(1, HEP.High_Happy.(Montagei).trial{:}), 1);
        m_HEP.Neutral    = mean(cat(1, HEP.Neutral.(Montagei).trial{:}), 1);

        % Subplot per age group
        subplot(3,1,g); hold on;
        HEP_time = 0:(T_length*7/8-1);
        plot(HEP_time, m_HEP.High_Fear(1:(T_length*7/8)), 'Color', colors{1}, 'LineWidth', 2);
        plot(HEP_time, m_HEP.High_Happy(1:(T_length*7/8)), 'Color', colors{2}, 'LineWidth', 2);
        plot(HEP_time, m_HEP.Neutral(1:(T_length*7/8)), 'Color', colors{3}, 'LineWidth', 2);

        % Baseline and time zero lines
        xlim([0 HEP_time(end)]);
        ylim(y_limits);
        line(xlim, [0 0], 'Color', [0.5 0.5 0.5], 'LineWidth', 2, 'LineStyle', '--');
        line([100 100], y_limits, 'Color', [0.5 0.5 0.5], 'LineWidth', 2, 'LineStyle', '--');

        % Significance markers
        pos_FvsN = HEP_stat.FvsN.posclusterslabelmat ~= 0;
        neg_FvsN = HEP_stat.FvsN.negclusterslabelmat ~= 0;
        pos_HvsN = HEP_stat.HvsN.posclusterslabelmat ~= 0;
        neg_HvsN = HEP_stat.HvsN.negclusterslabelmat ~= 0;

        offset_FvsN = 0.05 * diff(y_limits);
        offset_HvsN = 0.1 * diff(y_limits);

        for idx = find(pos_FvsN | neg_FvsN)
            rectangle('Position',[HEP_time(idx)-0.5, y_limits(2)-offset_FvsN, 1, diff(y_limits)*0.04], ...
                      'FaceColor',[colors{1}, alphaValue],'EdgeColor','none');
        end
        for idx = find(pos_HvsN | neg_HvsN)
            rectangle('Position',[HEP_time(idx)-0.5, y_limits(2)-offset_HvsN, 1, diff(y_limits)*0.04], ...
                      'FaceColor',[colors{2}, alphaValue],'EdgeColor','none');
        end

        title(sprintf('%s - %s', group_name, Montagei));
        xticks([0 50 100 150 200 250 300 350]);
        xticklabels({'-200','-100','0','100','200','300','400','500'});
        set(gca,'LineWidth',2,'TickDir','out');
    end

    % Save figure
    outdir = '\HEP\fig';
    if ~exist(outdir,'dir'), mkdir(outdir); end
    saveas(gcf, fullfile(outdir, sprintf('%s_HEP.png', Montagei)));
end

