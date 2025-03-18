
%% This script categorizes children into high and low emotional groups based on 
% their self-reported feelings after watching the movie.

result_table = table();
% load all info
child_info = readtable("\child_info.csv");

result_table.ID = child_info.ID;
child_info.A_Fe_Ne = child_info.fear_A - child_info.neutral_A;
child_info.V_Fe_Ne = child_info.fear_V - child_info.neutral_V;
child_info.A_Ha_Ne = child_info.happy_A - child_info.neutral_A;
child_info.V_Ha_Ne = child_info.happy_V - child_info.neutral_V;

% Define the reference point (8, -8)
ref_x = 8;
ref_y = -8;

%% Fear
% Calculate the Euclidean distance to the point (8, -8)
distances = sqrt((child_info.A_Fe_Ne - ref_x).^2 + (child_info.V_Fe_Ne - ref_y).^2);

% Sort distances to identify closest and farthest 25%
[~, sorted_indices] = sort(distances);

n_rows = height(child_info);
n_25percent = round(0.25 * n_rows);

% Assign Fear_indivd: 1 for closest 25%, -1 for farthest 25%, 0 for the rest
result_table.Fear_indivd = zeros(n_rows, 1);
result_table.Fear_indivd(sorted_indices(1:n_25percent)) = 1;  % Closest 25%
result_table.Fear_indivd(sorted_indices(end-n_25percent+1:end)) = -1;  % Farthest 25%

%% happy
% Define the reference point (8, 8)
ref_x = 8;
ref_y = 8;
% Calculate the Euclidean distance to the point (8, 8)
distances = sqrt((child_info.A_Ha_Ne - ref_x).^2 + (child_info.V_Ha_Ne - ref_y).^2);
% Sort distances to identify closest and farthest 25%
[~, sorted_indices] = sort(distances);
n_rows = height(child_info);
n_25percent = round(0.25 * n_rows);
% Assign Happy_indivd: 1 for closest 25%, -1 for farthest 25%, 0 for the rest
result_table.Happy_indivd = zeros(n_rows, 1);
result_table.Happy_indivd(sorted_indices(1:n_25percent)) = 1;  % Closest 25 %
result_table.Happy_indivd(sorted_indices(end-n_25percent+1:end)) = -1;  % Farthest 25 %

writetable(result_table, '\BHI and self-reports\child_feeling_group.csv');