
%% This script compares the directional brain-heart interplay  
% between fearful, happy, and neutral states and visualizes the results.

% load toolbox required
addpath("\toolbox\Temporal_Cluster_Permutation");

% read in children's info
child_info = readtable("\child_info.csv");
child_info(child_info.ID==231125091, :) = []; %% dBHI computation failed for this sample due to poor ECG data quality

dBHI_index = [
    "LF2a", "HF2a", "a2LF", "a2HF", ...
    "LF2b", "HF2b", "b2LF", "b2HF", ...
    "LF2d", "HF2d", "d2LF", "d2HF", ...
    "LF2g", "HF2g", "g2LF", "g2HF", ...
    "LF2t", "HF2t", "t2LF", "t2HF"
];% LF-HRV/HF-HRV and EEG delta/theta/alpha/beta/gamma power

dBHI_ne = []; dBHI_fe = []; dBHI_ha = []; % neutral/fearful/happy
for i = 1:size(child_info,1)
    id = child_info.ID(i);
    age = child_info.Age_month(i);

    for ii = 1:size(dBHI_index,2)
        dBHI_indexii = dBHI_index(ii);
        [dBHI_nei, dBHI_fei, dBHI_hai] = dBHI_FCP_movie(id,age);
        
        Tlength = length(dBHI_nei.Frontal.(dBHI_indexii));
        dBHI_ne.Frontal.(dBHI_indexii).trial{i} = dBHI_nei.Frontal.(dBHI_indexii); dBHI_ne.Frontal.(dBHI_indexii).time{i} = [1:1:Tlength];
        dBHI_fe.Frontal.(dBHI_indexii).trial{i} = dBHI_fei.Frontal.(dBHI_indexii); dBHI_fe.Frontal.(dBHI_indexii).time{i} = [1:1:Tlength];
        dBHI_ha.Frontal.(dBHI_indexii).trial{i} = dBHI_hai.Frontal.(dBHI_indexii); dBHI_ha.Frontal.(dBHI_indexii).time{i} = [1:1:Tlength];
        dBHI_ne.Central.(dBHI_indexii).trial{i} = dBHI_nei.Central.(dBHI_indexii); dBHI_ne.Central.(dBHI_indexii).time{i} = [1:1:Tlength];
        dBHI_fe.Central.(dBHI_indexii).trial{i} = dBHI_fei.Central.(dBHI_indexii); dBHI_fe.Central.(dBHI_indexii).time{i} = [1:1:Tlength];
        dBHI_ha.Central.(dBHI_indexii).trial{i} = dBHI_hai.Central.(dBHI_indexii); dBHI_ha.Central.(dBHI_indexii).time{i} = [1:1:Tlength];
        dBHI_ne.Posterior.(dBHI_indexii).trial{i} = dBHI_nei.Posterior.(dBHI_indexii); dBHI_ne.Posterior.(dBHI_indexii).time{i} = [1:1:Tlength];
        dBHI_fe.Posterior.(dBHI_indexii).trial{i} = dBHI_fei.Posterior.(dBHI_indexii); dBHI_fe.Posterior.(dBHI_indexii).time{i} = [1:1:Tlength];
        dBHI_ha.Posterior.(dBHI_indexii).trial{i} = dBHI_hai.Posterior.(dBHI_indexii); dBHI_ha.Posterior.(dBHI_indexii).time{i} = [1:1:Tlength];
        
        dBHI_ne.ID{i} = id; dBHI_fe.ID{i} = id; dBHI_ha.ID{i} = id; dBHI_zero.ID{i} = id; dBHI_zero.ID{i} = id; dBHI_mne.ID{i} = id; 
        
        dBHI_mne.Frontal.(dBHI_indexii).trial{i} = repmat(mean(dBHI_ne.Frontal.(dBHI_indexii).trial{i}),1,Tlength); dBHI_mne.Frontal.(dBHI_indexii).time{i} = [1:1:Tlength];
        dBHI_mne.Central.(dBHI_indexii).trial{i} = repmat(mean(dBHI_ne.Frontal.(dBHI_indexii).trial{i}),1,Tlength); dBHI_mne.Central.(dBHI_indexii).time{i} = [1:1:Tlength];
        dBHI_mne.Posterior.(dBHI_indexii).trial{i} = repmat(mean(dBHI_ne.Frontal.(dBHI_indexii).trial{i}),1,Tlength); dBHI_mne.Posterior.(dBHI_indexii).time{i} = [1:1:Tlength];
    end
