% ---------------------------------------------------------------
% dBHI Analysis by age
% ---------------------------------------------------------------
% 1. Loads subject information.
% 2. Computes directional BHI indices (LF/HF × delta/theta/alpha) per region.
% 3. Groups data by age (G1–G3) and stores emotion-specific time series.
% 4. Performs cluster-based permutation tests (Fear/Happy vs Neutral).
% 5. Visualizes group-level BHI trajectories with significance overlays.
%
% ---------------------------------------------------------------

%% === Step 1: Setup and Load Info ===
addpath("/toolbox/Temporal_Cluster_Permutation");

child_info = readtable("/all_children_info.csv");
child_info(child_info.ID == 231125091, :) = [];

dBHI_index = ["LF2d", "HF2d", "d2LF", "d2HF", ...
              "LF2t", "HF2t", "t2LF", "t2HF", ...
              "LF2a", "HF2a", "a2LF", "a2HF"];
groups = {'G1','G2','G3'};
age_ranges = {[60 83],[84 107],[108 131]};


%% === Step 2: Initialize Containers ===
for g = 1:length(groups)
    gname = groups{g};
    dBHI_ne.(gname)  = struct();
    dBHI_fe.(gname)  = struct();
    dBHI_ha.(gname)  = struct();
    dBHI_mne.(gname) = struct();
end


%% === Step 3: Compute Individual BHI per Group ===
for g = 1:length(groups)
    gname = groups{g};
    age_range = age_ranges{g};

    idx_group = child_info.Age_month >= age_range(1) & child_info.Age_month <= age_range(2);
    group_subjects = child_info(idx_group, :);

    for s = 1:height(group_subjects)
        id  = group_subjects.ID(s);
        age = group_subjects.Age_month(s);

        try
            [dBHI_nei, dBHI_fei, dBHI_hai] = dBHI_FCP_movie(id, age);
        catch ME
            warning("[Skipped] ID: %d | Error: %s", id, ME.message);
            continue;
        end

        for ii = 1:length(dBHI_index)
            dBHI_indexii = dBHI_index(ii);
            for region = ["Frontal","Central","Posterior"]
                val_ne = dBHI_nei.(region).(dBHI_indexii);
                val_fe = dBHI_fei.(region).(dBHI_indexii);
                val_ha = dBHI_hai.(region).(dBHI_indexii);
                T = length(val_ne);

                dBHI_ne.(gname).(region).(dBHI_indexii).trial{s} = val_ne;
                dBHI_fe.(gname).(region).(dBHI_indexii).trial{s} = val_fe;
                dBHI_ha.(gname).(region).(dBHI_indexii).trial{s} = val_ha;
                dBHI_mne.(gname).(region).(dBHI_indexii).trial{s} = repmat(mean(val_ne), 1, T);

                dBHI_ne.(gname).(region).(dBHI_indexii).time{s}  = 1:T;
                dBHI_fe.(gname).(region).(dBHI_indexii).time{s}  = 1:T;
                dBHI_ha.(gname).(region).(dBHI_indexii).time{s}  = 1:T;
                dBHI_mne.(gname).(region).(dBHI_indexii).time{s} = 1:T;
            end
        end
    end
end

%% === Step 4: Compute ΔBHI (Fear–Neutral, Happy–Neutral) & Stats ===
cfg = [];
cfg.mint             = 5;
cfg.statistic        = 'dep_param';
cfg.alpha            = 0.05;
cfg.tail             = 0;
cfg.numrandomization = 10000;

Regions = ["Frontal","Central","Posterior"];

for g = 1:numel(groups)
    gname = groups{g};
    for ii = 1:numel(dBHI_index)
        idx = dBHI_index(ii);
        for r = 1:numel(Regions)
            region = Regions(r);

            fe_trials = dBHI_fe.(gname).(region).(idx).trial;
            ha_trials = dBHI_ha.(gname).(region).(idx).trial;
            ne_trials = dBHI_mne.(gname).(region).(idx).trial;

            % Compute Fear–Neutral & Happy–Neutral differences
            dBHI_Fe_Ne.(gname).(region).(idx) = cellfun(@(x,y) x - y, fe_trials, ne_trials, 'UniformOutput', false);
            dBHI_Ha_Ne.(gname).(region).(idx) = cellfun(@(x,y) x - y, ha_trials, ne_trials, 'UniformOutput', false);

            tmp1 = dBHI_Fe_Ne.(gname).(region).(idx);
            tmp2 = dBHI_Ha_Ne.(gname).(region).(idx);

            mdBHI_diff.(gname).Fe_Ne.(region).(idx) = median(cat(1, tmp1{:}), 1);
            mdBHI_diff.(gname).Ha_Ne.(region).(idx) = median(cat(1, tmp2{:}), 1);

            % Cluster-based permutation test
            stat.Fear.(gname).(region).(idx)  = ft_statfun_temp_cluster(cfg, dBHI_fe.(gname).(region).(idx), dBHI_mne.(gname).(region).(idx));
            stat.Happy.(gname).(region).(idx) = ft_statfun_temp_cluster(cfg, dBHI_ha.(gname).(region).(idx), dBHI_mne.(gname).(region).(idx));
        end
    end
