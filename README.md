# Dev-brain-heart
Codes for the paper "The development of brain-heart interplay during child affective experience"

## Scripts Overview

| **Analysis**               | **Script/Data**             | **Function**                                                            |
|----------------------------|-----------------------------|-------------------------------------------------------------------------|
| **EEG and ECG Preprocessing** | `ecg_pre.m`                 | Detection of R and T waves on the ECG                                |
|                            | `eeg_pre_for_power.m`       | Preprocessing EEG for power analysis                                    |
|                            | `movie_EEG_TF.m`            | Power analysis for EEG data                                             |
|                            | `EEG_regions_pow.m`         | Averaged EEG power over regions (Frontal, Central, Poterior)            |
| **Eliciting Effects**      | `ECG_analysis.m`            | Compute cardiac activities and visualize dynamics                       |
|                            | `EEG_power_dym.m`           | Compute EEG(Frontal) dynamics and visualize                             |
| **Movie Editing**          | `typical_moments_selected.m` | Select typical emotional moments                                       |
|                            | `epoch_smooth_select.m`     | Select typical emotional moments with smooth windows                    |
|                            | `Movies_rating_by_RA.csv`   | Mean ratings by RAs                                                     |
| **Brain-heart interplay**  | `nondi_BH_by_age.ipynb`     | Calculate nondirection brain-heart correlation for each age group       |
|                            | `movie_HEP.m`               | Preprocessing EEG and segmentation                                      |
|                            | `HEP_age.m`                 | Comparisons between fearful/happy and neutral states in each age group  |
|                            | `dBHI_movie_TS.m`           | Time series analysis of dBHI                                            |
|                            | `dBHI_model_child.m`        | dBHI modeling for children                                              |
|                            | `dBHI_FCP_movie.m`          | Average dBHI across montages                                            |
|                            | `dBHI_dym_age.m`            | Comparisons of dBHI between fearful/happy and neutral in each age group |
| **similarity analysis**    | `Similarity_analysis.ipynb` | Similarity analysis of self-reported feelings and brain-heart interplay |