end

%% Subtracting neutral
dBHI_Fe_Ne = []; dBHI_Ha_Ne = [];
dBHI_Fe_Ne.ID = dBHI_ne.ID; 
dBHI_Ha_Ne.ID = dBHI_ne.ID; 
for i = 1:size(dBHI_index,2)
    dBHI_indexi = dBHI_index(i);

    dBHI_Fe_Ne.Ftl.(dBHI_indexi) = cellfun(@(x, y) x - y, dBHI_fe.Frontal.(dBHI_indexi).trial, dBHI_mne.Frontal.(dBHI_indexi).trial, 'UniformOutput', false);
    dBHI_Ha_Ne.Ftl.(dBHI_indexi) = cellfun(@(x, y) x - y, dBHI_ha.Frontal.(dBHI_indexi).trial, dBHI_mne.Frontal.(dBHI_indexi).trial, 'UniformOutput', false);

    dBHI_Fe_Ne.Ctl.(dBHI_indexi) = cellfun(@(x, y) x - y, dBHI_fe.Central.(dBHI_indexi).trial, dBHI_mne.Central.(dBHI_indexi).trial, 'UniformOutput', false);
    dBHI_Ha_Ne.Ctl.(dBHI_indexi) = cellfun(@(x, y) x - y, dBHI_ha.Central.(dBHI_indexi).trial, dBHI_mne.Central.(dBHI_indexi).trial, 'UniformOutput', false);

    dBHI_Fe_Ne.Ptr.(dBHI_indexi) = cellfun(@(x, y) x - y, dBHI_fe.Posterior.(dBHI_indexi).trial, dBHI_mne.Posterior.(dBHI_indexi).trial, 'UniformOutput', false);
    dBHI_Ha_Ne.Ptr.(dBHI_indexi) = cellfun(@(x, y) x - y, dBHI_ha.Posterior.(dBHI_indexi).trial, dBHI_mne.Posterior.(dBHI_indexi).trial, 'UniformOutput', false);
end

save('\brain-heart interplay\dBHI\dBHI_for_each.mat', 'dBHI_fe', 'dBHI_ha', 'dBHI_ne', 'dBHI_Fe_Ne', 'dBHI_Ha_Ne');

%% cluster-based permutation 
cfg = [];
cfg.mint = 5; % minimum temporal cluster 5s
cfg.statistic = 'dep_param'; 
cfg.alpha = 0.05; % alpha level of the permutation test
cfg.tail = 0; 
cfg.numrandomization = 10000;  

