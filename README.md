# Dev-brain-heart
Codes for the paper "The development of brain-heart interplay during child emotional experience"

# Scripts Overview

| **Analysis**               | **Script/Data**             | **Function**                                                            |
|----------------------------|-----------------------------|-------------------------------------------------------------------------|
| **EEG and ECG Preprocessing** | `eeg_pre_for_power.m`        | Preprocessing EEG for power analysis                                    |
|                            | `ecg_pre.m`                 | Detection of R and T waves on the ECG                                   |
|                            | `movie_EEG_TF.m`            | Power analysis for EEG data                                             |
|                            | `movie_ECG_TS.ipynb`        | Compute ECG time series                                                 |
| **Eliciting Effects**      | `child_feelings.R`          | Visualization of children's self-reported feelings                      |
|                            | `heart_barplot.R`           | Visualization of children's cardiac activities across different movies  |
|                            | `ECG_analysis.m`            | Compute cardiac activities and visualize dynamics                        |
|                            | `EEG_analysis.m`            | Compute EEG dynamics                                                     |
|                            | `movie_bio_dym.R`           | Correlation between neurophysiological dynamics and emotional intensity  |
| **Movie Editing**          | `typical_moments_selected.m` | Select typical emotional moments                                         |
|                            | `epoch_smooth_select.m`     | Select typical emotional moments with smooth windows                     |
|                            | `Movies_rating_by_RA.csv`   | Mean ratings by RAs                                                     |
| **Nondirectional BHI**     | `nodi_Brain-Heart.m`        | Calculate non-BHI for each child                                         |
|                            | `non_BH_alpha_heart.R`      | Visualize EEG alpha and heart activity                                  |
| **HEP**                    | `movie_HEP.m`               | Preprocessing EEG and segmentation                                       |
|                            | `HEP_stat.m`                | Comparisons between fearful/happy and neutral states                    |
| **dBHI**                   | `dBHI_movie_TS.m`           | Time series analysis of dBHI                                            |
|                            | `dBHI_model_child.m`        | dBHI modeling for children                                              |
|                            | `dBHI_FCP_movie.m`         | Average dBHI across montages                                            |
|                            | `dBHI_dym.m`                | Comparisons of dBHI between fearful/happy and neutral                   |
| **Development of BHI**     | `nonBH-age.R`               | Visualize BH and age relationships                                      |
|                            | `HEP-age.R`                 | Visualize HEP and age relationships                                     |
|                            | `dBHI-age.R`                | Visualize dBHI and age relationships                                    |
|                            | `typical_dBHI.m`            | Average dBHI over typical moments for each child                         |
| **Feelings**               | `separate_group.m`          | Identify children with high and low emotional feelings                   |
|                            | `dBHI-feelings-radar.R`     | Visualize dBHI differences between high/low emotional children          |
| **IS-RSA**                 | `dBHI_feelings_ISRSA`       | Intersubject similarity analysis of dBHI and self-reported feelings     |
| **FDR**                    | `FDR.ipynb`                 | Applying FDR correction to control for multiple comparisons and reduce false positives |
