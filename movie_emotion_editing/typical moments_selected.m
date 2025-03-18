
%% This script selects typical emotional moments during movie viewing.
% The top 30% of the highest ratings are selected as representative emotional moments.

% read in movie emotional intensity ratings by RA
filename = '\movie_emotion_editing\Movies_rating_by_RA.csv';
film_rating = readtable(filename);
film_rating = film_rating(3:180, :); % kick out the first 2-s epoch in each movie clips

%% Fear
Fear_Intensity = film_rating.Fear_Intensity;
n = height(film_rating);
top30PercentIndex = round(0.3 * n);
% Sort order
[sortedFear, sortedIndex] = sort(Fear_Intensity);
% Identify and keep only consecutive time intervals of length >= 5
% top 30%
high30Index = sortedIndex(end-top30PercentIndex+1:end);
high30Fear = film_rating(high30Index, :);
% Sort by 'Time' column in ascending order
high30Fear = sortrows(high30Fear, 'Time');
% Identify and keep only consecutive time intervals of length >= 5
timeDiffs = diff(high30Fear.Time);
consecutiveGroups = [0; timeDiffs ~= 1]; % Mark where consecutive sequence breaks
groupID = cumsum(consecutiveGroups) + 1; % Convert group IDs to positive integers
% Calculate the size of each group
groupSizes = accumarray(groupID, 1);
% Keep only rows where the group size is 5 or more
validGroupIndices = ismember(groupID, find(groupSizes >= 5));
high30Fear = high30Fear(validGroupIndices, :);

% bottom 30%
low30Index = sortedIndex(1:top30PercentIndex);
low30Fear = film_rating(low30Index, :);
% Sort by 'Time' column in ascending order
low30Fear = sortrows(low30Fear, 'Time');
% Identify and keep only consecutive time intervals of length >= 5
timeDiffs = diff(low30Fear.Time);
consecutiveGroups = [0; timeDiffs ~= 1]; % Mark where consecutive sequence breaks
groupID = cumsum(consecutiveGroups) + 1; % Convert group IDs to positive integers
% Calculate the size of each group
groupSizes = accumarray(groupID, 1);
% Keep only rows where the group size is 5 or more
validGroupIndices = ismember(groupID, find(groupSizes >= 5));
low30Fear = low30Fear(validGroupIndices, :);

%% Happy
Happy_Intensity = film_rating.Happy_Intensity;
n = height(film_rating);
top30PercentIndex = round(0.3 * n);
% Sort order
[sortedHappy, sortedIndex] = sort(Happy_Intensity);
% top 30%
high30Index = sortedIndex(end-top30PercentIndex+1:end);
high30Happy = film_rating(high30Index, :);
% Sort by 'Time' column in ascending order
high30Happy = sortrows(high30Happy, 'Time');
% Identify and keep only consecutive time intervals of length >= 5
timeDiffs = diff(high30Happy.Time);
consecutiveGroups = [0; timeDiffs ~= 1]; % Mark where consecutive sequence breaks
groupID = cumsum(consecutiveGroups) + 1; % Convert group IDs to positive integers
% Calculate the size of each group
groupSizes = accumarray(groupID, 1);
% Keep only rows where the group size is 5 or more
validGroupIndices = ismember(groupID, find(groupSizes >= 5));
high30Happy = high30Happy(validGroupIndices, :);

% bottom 30%
low30Index = sortedIndex(1:top30PercentIndex);
low30Happy = film_rating(low30Index, :);
% Sort by 'Time' column in ascending order
low30Happy = sortrows(low30Happy, 'Time');
% Identify and keep only consecutive time intervals of length >= 5
timeDiffs = diff(low30Happy.Time);
consecutiveGroups = [0; timeDiffs ~= 1]; % Mark where consecutive sequence breaks
groupID = cumsum(consecutiveGroups) + 1; % Convert group IDs to positive integers
% Calculate the size of each group
groupSizes = accumarray(groupID, 1);
% Keep only rows where the group size is 5 or more
validGroupIndices = ismember(groupID, find(groupSizes >= 5));
low30Happy = low30Happy(validGroupIndices, :);

%% save
emo_epoch_rating = [];
emo_epoch_rating.High_Happy = high30Happy;
emo_epoch_rating.High_Fear = high30Fear;
emo_epoch_rating.Low_Happy = low30Happy;
emo_epoch_rating.Low_Fear = low30Fear;

outputFolder = '\movie_emotion_editing'; 
emo_rating = fullfile(outputFolder, 'emo_epoch_rating.mat');

save(emo_rating, 'emo_epoch_rating');