mdBHI_diff = [];
for i = 1:size(dBHI_index,2)
    dBHI_indexi = dBHI_index(i);

    mdBHI_diff.Fe_Ne.Ftl.(dBHI_indexi) = median(cat(1, dBHI_Fe_Ne.Ftl.(dBHI_indexi){:}),1);
    mdBHI_diff.Ha_Ne.Ftl.(dBHI_indexi) = median(cat(1, dBHI_Ha_Ne.Ftl.(dBHI_indexi){:}),1);
    mdBHI_diff.Fe_Ne.Ctl.(dBHI_indexi) = median(cat(1, dBHI_Fe_Ne.Ctl.(dBHI_indexi){:}),1);
    mdBHI_diff.Ha_Ne.Ctl.(dBHI_indexi) = median(cat(1, dBHI_Ha_Ne.Ctl.(dBHI_indexi){:}),1);
    mdBHI_diff.Fe_Ne.Ptr.(dBHI_indexi) = median(cat(1, dBHI_Fe_Ne.Ptr.(dBHI_indexi){:}),1);
    mdBHI_diff.Ha_Ne.Ptr.(dBHI_indexi) = median(cat(1, dBHI_Ha_Ne.Ptr.(dBHI_indexi){:}),1);
   
    stat.Fear.Ftl.(dBHI_indexi) = ft_statfun_temp_cluster(cfg, dBHI_fe.Frontal.(dBHI_indexi), dBHI_mne.Frontal.(dBHI_indexi));
    stat.Fear.Ctl.(dBHI_indexi) = ft_statfun_temp_cluster(cfg, dBHI_fe.Central.(dBHI_indexi), dBHI_mne.Central.(dBHI_indexi)); 
    stat.Fear.Ptr.(dBHI_indexi) = ft_statfun_temp_cluster(cfg, dBHI_fe.Posterior.(dBHI_indexi), dBHI_mne.Posterior.(dBHI_indexi)); 
    stat.Happy.Ftl.(dBHI_indexi) = ft_statfun_temp_cluster(cfg, dBHI_ha.Frontal.(dBHI_indexi), dBHI_mne.Frontal.(dBHI_indexi));
    stat.Happy.Ctl.(dBHI_indexi) = ft_statfun_temp_cluster(cfg, dBHI_ha.Central.(dBHI_indexi), dBHI_mne.Central.(dBHI_indexi)); 
    stat.Happy.Ptr.(dBHI_indexi) = ft_statfun_temp_cluster(cfg, dBHI_ha.Posterior.(dBHI_indexi), dBHI_mne.Posterior.(dBHI_indexi)); 
end

%% plot
bands = ["delta", "theta", "alpha", "beta", "gamma"];
index_map = ["d", "t", "a", "b", "g"];
conditions = ["LF", "HF"]; % HRV
Montage = ["Ftl", "Ctl", "Ptr"];
folder_fig = '\brain-heart interplay\dBHI\fig';