end


%% === Step 5: Visualization (Fear / Happy) ===
montage      = "Posterior";   % "Frontal" | "Central" | "Posterior"
emotion_name = "Fear";        % "Fear" | "Happy"
direction    = "HB";          % "HB" = Heart→Brain, "BH" = Brain→Heart

% ---- Visualization settings ----
bands      = ["delta","theta","alpha"];
imap       = struct('delta','d','theta','t','alpha','a');
conditions = ["LF","HF"];
group_keys = {'G1','G2','G3'};
group_labels = {'G1 (5-6y)','G2 (7-8y)','G3 (9-10y)'};
group_colors = [1 0 0; 0 0 1; 0 0 0];
outdir     = '/fig';
if emotion_name == "Fear", emotion_key = "Fe"; else, emotion_key = "Ha"; end

% ---- Loop over LF/HF ----
for i = 1:numel(conditions)
    cond = conditions(i);
    figure('Position',[120,80,1600,900]);

    for j = 1:numel(bands)
        band = bands(j); b = imap.(band);

        % Direction index key
        if direction == "HB"
            idx = cond + "2" + b;
        else
            idx = b + "2" + cond;
        end

        subplot(3,1,j); hold on;
        set(gca,'LineWidth',1.6,'TickLength',[0.015 0.015]);
        Yall = [];

        % Plot group-level median ΔBHI
        for g = 1:numel(group_keys)
            G = group_keys{g};
            y = mdBHI_diff.(G).(emotion_key + "_Ne").(montage).(idx);
            plot(0:numel(y)-1, y, 'LineWidth', 3, 'Color', group_colors(g,:));
            Yall = [Yall; y(:)'];
        end

        % Axis & zero line
        ymin = min(Yall,[],'all'); ymax = max(Yall,[],'all');
        ymrg = 0.4 * max(ymax - ymin, eps);
        ylim([ymin - ymrg, ymax + ymrg]);
        line(xlim, [0 0], 'Color', [0.5 0.5 0.5], 'LineStyle', '--', 'LineWidth', 1.2);
        set(gca, 'YTick', [], 'Box', 'off', 'TickDir', 'out');

        % Add significance bars
        yl = ylim; off = 0.05 * range(yl);
        xl = xlim;
        for g = 1:numel(group_keys)
            G = group_keys{g};
            pos = stat.(emotion_name).(G).(montage).(idx).posclusterslabelmat ~= 0;
            neg = stat.(emotion_name).(G).(montage).(idx).negclusterslabelmat ~= 0;
            sig = pos | neg;
            sidx = find(sig);
            baseY = yl(2) - g * off;
            for t = sidx(:)'
                x_start = max(xl(1), t - 0.5);
                x_end   = min(xl(2), t + 0.5);
                width   = x_end - x_start;
                if width > 0
                    rectangle('Position', [x_start, baseY, width, 0.03*range(yl)], ...
                              'FaceColor', [group_colors(g,:) 0.75], 'EdgeColor', 'none');
                end
            end
        end

        % Titles & axes
        if direction == "HB"
            title(sprintf('%s | %s | %s→%s', montage, emotion_name, cond, char(band)));
        else
            title(sprintf('%s | %s | %s→%s', montage, emotion_name, char(band), cond));
        end
        if j == numel(bands), xlabel('Time'); else, set(gca, 'XTick', []); end
    end

    % Legend & save
    lgd = legend(group_labels, 'Orientation', 'horizontal');
    set(lgd, 'Position', [0.35, 0.02, 0.3, 0.03]);

    if direction == "HB"
        outfile = fullfile(outdir, sprintf('%s_%s_%s_to_allBands.png', emotion_name, montage, cond));
    else
        outfile = fullfile(outdir, sprintf('%s_%s_%s_from_allBands.png', emotion_name, montage, cond));
    end
    print(gcf, outfile, '-dpng', '-r300');
end
