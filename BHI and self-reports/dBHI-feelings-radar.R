
## This script visualizes the differences of dBHI
# between high and low emotional children.

library(ggplot2)
library(dplyr)
library(fmsb)

# read in
dBHI <- read.csv("/development of BHI/typical_dBHI_Ctl.csv")
child_info <- read.csv("/child_info.csv")
group <- read.csv("/BHI and self-reports/child_feeling_group.csv")

dBHI_child <- merge(child_info, group, by = "ID", all = TRUE)
dBHI_child <- merge(dBHI_child, dBHI, by = "ID", all = TRUE)

# delete data without dBHI
dBHI_child <- dBHI_child[dBHI_child$ID != 231125091, ]
dBHI_child <- dBHI_child[rowSums(is.na(dBHI_child)) < ncol(dBHI_child), ]

columns_to_scale <- grep("High", colnames(dBHI_child), value = TRUE)

# convert to Z score
dBHI_child[columns_to_scale] <- scale(dBHI_child[columns_to_scale])

## Fear 
# Heart to Brain
high_fear_means <- colMeans(dBHI_child[dBHI_child$Fear_indivd == 1, c("LF2d_High_Fear", "LF2t_High_Fear", "LF2a_High_Fear", "LF2b_High_Fear", "LF2g_High_Fear", "HF2d_High_Fear", "HF2t_High_Fear", "HF2a_High_Fear", "HF2b_High_Fear", "HF2g_High_Fear")])
low_fear_means <- colMeans(dBHI_child[dBHI_child$Fear_indivd == -1, c("LF2d_High_Fear", "LF2t_High_Fear", "LF2a_High_Fear", "LF2b_High_Fear", "LF2g_High_Fear", "HF2d_High_Fear", "HF2t_High_Fear", "HF2a_High_Fear", "HF2b_High_Fear", "HF2g_High_Fear")])

data_radar <- rbind(rep(0.5, 10), rep(-0.5, 10), high_fear_means, low_fear_means)
colnames(data_radar) <- c("LF2d_High_Fear", "LF2t_High_Fear", "LF2a_High_Fear", "LF2b_High_Fear", "LF2g_High_Fear", "HF2d_High_Fear", "HF2t_High_Fear", "HF2a_High_Fear", "HF2b_High_Fear", "HF2g_High_Fear")
data_radar <- as.data.frame(data_radar)

Fear_vlabels = gsub("_High_Fear", "", colnames(data_radar)[1:ncol(data_radar)])
caxis_labels = round(seq(-0.5, 0.5, length.out = 5), 2)

radarchart(data_radar,
           axistype = 0,
           pcol = c("blue", "lightblue"),
           pfcol = c(rgb(0, 0, 1, 0.5), rgb(0.678, 0.847, 0.902, 0.5)), 
           plwd = 2,
           plty = 1,
           title = "Radar Chart of Fear",
           cglcol = "grey",
           cglty = 1,
           caxislabels = caxis_labels,  
           cglwd = 2,
           vlabels = Fear_vlabels,  
           cex.axis = 0.4,  
           cex.main = 0.9)  

# brain to Heart
high_fear_means <- colMeans(dBHI_child[dBHI_child$Fear_indivd == 1, c("d2LF_High_Fear", "t2LF_High_Fear", "a2LF_High_Fear", "b2LF_High_Fear", "g2LF_High_Fear", "d2HF_High_Fear", "t2HF_High_Fear", "a2HF_High_Fear", "b2HF_High_Fear", "g2HF_High_Fear")])
low_fear_means <- colMeans(dBHI_child[dBHI_child$Fear_indivd == -1, c("d2LF_High_Fear", "t2LF_High_Fear", "a2LF_High_Fear", "b2LF_High_Fear", "g2LF_High_Fear", "d2HF_High_Fear", "t2HF_High_Fear", "a2HF_High_Fear", "b2HF_High_Fear", "g2HF_High_Fear")])
data_radar <- rbind(rep(0.5, 10), rep(-0.5, 10), high_fear_means, low_fear_means)
colnames(data_radar) <- c("d2LF", "t2LF", "a2LF", "b2LF", "g2LF", "d2HF", "t2HF", "a2HF", "b2HF", "g2HF")
data_radar <- as.data.frame(data_radar)
Fear_vlabels = colnames(data_radar)
caxis_labels = round(seq(-0.5, 0.5, length.out = 5), 2)
radarchart(data_radar,
           axistype = 0,
           pcol = c("blue", "lightblue"),
           pfcol = c(rgb(0, 0, 1, 0.5), rgb(0.678, 0.847, 0.902, 0.5)), 
           plwd = 2,
           plty = 1,
           title = "Radar Chart of Fear",
           cglcol = "grey",
           cglty = 1,
           axislabcol = NA,  
           caxislabels = caxis_labels,  
           cglwd = 2,
           vlabels = Fear_vlabels,  
           cex.axis = 0.4,  
           cex.main = 0.9) 