%% only plot EEG alpha band
%% Fear
% from heart to brain
for i = 1:2
   condition = conditions(i);
   figure('Position', [0, 0, 1600, 200]);
   j = 3; %% EEG alhpa band
        band = bands(j);
        dBHI_indexi = condition + "2" + index_map(j); 
        hold on;

        T_length = length(stat.Fear.Ftl.(dBHI_indexi).time);
        time = 0:1:(T_length-1);

        pos = struct();
        neg = struct();
        for ii = 1:3
            Montagei = Montage(ii);
            
            % Fear
            if ~isempty(stat.Fear.(Montagei).(dBHI_indexi).posclusters)    
                pos.Fear.(Montagei).(dBHI_indexi) = stat.Fear.(Montagei).(dBHI_indexi).posclusterslabelmat ~= 0; 
            else
                pos.Fear.(Montagei).(dBHI_indexi) = false(1,length(stat.Fear.(Montagei).(dBHI_indexi).time));
            end

            if ~isempty(stat.Fear.(Montagei).(dBHI_indexi).negclusters)     
                neg.Fear.(Montagei).(dBHI_indexi) = stat.Fear.(Montagei).(dBHI_indexi).negclusterslabelmat ~= 0;
            else
                neg.Fear.(Montagei).(dBHI_indexi) = false(1,length(stat.Fear.(Montagei).(dBHI_indexi).time));
            end
        end

        plot(time, mdBHI_diff.Fe_Ne.Ftl.(dBHI_indexi), 'r', 'LineWidth', 3); 
        plot(time, mdBHI_diff.Fe_Ne.Ctl.(dBHI_indexi), 'b', 'LineWidth', 3); 
        plot(time, mdBHI_diff.Fe_Ne.Ptr.(dBHI_indexi), 'k', 'LineWidth', 3);

        data = [mdBHI_diff.Fe_Ne.Ftl.(dBHI_indexi), ...
                mdBHI_diff.Fe_Ne.Ctl.(dBHI_indexi), ...
                mdBHI_diff.Fe_Ne.Ptr.(dBHI_indexi)];
        
        max_y = max(data(:));  
        min_y = min(data(:));  
    
        y_margin = 0.4 * (max_y - min_y); 
        ylim([min_y - y_margin, max_y + y_margin]); 

        % title(condition + " - " + band);
        ylabel('A.U.'); % arbitrary units
        line(xlim, [0 0], 'Color', [0.5,0.5,0.5], 'LineWidth', 3, 'LineStyle', '--');
        if j == 5
            xticks(0:50:time(end));
        else
            xticks([]);  
        end
        xlim([0 time(end)]);

        set(gca, 'YTick', []); 
        yticks([0]); 
        yticklabels({'0'}); 

        colors = [1, 0, 0; 0, 0, 1; 0, 0, 0];  % r, b, k 
        alphaValue = 0.8;  
        y = ylim(gca);
        baseOffset = 0;
        offsetIncrement = 0.05;

        for k = 1:3
            Montage_k = Montage(k);
            significantPositions = (pos.Fear.(Montage_k).(dBHI_indexi)) | (neg.Fear.(Montage_k).(dBHI_indexi));  
            if any(significantPositions)  
                indices = find(significantPositions);  
                color = colors(k, :);  
                currentOffset = baseOffset - k * offsetIncrement * diff(y);
                for idx = 1:length(indices)
                    index = indices(idx);
                    rectangle('Position', [time(index) - 0.5, y(2) + currentOffset, 1, diff(y) * 0.04], ...
                              'FaceColor', [color, alphaValue], 'EdgeColor', 'none');
                end
            end
        end
        
        title(['Fear '+ dBHI_indexi]);  

        set(gca, 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1);
        set(gca, 'XAxisLocation', 'bottom', 'YAxisLocation', 'left', 'TickLength', [0.01 0.01]);

        hold off;
    
    
    legend_labels = {'Frontal', 'Central', 'Posterior'};
    hL = legend(legend_labels, 'Orientation', 'horizontal', 'Position', [0.5, 0.95, 0.1, 0.02]);
    set(hL, 'Units', 'normalized', 'Position', [0.5, 0.02, 0.1, 0.02]);

    set(gca, 'LineWidth', 3);  % 
    set(gcf, 'Position', [100, 100, 1500, 400]);  
    filename = fullfile(folder_fig, sprintf(['Fear '+ condition + ' to ' + band + '.png']));  
    print(gcf, filename, '-dpng', '-r1200');  
end

