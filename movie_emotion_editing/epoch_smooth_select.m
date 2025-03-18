
%% This script selects typical epochs with sliding windows to aligh with the processing of dBHI

filename = '\movie_emotion_editing\Movies_rating_by_RA.csv';
film_rating = readtable(filename);

%% considering the sliding window method in calculating dBHI
% 3s-179s
% brain-to-heart 18s - 163s
% heart-to-brain 3s - 163s
% sliding 15-window in the RR series

start_time = 3; % Starting time in seconds
window_size = 15; % Window size in seconds
end_time = 178; % Ending time in seconds

time_vector = start_time:(end_time - window_size):end_time;

smth_fear_intensity = [];
smth_happy_intensity = [];

% Loop through each time point and calculate the mean
for window_start = start_time:end_time - window_size
    window_end = window_start + window_size;
    rows = film_rating.Time >= window_start & film_rating.Time < window_end;
    % Calculate means if there are any rows in the current window
    if any(rows)
        smth_fear_intensity(end + 1) = mean(film_rating.Fear_Intensity(rows));
        smth_happy_intensity(end + 1) = mean(film_rating.Happy_Intensity(rows));
    else
        smth_fear_intensity(end + 1) = NaN; 
        smth_happy_intensity(end + 1) = NaN; 
    end
end

result_time_vector = start_time:end_time - window_size;

smth_film_rating = table(result_time_vector', smth_fear_intensity',  ...
    smth_happy_intensity',  ...
                     'VariableNames', {'Time', 'Fear_Intensity', 'Happy_Intensity'});

%% to get the high fear
% Calculate the distances from each point to (9, 1) and (0, 9)
distances_high_fear = sqrt((smth_film_rating.Fear_Intensity - 9).^2 );

% Get the number of points
num_points = height(smth_film_rating);
% Calculate the number of points for 30%
num_high_fear = round(num_points * 0.3);

% Sort distances and get the indices for the closest points
[~, high_fear_indices] = sort(distances_high_fear);

% Select the top 30% indices
selected_high_fear_indices = high_fear_indices(1:num_high_fear);

% Get the selected times
selected_high_fear_times = smth_film_rating.Time(selected_high_fear_indices);

% Sort the selected times
selected_high_fear_times = sort(selected_high_fear_times);

% Ensure selected times are grouped within 5 seconds
time_window = 5; % 5 seconds

% Initialize clustered arrays
high_fear_clusters = [];

% Clustering for High Fear
current_cluster = [];
last_time = -Inf;

for i = 1:length(selected_high_fear_times)
    if selected_high_fear_times(i) <= last_time + time_window
        current_cluster = [current_cluster; selected_high_fear_times(i)];
    else
        % Only store clusters with length >= 5 seconds
        if length(current_cluster) > 0 && (current_cluster(end) - current_cluster(1)) >= 5
            high_fear_clusters = [high_fear_clusters; current_cluster]; % Store the cluster
        end
        current_cluster = selected_high_fear_times(i); % Start a new cluster
    end
    last_time = selected_high_fear_times(i);
end

% Check the last cluster for High Fear
if length(current_cluster) > 0 && (current_cluster(end) - current_cluster(1)) >= 5
    high_fear_clusters = [high_fear_clusters; current_cluster];
end

%% plot fear
folder_fig = '\movie_emotion_editing\fig'

figure('Position', [100, 100, 2000, 400]);