## Happy 
# Heart to Brain
high_happy_means <- colMeans(dBHI_child[dBHI_child$Happy_indivd == 1, c("LF2d_High_Happy", "LF2t_High_Happy", "LF2a_High_Happy", "LF2b_High_Happy", "LF2g_High_Happy", "HF2d_High_Happy", "HF2t_High_Happy", "HF2a_High_Happy", "HF2b_High_Happy", "HF2g_High_Happy")])
low_happy_means <- colMeans(dBHI_child[dBHI_child$Happy_indivd == -1, c("LF2d_High_Happy", "LF2t_High_Happy", "LF2a_High_Happy", "LF2b_High_Happy", "LF2g_High_Happy", "HF2d_High_Happy", "HF2t_High_Happy", "HF2a_High_Happy", "HF2b_High_Happy", "HF2g_High_Happy")])
data_radar <- rbind(rep(0.5, 10), rep(-0.5, 10), high_happy_means, low_happy_means)
colnames(data_radar) <- c("LF2d_High_Happy", "LF2t_High_Happy", "LF2a_High_Happy", "LF2b_High_Happy", "LF2g_High_Happy", "HF2d_High_Happy", "HF2t_High_Happy", "HF2a_High_Happy", "HF2b_High_Happy", "HF2g_High_Happy")
data_radar <- as.data.frame(data_radar)
Happy_vlabels = gsub("_High_Happy", "", colnames(data_radar)[1:ncol(data_radar)])
caxis_labels = round(seq(-0.5, 0.5, length.out = 5), 2)
radarchart(data_radar,
           axistype = 0,
           pcol = c("darkred", "lightcoral"), 
           pfcol = c(rgb(0.5, 0, 0, 0.5), rgb(1, 0.5, 0.5, 0.5)),  
           plwd = 2,
           plty = 1,
           title = "Radar Chart of Happy",
           cglcol = "grey",
           cglty = 1,
           axislabcol = NA,  
           caxislabels = caxis_labels, 
           cglwd = 2,
           vlabels = Happy_vlabels, 
           cex.axis = 0.4, 
           cex.main = 0.9) 

# brain to Heart
high_happy_means <- colMeans(dBHI_child[dBHI_child$Happy_indivd == 1, c("d2LF_High_Happy", "t2LF_High_Happy", "a2LF_High_Happy", "b2LF_High_Happy", "g2LF_High_Happy", "d2HF_High_Happy", "t2HF_High_Happy", "a2HF_High_Happy", "b2HF_High_Happy", "g2HF_High_Happy")])
low_happy_means <- colMeans(dBHI_child[dBHI_child$Happy_indivd == -1, c("d2LF_High_Happy", "t2LF_High_Happy", "a2LF_High_Happy", "b2LF_High_Happy", "g2LF_High_Happy", "d2HF_High_Happy", "t2HF_High_Happy", "a2HF_High_Happy", "b2HF_High_Happy", "g2HF_High_Happy")])
data_radar <- rbind(rep(0.5, 10), rep(-0.5, 10), high_happy_means, low_happy_means)
colnames(data_radar) <- c("d2LF", "t2LF", "a2LF", "b2LF", "g2LF", "d2HF", "t2HF", "a2HF", "b2HF", "g2HF")
data_radar <- as.data.frame(data_radar)
Happy_vlabels = colnames(data_radar)
caxis_labels = round(seq(-0.5, 0.5, length.out = 5), 2)
radarchart(data_radar,
           axistype = 0,
           pcol = c("darkred", "lightcoral"), 
           pfcol = c(rgb(0.5, 0, 0, 0.5), rgb(1, 0.5, 0.5, 0.5)), 
           plwd = 2,
           plty = 1,
           title = "Radar Chart of Happy",
           cglcol = "grey",
           cglty = 1,
           axislabcol = NA,  
           caxislabels = caxis_labels,  
           cglwd = 2,
           vlabels = Happy_vlabels,  
           cex.axis = 0.4, 
           cex.main = 0.9)  