% from brain to heart
for i = 1:2
    condition = conditions(i);
    figure('Position', [0, 0, 1600, 200]);
    j = 3;
        band = bands(j);
        dBHI_indexi = index_map(j) + "2" + condition;
        hold on;

        T_length = length(stat.Fear.Ftl.(dBHI_indexi).time);
        time = 0:1:(T_length-1);

        pos = struct();
        neg = struct();
        for ii = 1:3
            Montagei = Montage(ii);
            
            if ~isempty(stat.Fear.(Montagei).(dBHI_indexi).posclusters)    
                pos.Fear.(Montagei).(dBHI_indexi) = stat.Fear.(Montagei).(dBHI_indexi).posclusterslabelmat ~= 0; 
            else
                pos.Fear.(Montagei).(dBHI_indexi) = false(1,length(stat.Fear.(Montagei).(dBHI_indexi).time));
            end

            if ~isempty(stat.Fear.(Montagei).(dBHI_indexi).negclusters)     
                neg.Fear.(Montagei).(dBHI_indexi) = stat.Fear.(Montagei).(dBHI_indexi).negclusterslabelmat ~= 0;
            else
                neg.Fear.(Montagei).(dBHI_indexi) = false(1,length(stat.Fear.(Montagei).(dBHI_indexi).time));
            end
        end

        plot(time, mdBHI_diff.Fe_Ne.Ftl.(dBHI_indexi), 'r', 'LineWidth', 3); 
        plot(time, mdBHI_diff.Fe_Ne.Ctl.(dBHI_indexi), 'b', 'LineWidth', 3); 
        plot(time, mdBHI_diff.Fe_Ne.Ptr.(dBHI_indexi), 'k', 'LineWidth', 3);

        data = [mdBHI_diff.Fe_Ne.Ftl.(dBHI_indexi), ...
                mdBHI_diff.Fe_Ne.Ctl.(dBHI_indexi), ...
                mdBHI_diff.Fe_Ne.Ptr.(dBHI_indexi)];
        
        max_y = max(data(:));  
        min_y = min(data(:));  
    
        y_margin = 0.4 * (max_y - min_y);  
        ylim([min_y - y_margin, max_y + y_margin]);  

        % title(condition + " - " + band);
        ylabel('A.U.'); % arbitrary units
        line(xlim, [0 0], 'Color', [0.5,0.5,0.5],'LineWidth', 3, 'LineStyle', '--');
        if j == 5
            xticks(0:50:time(end));
        else
            xticks([]);  
        end
        xlim([0 time(end)]);

        set(gca, 'YTick', []); 
        yticks([0]);
        yticklabels({'0'}); 

        colors = [1, 0, 0; 0, 0, 1; 0, 0, 0];  % r, b, k 
        alphaValue = 0.8;  
        y = ylim(gca);
        baseOffset = 0;
        offsetIncrement = 0.05;

        for k = 1:3
            Montage_k = Montage(k);
            significantPositions = (pos.Fear.(Montage_k).(dBHI_indexi)) | (neg.Fear.(Montage_k).(dBHI_indexi));  
            if any(significantPositions)  
                indices = find(significantPositions);  
                color = colors(k, :);  
                currentOffset = baseOffset - k * offsetIncrement * diff(y);
                for idx = 1:length(indices)
                    index = indices(idx);
                    rectangle('Position', [time(index) - 0.5, y(2) + currentOffset, 1, diff(y) * 0.04], ...
                              'FaceColor', [color, alphaValue], 'EdgeColor', 'none');
                end
            end
        end
        
        title(['Fear '+ dBHI_indexi]);  

        set(gca, 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1);
        set(gca, 'XAxisLocation', 'bottom', 'YAxisLocation', 'left', 'TickLength', [0.01 0.01]);

        hold off;
    

    % legend
    legend_labels = {'Frontal', 'Central', 'Posterior'};
    hL = legend(legend_labels, 'Orientation', 'horizontal', 'Position', [0.5, 0.95, 0.1, 0.02]);
    set(hL, 'Units', 'normalized', 'Position', [0.5, 0.02, 0.1, 0.02]);

    set(gca, 'LineWidth', 3);   
    set(gcf, 'Position', [100, 100, 1500, 400]);  
    filename = fullfile(folder_fig, sprintf(['Fear ' + band + ' to '+ condition + '.png']));  
    print(gcf, filename, '-dpng', '-r1200');  
end

