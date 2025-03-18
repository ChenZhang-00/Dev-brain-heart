## This script visualizes the association between directional brain-heart interplay and child age.

library(ggplot2)
library(dplyr)
library(fmsb)

# read in
dBHI <- read.csv("/development of BHI/typical_dBHI_Ctl.csv")
child_info <- read.csv("/child_info.csv")

dBHI_child <- merge(child_info, dBHI, by = "ID", all = TRUE)

## plot central montage for visualization
## Fear 
## Heart to Brain
high_fear_cols <- grep("High_Fear", colnames(dBHI_child), value = TRUE)
high_fear <- dBHI_child[, c("Age_month", high_fear_cols)]

cols_to_select <- grep("^LF2|^HF2", colnames(high_fear)) 
data_high_fear <- high_fear[, c(1, cols_to_select)]  

# Pearson's r
cor_values <- sapply(data_high_fear[, -1], function(x) cor(x, data_high_fear$Age_month, use = "complete.obs"))

max_val <- max(cor_values, na.rm = TRUE) + 0.1 
min_val <- min(cor_values, na.rm = TRUE) - 0.1  

radar_data <- rbind(rep(0.4, length(cor_values)), 
                    rep(-0.2, length(cor_values)), 
                    cor_values)  

colnames(radar_data) <- names(cor_values)
Fear_vlabels = gsub("_High_Fear", "", colnames(radar_data)[1:ncol(radar_data)])

radar_data <- as.data.frame(radar_data)
radarchart(radar_data, 
           axistype = 0,          
           pcol = "#1172BF",        
           plwd = 10,              
           cglcol = "gray",     
           cglty = 2,            
           cglwd = 4,
           axislabcol = "black",  
           # caxislabels = round(seq(-0.2, 0.4, length = 5),2), 
           vlabels = Fear_vlabels,  
           vlcex = 0.8)           

## Brain to Heart
cols_to_select <- grep("^d2|^t2|^a2|^b2|^g2", colnames(high_fear))  
data_high_fear <- high_fear[, c(1, cols_to_select)]  
cor_values <- sapply(data_high_fear[, -1], function(x) cor(x, data_high_fear$Age_month, use = "complete.obs"))
max_val <- max(cor_values, na.rm = TRUE) + 0.1  
min_val <- min(cor_values, na.rm = TRUE) - 0.1  

radar_data <- rbind(rep(0.4, length(cor_values)), 
                    rep(-0.2, length(cor_values)),  
                    cor_values)  
colnames(radar_data) <- names(cor_values)
Fear_vlabels = gsub("_High_Fear", "", colnames(radar_data)[1:ncol(radar_data)])
radar_data <- as.data.frame(radar_data)
radarchart(radar_data, 
           axistype = 0,         
           pcol = "#1172BF",       
           plwd = 10,             
           cglcol = "grey",      
           cglty = 2,            
           cglwd = 4,
           axislabcol = "black",  
           # caxislabels = round(seq(-0.2, 0.4, length = 5),2),  
           vlabels = Fear_vlabels,  
           vlcex = 0.8)          

## Happy 
## Heart to Brain
high_happy_cols <- grep("High_Happy", colnames(dBHI_child), value = TRUE)
high_happy <- dBHI_child[, c("Age_month", high_happy_cols)]
cols_to_select <- grep("^LF2|^HF2", colnames(high_happy)) 
data_high_happy <- high_happy[, c(1, cols_to_select)]  
cor_values <- sapply(data_high_happy[, -1], function(x) cor(x, data_high_happy$Age_month, use = "complete.obs"))
max_val <- max(cor_values, na.rm = TRUE) + 0.1 
min_val <- min(cor_values, na.rm = TRUE) - 0.1  
radar_data <- rbind(rep(0.4, length(cor_values)), 
                    rep(-0.2, length(cor_values)), 
                    cor_values)  
colnames(radar_data) <- names(cor_values)
Happy_vlabels = gsub("_High_Happy", "", colnames(radar_data)[1:ncol(radar_data)])
radar_data <- as.data.frame(radar_data)
radarchart(radar_data, 
           axistype = 0,         
           pcol = "#C60700",         
           plwd = 10,             
           cglcol = "grey",      
           cglty = 2,            
           cglwd = 4,
           axislabcol = "black",  
           # caxislabels = round(seq(-0.2, 0.4, length = 5),2),  
           vlabels = Happy_vlabels,  
           vlcex = 0.8)           

## Brain to Heart
cols_to_select <- grep("^d2|^t2|^a2|^b2|^g2", colnames(high_happy)) 
data_high_happy <- high_happy[, c(1, cols_to_select)] 
cor_values <- sapply(data_high_happy[, -1], function(x) cor(x, data_high_happy$Age_month, use = "complete.obs"))
max_val <- max(cor_values, na.rm = TRUE) + 0.1  
min_val <- min(cor_values, na.rm = TRUE) - 0.1  
radar_data <- rbind(rep(0.4, length(cor_values)),  
                    rep(-0.2, length(cor_values)), 
                    cor_values) 
colnames(radar_data) <- names(cor_values)
Happy_vlabels = gsub("_High_Happy", "", colnames(radar_data)[1:ncol(radar_data)])
radar_data <- as.data.frame(radar_data)
radarchart(radar_data, 
           axistype = 0,          
           pcol = "#C60700",        
           plwd = 10,             
           cglcol = "grey",       
           cglty = 2,            
           cglwd = 4,
           axislabcol = "black", 
           # caxislabels = round(seq(-0.2, 0.4, length = 5),2),  
           vlabels = Happy_vlabels, 
           vlcex = 0.8)         