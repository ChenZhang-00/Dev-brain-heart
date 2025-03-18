function [dBHI_ne, dBHI_fe, dBHI_ha] = dBHI_FCP_movie(id,age)
%% This function average the dBHI timeseries across montages
id  = id;
age = age;

% read in dBHI_coefficients
dBHI_path     = '\brain-heart interplay\movie_dBHI_TS\';
dBHI_name     = ['ID ' num2str(id) ' Age ' num2str(age) ' movie_dBHI_TS.mat'];
disp(['load ' dBHI_path dBHI_name]);
load([dBHI_path dBHI_name], 'movie_dBHI');

% montage for frontal, central, posterior chs
Frontal = [1,32,33,34,35,62,63,5,4,37,3,36,2,61,31,60,30,29];
Central = [38,6,39,7,27,58,28,59,9,41,8,40,26,57,25,56,24,42,10,43,11,53,22,54,23,55];
Posterior = [15,14,45,13,44,12,52,21,51,20,19,46,47,48,49,50,16,17,18];

% average the dBHI among Ftl, Ctl, Ptr
dBHI_ne = []; dBHI_fe = []; dBHI_ha = [];
dBHI_name = fieldnames(movie_dBHI.neutral);
for i = 1:numel(dBHI_name)
    dBHIi = dBHI_name{i};
    datai_ne = movie_dBHI.neutral.(dBHIi);
    dBHI_ne.Frontal.(dBHIi) = mean(datai_ne(Frontal,:),1); 
    dBHI_ne.Central.(dBHIi) = mean(datai_ne(Central,:),1); 
    dBHI_ne.Posterior.(dBHIi) = mean(datai_ne(Posterior,:),1); 

    datai_fe = movie_dBHI.fear.(dBHIi);
    dBHI_fe.Frontal.(dBHIi) = mean(datai_fe(Frontal,:),1); 
    dBHI_fe.Central.(dBHIi) = mean(datai_fe(Central,:),1); 
    dBHI_fe.Posterior.(dBHIi) = mean(datai_fe(Posterior,:),1);

    datai_ha = movie_dBHI.happy.(dBHIi);
    dBHI_ha.Frontal.(dBHIi) = mean(datai_ha(Frontal,:),1); 
    dBHI_ha.Central.(dBHIi) = mean(datai_ha(Central,:),1); 
    dBHI_ha.Posterior.(dBHIi) = mean(datai_ha(Posterior,:),1); 
end


end