%% Happy
% from heart to brain
for i = 1:2
   condition = conditions(i);
   figure('Position', [0, 0, 1600, 200]);
   j = 3; 
        band = bands(j);
        BHI_indexi = condition + "2" + index_map(j);
        hold on;

        T_length = length(stat.Happy.Ftl.(BHI_indexi).time);
        time = 0:1:(T_length-1);

        pos = struct();
        neg = struct();
        for ii = 1:3
            Montagei = Montage(ii);
            
            if ~isempty(stat.Happy.(Montagei).(BHI_indexi).posclusters)    
                pos.Happy.(Montagei).(BHI_indexi) = stat.Happy.(Montagei).(BHI_indexi).posclusterslabelmat ~= 0; 
            else
                pos.Happy.(Montagei).(BHI_indexi) = false(1,length(stat.Happy.(Montagei).(BHI_indexi).time));
            end

            if ~isempty(stat.Happy.(Montagei).(BHI_indexi).negclusters)     
                neg.Happy.(Montagei).(BHI_indexi) = stat.Happy.(Montagei).(BHI_indexi).negclusterslabelmat ~= 0;
            else
                neg.Happy.(Montagei).(BHI_indexi) = false(1,length(stat.Happy.(Montagei).(BHI_indexi).time));
            end
        end

        plot(time, mBHI_diff.Ha_Ne.Ftl.(BHI_indexi), 'r', 'LineWidth', 3); 
        plot(time, mBHI_diff.Ha_Ne.Ctl.(BHI_indexi), 'b', 'LineWidth', 3); 
        plot(time, mBHI_diff.Ha_Ne.Ptr.(BHI_indexi), 'k', 'LineWidth', 3);

        data = [mBHI_diff.Ha_Ne.Ftl.(BHI_indexi), ...
                mBHI_diff.Ha_Ne.Ctl.(BHI_indexi), ...
                mBHI_diff.Ha_Ne.Ptr.(BHI_indexi)];
        
        max_y = max(data(:));  
        min_y = min(data(:));  
    
        y_margin = 0.4 * (max_y - min_y);
        ylim([min_y - y_margin, max_y + y_margin]); 

        ylabel('A.U.'); % arbitrary units
        line(xlim, [0 0], 'Color', [0.5,0.5,0.5],'LineWidth', 3, 'LineStyle', '--');
        if j == 5
            xticks(0:50:time(end));
        else
            xticks([]); 
        end
        xlim([0 time(end)]);

        set(gca, 'YTick', []); 
        yticks([0]); 
        yticklabels({'0'}); 

        colors = [1, 0, 0; 0, 0, 1; 0, 0, 0];  
        alphaValue = 0.8;  
        y = ylim(gca);
        baseOffset = 0;
        offsetIncrement = 0.05;

        for k = 1:3
            Montage_k = Montage(k);
            significantPositions = (pos.Happy.(Montage_k).(BHI_indexi)) | (neg.Happy.(Montage_k).(BHI_indexi));  
            if any(significantPositions)  
                indices = find(significantPositions);  
                color = colors(k, :);  
                currentOffset = baseOffset - k * offsetIncrement * diff(y);
                for idx = 1:length(indices)
                    index = indices(idx);
                    rectangle('Position', [time(index) - 0.5, y(2) + currentOffset, 1, diff(y) * 0.04], ...
                              'FaceColor', [color, alphaValue], 'EdgeColor', 'none');
                end
            end
        end
        
        title(['Happy '+ BHI_indexi]);  

        set(gca, 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1);
        set(gca, 'XAxisLocation', 'bottom', 'YAxisLocation', 'left', 'TickLength', [0.01 0.01]);

        hold off;
    
    legend_labels = {'Frontal', 'Central', 'Posterior'};
    hL = legend(legend_labels, 'Orientation', 'horizontal', 'Position', [0.5, 0.95, 0.1, 0.02]);
    set(hL, 'Units', 'normalized', 'Position', [0.5, 0.02, 0.1, 0.02]);

    set(gca, 'LineWidth', 3);  % 
    set(gcf, 'Position', [100, 100, 1500, 400]); 
    filename = fullfile(folder_fig, sprintf(['Happy '+ condition + ' to ' + band + '.png']));  
    print(gcf, filename, '-dpng', '-r1200');  
end

