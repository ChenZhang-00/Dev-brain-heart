
%% This script averages dBHI over tipical moments for each child

% epoch marked with high fear and high happy
smth_film_rating = readtable("\movie_emotion_editing\typical_moments_smth.csv");

%% load dBHI
load('\brain-heart interplay\dBHI\dBHI_for_each.mat');

result_table = table();

index_map = ["d", "t", "a", "b", "g"]; % EEG bands
conditions = ["LF", "HF"]; % HRV
% only central here
for sub_idx = 1:length(dBHI_Fe_Ne.Ctl.LF2a)
    subject_id = dBHI_Fe_Ne.ID{sub_idx};  
    avg_values = struct();
    
    high_fear_times = smth_film_rating.Time(smth_film_rating.High_Fear == 1);
    
    high_happy_times = smth_film_rating.Time(smth_film_rating.High_Happy == 1);
    
    for condition = conditions
        for k = 1:length(index_map)
            key = condition + "2" + index_map(k); 
            
            current_data = dBHI_Fe_Ne.Ctl.(key){sub_idx};  
            current_data_happy = dBHI_Ha_Ne.Ctl.(key){sub_idx};  
            
            high_fear_values = [];
            high_happy_values = [];
           
            for t = high_fear_times'
                if t >= 3 && t <= 163  
                    high_fear_values = [high_fear_values, current_data(t - 2)];  
                end
            end
            
            for t = high_happy_times'
                if t >= 3 && t <= 163  
                    high_happy_values = [high_happy_values, current_data_happy(t - 2)];  
                end
            end
            
            avg_high_fear = mean(high_fear_values); 
            avg_high_happy = mean(high_happy_values);  
            
            avg_values.(key) = struct('High_Fear', avg_high_fear,  ...
                                       'High_Happy', avg_high_happy);
        end
    end

    for condition = conditions
        for k = 1:length(index_map)
            key =  index_map(k)+ "2" + condition; 
            
            current_data = dBHI_Fe_Ne.Ctl.(key){sub_idx}; 
            current_data_happy = dBHI_Ha_Ne.Ctl.(key){sub_idx}; 
            
            high_fear_values = [];
            high_happy_values = [];
           
            for t = high_fear_times'
                if t >= 18 && t <= 163 
                    high_fear_values = [high_fear_values, current_data(t - 17)];  
                end
            end
            
            for t = high_happy_times'
                if t >= 18 && t <= 163 
                    high_happy_values = [high_happy_values, current_data_happy(t - 17)];
                end
            end
            
            avg_high_fear = mean(high_fear_values); 
            avg_high_happy = mean(high_happy_values);  
            
            avg_values.(key) = struct('High_Fear', avg_high_fear, ...
                                       'High_Happy', avg_high_happy);
        end
    end
    
    row_data = {subject_id};
    for condition = conditions
        for k = 1:length(index_map)
            key1 = condition + "2" + index_map(k);
            key2 = index_map(k) + "2" + condition;
    
            if isfield(avg_values, key1)
                row_data{end+1} = avg_values.(key1).High_Fear; 
                row_data{end+1} = avg_values.(key1).High_Happy; 
            end
            
            if isfield(avg_values, key2)
                row_data{end+1} = avg_values.(key2).High_Fear;  
                row_data{end+1} = avg_values.(key2).High_Happy;  
            end
        end
    end

    result_table = [result_table; row_data]; 
end

column_names = {'ID'};  

for condition = conditions
    for k = 1:length(index_map)
        key1 = condition + "2" + index_map(k); 
        key2 = index_map(k) + "2" + condition;  
        
        column_names{end+1} = [char(key1) '_High_Fear'];
        column_names{end+1} = [char(key1) '_High_Happy'];
        
        column_names{end+1} = [char(key2) '_High_Fear'];
        column_names{end+1} = [char(key2) '_High_Happy'];
    end
end

result_table.Properties.VariableNames = column_names;
writetable(result_table, '\development of BHI\typical_dBHI_Ctl.csv','QuoteStrings', true);