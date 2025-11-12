% ---------------------------------------------------------------
% EEG Frontal Power Dynamics (Fear/Happy vs Neutral)
% ---------------------------------------------------------------
% 1. Loads frontal EEG time-series data for all subjects.
% 2. Computes ΔPower (emotion − neutral) for delta, theta, alpha bands.
% 3. Performs one-sample temporal cluster permutation tests (vs 0).
% 4. Plots averaged dynamics and highlights significant clusters.
% ---------------------------------------------------------------

clear; clc;

% === Toolboxes ===
addpath('\toolbox\fieldtrip-master');
addpath('\toolbox\Temporal_Cluster_Permutation');

% === Parameters ===
bands = {'delta','theta','alpha'};
colors = {[0 0 1], [1 0 0], [0 0 0]};      % delta=blue, theta=red, alpha=black
T_length = 176;                            % 1 Hz
time = 1:T_length;
ylims = [-0.6 0.6]; rect_height = ylims(2)-0.05; decrease_per_band = 0.05;

% Cluster-permutation settings
cfg = struct('mint',5,'statistic','dep_param','alpha',0.05,...
             'tail',0,'numrandomization',10000);

% Output folder
fig_folder = '\fig';

% === Subjects & EEG data ===
child_info = readtable("\all_children_info.csv");
N = height(child_info);
Frontal = [1,32,33,34,35,62,63,5,4,37,3,36,2,61,31,60,30,29];
data_path = '\movie_EEG_TS';

FE = struct(); HA = struct(); NE = struct();
for b = 1:numel(bands)
    FE.(bands{b}) = cell(1,N); HA.(bands{b}) = cell(1,N); NE.(bands{b}) = cell(1,N);
end

% Load EEG power per subject and emotion
for i = 1:N
    id = child_info.ID(i); age = child_info.Age_month(i);
    f = fullfile(data_path, sprintf('ID %d Age %d EEG_pow TS.mat', id, age));
    S = load(f); 
    for b = 1:numel(bands)
        band = bands{b};
        FE.(band){i} = mean(log(S.movie_EEG_TS.fear.(band)(Frontal,1:T_length)),1);
        HA.(band){i} = mean(log(S.movie_EEG_TS.happy.(band)(Frontal,1:T_length)),1);
        NE.(band){i} = mean(log(S.movie_EEG_TS.neutral.(band)(Frontal,1:T_length)),1);
    end
end

% === Compute ΔPower (emotion − neutral median) ===
dFE = struct(); dHA = struct();
for b = 1:numel(bands)
    band = bands{b};
    for i = 1:N
        ne_med = median(NE.(band){i});
        dFE.(band){i} = FE.(band){i} - ne_med;
        dHA.(band){i} = HA.(band){i} - ne_med;
    end
end

% ---------------------------------------------------------------
% Fear vs Neutral (ΔPower)
% ---------------------------------------------------------------
figure('Position',[100 100 2000 420]); hold on;
legend_handles = gobjects(1,numel(bands));
for b = 1:numel(bands)
    band = bands{b}; col = colors{b}; dcell = dFE.(band);
    mean_diff = mean(cat(1,dcell{:}),1);
    legend_handles(b) = plot(time, mean_diff,'Color',col,'LineWidth',2.5);

    condFT = struct('trial',{dcell},'time',{repmat({time},size(dcell))});
    zero_cell = cellfun(@(x) zeros(1,size(x,2)),dcell,'UniformOutput',false);
    baseFT = struct('trial',{zero_cell},'time',{repmat({time},size(zero_cell))});
    result = ft_statfun_temp_cluster(cfg,condFT,baseFT);

    pos_mask = isfield(result,'posclusters') && ~isempty(result.posclusters) && result.posclusterslabelmat~=0;
    neg_mask = isfield(result,'negclusters') && ~isempty(result.negclusters) && result.negclusterslabelmat~=0;
    sig_mask = pos_mask | neg_mask;

    if any(sig_mask)
        ysig = rect_height - (b-1)*decrease_per_band;
        for k = find(sig_mask)
            line([time(k)-0.5,time(k)+0.5],[ysig ysig],'Color',col,'LineWidth',8);
        end
    end
end
title('Fear vs Neutral (Frontal EEG Power)');
xlabel('Time (s)'); ylabel('\DeltaPower (log, Frontal)');
xlim([1 T_length]); ylim(ylims);
yline(0,'--','Color',[0.5 0.5 0.5]);
set(gca,'Box','off','TickDir','out','LineWidth',1.4,'FontSize',12);
legend(legend_handles,bands,'Location','northeastoutside'); legend boxoff;
print(gcf, fullfile(fig_folder,'EEG_Frontal_Fear_DeltaThetaAlpha.png'),'-dpng','-r1200');

% ---------------------------------------------------------------
% Happy vs Neutral (ΔPower)
% ---------------------------------------------------------------
figure('Position',[100 100 2000 420]); hold on;
legend_handles = gobjects(1,numel(bands));
for b = 1:numel(bands)
    band = bands{b}; col = colors{b}; dcell = dHA.(band);
    mean_diff = mean(cat(1,dcell{:}),1);
    legend_handles(b) = plot(time, mean_diff,'Color',col,'LineWidth',2.5);

    condFT = struct('trial',{dcell},'time',{repmat({time},size(dcell))});
    zero_cell = cellfun(@(x) zeros(1,size(x,2)),dcell,'UniformOutput',false);
    baseFT = struct('trial',{zero_cell},'time',{repmat({time},size(zero_cell))});
    result = ft_statfun_temp_cluster(cfg,condFT,baseFT);

    pos_mask = isfield(result,'posclusters') && ~isempty(result.posclusters) && result.posclusterslabelmat~=0;
    neg_mask = isfield(result,'negclusters') && ~isempty(result.negclusters) && result.negclusterslabelmat~=0;
    sig_mask = pos_mask | neg_mask;

    if any(sig_mask)
        ysig = rect_height - (b-1)*decrease_per_band;
        for k = find(sig_mask)
            line([time(k)-0.5,time(k)+0.5],[ysig ysig],'Color',col,'LineWidth',8);
        end
    end
end
title('Happy vs Neutral (Frontal EEG Power)');
xlabel('Time (s)'); ylabel('\DeltaPower (log, Frontal)');
xlim([1 T_length]); ylim(ylims);
yline(0,'--','Color',[0.5 0.5 0.5]);
set(gca,'Box','off','TickDir','out','LineWidth',1.4,'FontSize',12);
legend(legend_handles,bands,'Location','northeastoutside'); legend boxoff;
print(gcf, fullfile(fig_folder,'EEG_Frontal_Happy_DeltaThetaAlpha.png'),'-dpng','-r1200');