subplot(2,1,1); 
imagesc(smth_film_rating.Time, 1, smth_film_rating.Fear_Intensity');  
cmap_intensity = hot(256);  
cmap_intensity = cmap_intensity(60:240, :);  
colormap(gca, flipud(cmap_intensity));  
caxis([0 9]); 
colorbar('Ticks', [0, 9], 'TickLabels', {'0', '9'});  
set(gca, 'Position', [0.1 0.7 0.7 0.2]);  
ylabel('Intensity');
set(gca, 'TickDir', 'out');
set(gca, 'YTick', []);  
set(gca, 'XTick', []); 

% Mark High Fear time points with Rectangular Bars 
subplot(2,1,2); 

% Plot High Fear clusters (in red)
hold on;
% Plot High Fear clusters (in dark blue)
for i = 1:length(high_fear_clusters)
    t = high_fear_clusters(i);
    rectangle('Position', [t-0.5, 0.1, 1, 0.2], 'FaceColor', [0 0 0.6], 'EdgeColor', [0 0 0.6]);  % Draw dark blue rectangle
end

set(gca, 'TickDir', 'out');
xlabel('Time (seconds)');
xlim([min(smth_film_rating.Time), max(smth_film_rating.Time)]); 
set(gca, 'Position', [0.1 0.1 0.7 0.2]); 

ylim([0 1]);  
yticks([]);  
set(gca, 'YColor', 'none');  
xticks = 20:20:160;  

set(gca, 'XTickLabel', arrayfun(@num2str, xticks, 'UniformOutput', false));
hold off;

filename = fullfile(folder_fig, sprintf(['Fear intensity smooth epoch.png']));  
print(gcf, filename, '-dpng', '-r1200');

%% to get the high happy epochs
distances_high_happy = sqrt((smth_film_rating.Happy_Intensity - 9).^2);
num_points = height(smth_film_rating);
num_high_happy = round(num_points * 0.3);
[~, high_happy_indices] = sort(distances_high_happy);
selected_high_happy_indices = high_happy_indices(1:num_high_happy);
selected_high_happy_times = smth_film_rating.Time(selected_high_happy_indices);
selected_high_happy_times = sort(selected_high_happy_times);
time_window = 5; 

high_happy_clusters = [];
low_happy_clusters = [];
current_cluster = [];
last_time = -Inf;

for i = 1:length(selected_high_happy_times)
    if selected_high_happy_times(i) <= last_time + time_window
        current_cluster = [current_cluster; selected_high_happy_times(i)];
    else
        if length(current_cluster) > 0 && (current_cluster(end) - current_cluster(1)) >= 5
            high_happy_clusters = [high_happy_clusters; current_cluster]; 
        end
        current_cluster = selected_high_happy_times(i); 
    end
    last_time = selected_high_happy_times(i);
end

% Check the last cluster for High Happy
if length(current_cluster) > 0 && (current_cluster(end) - current_cluster(1)) >= 5
    high_happy_clusters = [high_happy_clusters; current_cluster];
end

%% plot happy
figure('Position', [100, 100, 2000, 400]);

subplot(2,1,1); 
imagesc(smth_film_rating.Time, 1, smth_film_rating.Happy_Intensity'); 

cmap_intensity = hot(256);  
cmap_intensity = cmap_intensity(60:240, :);  
colormap(gca, flipud(cmap_intensity));  
caxis([0 9]);  

colorbar('Ticks', [0, 9], 'TickLabels', {'0', '9'});  
set(gca, 'Position', [0.1 0.7 0.7 0.2]); 
ylabel('Intensity');
set(gca, 'TickDir', 'out');
set(gca, 'YTick', []); 
set(gca, 'XTick', []); 

%  Mark High Happy Time Points with Rectangular Bars ----
subplot(2,1,2); 
hold on;
for i = 1:length(high_happy_clusters)
    t = high_happy_clusters(i);
    rectangle('Position', [t-0.5, 0.1, 1, 0.2], 'FaceColor', [0.6 0 0], 'EdgeColor', [0.6 0 0]);  
end

set(gca, 'TickDir', 'out');
xlabel('Time (seconds)');
xlim([min(smth_film_rating.Time), max(smth_film_rating.Time)]);  
set(gca, 'Position', [0.1 0.1 0.7 0.2]);  

ylim([0 1]);  
yticks([]);  
set(gca, 'YColor', 'none');  
xticks = 20:20:160;  

set(gca, 'XTickLabel', arrayfun(@num2str, xticks, 'UniformOutput', false));
hold off;

filename = fullfile(folder_fig, sprintf(['Happy intensity smooth epoch.png']));  
print(gcf, filename, '-dpng', '-r1200'); 

%% save epoch for subsequent analysis
num_rows = height(smth_film_rating); 
smth_film_rating.High_Fear = zeros(num_rows, 1); 
smth_film_rating.High_Happy = zeros(num_rows, 1);  

for i = 1:length(high_fear_clusters)
    t = high_fear_clusters(i);
    if t >= 3 && t <= 163
        row_index = t - 2;  
        smth_film_rating.High_Fear(row_index) = 1; 
    end
end

for i = 1:length(high_happy_clusters)
    t = high_happy_clusters(i);
    if t >= 3 && t <= 163
        row_index = t - 2;  
        smth_film_rating.High_Happy(row_index) = 1;  
    end
end

writetable(smth_film_rating, '\movie_emotion_editing\typical_moments_smth.csv');