% from brain to heart
for i = 1:2
    condition = conditions(i);
    figure('Position', [0, 0, 1600, 200]);
    j = 3;
        band = bands(j);
        dBHI_indexi = index_map(j) + "2" + condition; 
        hold on;

        T_length = length(stat.Happy.Ftl.(dBHI_indexi).time);
        time = 0:1:(T_length-1);

        pos = struct();
        neg = struct();
        for ii = 1:3
            Montagei = Montage(ii);
            
            if ~isempty(stat.Happy.(Montagei).(dBHI_indexi).posclusters)    
                pos.Happy.(Montagei).(dBHI_indexi) = stat.Happy.(Montagei).(dBHI_indexi).posclusterslabelmat ~= 0; 
            else
                pos.Happy.(Montagei).(dBHI_indexi) = false(1,length(stat.Happy.(Montagei).(dBHI_indexi).time));
            end

            if ~isempty(stat.Happy.(Montagei).(dBHI_indexi).negclusters)     
                neg.Happy.(Montagei).(dBHI_indexi) = stat.Happy.(Montagei).(dBHI_indexi).negclusterslabelmat ~= 0;
            else
                neg.Happy.(Montagei).(dBHI_indexi) = false(1,length(stat.Happy.(Montagei).(dBHI_indexi).time));
            end
        end

        plot(time, mdBHI_diff.Ha_Ne.Ftl.(dBHI_indexi), 'r', 'LineWidth', 3); 
        plot(time, mdBHI_diff.Ha_Ne.Ctl.(dBHI_indexi), 'b', 'LineWidth', 3); 
        plot(time, mdBHI_diff.Ha_Ne.Ptr.(dBHI_indexi), 'k', 'LineWidth', 3);

        data = [mdBHI_diff.Ha_Ne.Ftl.(dBHI_indexi), ...
                mdBHI_diff.Ha_Ne.Ctl.(dBHI_indexi), ...
                mdBHI_diff.Ha_Ne.Ptr.(dBHI_indexi)];
        
        max_y = max(data(:)); 
        min_y = min(data(:)); 
    
        y_margin = 0.4 * (max_y - min_y); 
        ylim([min_y - y_margin, max_y + y_margin]); 

        ylabel('A.U.'); % arbitrary units
        line(xlim, [0 0], 'Color', [0.5,0.5,0.5],'LineWidth', 3, 'LineStyle', '--');
        if j == 5
            xticks(0:50:time(end));
        else
            xticks([]); 
        end
        xlim([0 time(end)]);

        set(gca, 'YTick', []);
        yticks([0]); 
        yticklabels({'0'}); 

        colors = [1, 0, 0; 0, 0, 1; 0, 0, 0];  
        alphaValue = 0.8;  
        y = ylim(gca);
        baseOffset = 0;
        offsetIncrement = 0.05;

        for k = 1:3
            Montage_k = Montage(k);
            significantPositions = (pos.Happy.(Montage_k).(dBHI_indexi)) | (neg.Happy.(Montage_k).(dBHI_indexi));  
            if any(significantPositions)  
                indices = find(significantPositions);  
                color = colors(k, :);  
                currentOffset = baseOffset - k * offsetIncrement * diff(y);
                for idx = 1:length(indices)
                    index = indices(idx);
                    rectangle('Position', [time(index) - 0.5, y(2) + currentOffset, 1, diff(y) * 0.04], ...
                              'FaceColor', [color, alphaValue], 'EdgeColor', 'none');
                end
            end
        end
        
        title(['Happy '+ dBHI_indexi]);  
        set(gca, 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1);
        set(gca, 'XAxisLocation', 'bottom', 'YAxisLocation', 'left', 'TickLength', [0.01 0.01]);

        hold off;
    
    legend_labels = {'Frontal', 'Central', 'Posterior'};
    hL = legend(legend_labels, 'Orientation', 'horizontal', 'Position', [0.5, 0.95, 0.1, 0.02]);
    set(hL, 'Units', 'normalized', 'Position', [0.5, 0.02, 0.1, 0.02]);

    set(gca, 'LineWidth', 3);  % 
    set(gcf, 'Position', [100, 100, 1500, 400]); 
    filename = fullfile(folder_fig, sprintf(['Happy ' + band + ' to '+ condition + '.png'])); 
    print(gcf, filename, '-dpng', '-r1200');  
end