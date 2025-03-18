
## This script visualizes the association between nondirectional brain-heart correlation and child age.

library(ggplot2)
library(dplyr)
library(fmsb)

# read in
non_BH <- read.csv("/brain-heart interplay/nondirectional_brain-heart interplay/nondi_BH_r.csv")
child_info <- read.csv("/child_info.csv")

BH_child <- merge(child_info, non_BH, by = "ID", all = TRUE)

# plot central montage for visualization
# Fear
FENE_Ctl_cols <- grep("FENE.*Central", colnames(BH_child), value = TRUE)
FE_Ctl <- BH_child[, c("Age_month", FENE_Ctl_cols)]

# compute Pearson's r between nonBH and age/month
cor_values <- sapply(FE_Ctl[, -1], function(x) cor(x, FE_Ctl$Age_month, use = "complete.obs"))

radar_data <- rbind(rep(0.4, length(cor_values)), 
                    rep(-0.4, length(cor_values)),  
                    cor_values) 

colnames(radar_data) <- names(cor_values)
Fear_vlabels = gsub("FE", "", colnames(radar_data)[1:ncol(radar_data)])

radar_data <- as.data.frame(radar_data)

# plot radar
radarchart(radar_data, 
           axistype = 0,         
           pcol = "#1172BF",        
           plwd = 10,              
           cglcol = "gray",      
           cglty = 2,             
           cglwd = 4,
           axislabcol = "black",  
           vlabels = Fear_vlabels,  
           vlcex = 0.3)   

# plot signicant relationship through scatters
# IBI-delta and age
fe_IBI-d_age <- ggscatter(FE_Ctl, x = "Age_month", y = "r_FENE_delta_Central_IBI",
                       add = "reg.line", conf.int = TRUE,    
                       add.params = list(fill = "lightgray", size = 4),
                       color = "#1172BF",
                       size = 8,alpha = 0.6,
                       ggtheme = theme_minimal()) +
  stat_cor(method = "pearson", 
           label.x = 60, label.y = -0.6, 
           label.y.npc = "top",   
           p.accuracy = 0.001  
           
  ) +  
  scale_x_continuous(breaks = pretty(FE_Ctl$Age_month)) + 
  theme(axis.ticks.y = element_line(color = "black"),  
        axis.ticks.x = element_line(color = "black"),  
        axis.line = element_line(color = "black"),  
        panel.border = element_rect(color = "black", fill = NA, size = 4),  
        panel.grid = element_blank(),
        axis.title = element_text(size = 10, face = "bold"), 
        axis.text = element_text(size = 18, face = "bold"),  
        plot.title = element_text(size = 10, face = "bold"))  
# IBI-theta and age
fe_IBI-t_age <- ggscatter(FE_Ctl, x = "Age_month", y = "r_FENE_theta_Central_IBI",
                          add = "reg.line", conf.int = TRUE,    
                          add.params = list(fill = "lightgray", size = 4),
                          color = "#1172BF",
                          size = 8,alpha = 0.6,
                          ggtheme = theme_minimal()) +
  stat_cor(method = "pearson", 
           label.x = 60, label.y = -0.6, 
           label.y.npc = "top",   
           p.accuracy = 0.001  
           
  ) +  
  scale_x_continuous(breaks = pretty(FE_Ctl$Age_month)) + 
  theme(axis.ticks.y = element_line(color = "black"),  
        axis.ticks.x = element_line(color = "black"),  
        axis.line = element_line(color = "black"),  
        panel.border = element_rect(color = "black", fill = NA, size = 4),  
        panel.grid = element_blank(),
        axis.title = element_text(size = 10, face = "bold"), 
        axis.text = element_text(size = 18, face = "bold"),  
        plot.title = element_text(size = 10, face = "bold"))  

## Happy
HANE_Ctl_cols <- grep("HANE.*Central", colnames(BH_child), value = TRUE)
HA_Ctl <- BH_child[, c("Age_month", HANE_Ctl_cols)]
cor_values <- sapply(HA_Ctl[, -1], function(x) cor(x, HA_Ctl$Age_month, use = "complete.obs"))
radar_data <- rbind(rep(0.4, length(cor_values)),  
                    rep(-0.4, length(cor_values)), 
                    cor_values) 

colnames(radar_data) <- names(cor_values)
Happy_vlabels = gsub("HA", "", colnames(radar_data)[1:ncol(radar_data)])
radar_data <- as.data.frame(radar_data)
radarchart(radar_data, 
           axistype = 0,          
           pcol = "#C60700",         
           plwd = 10,             
           cglcol = "gray",       
           cglty = 2,            
           cglwd = 4,
           axislabcol = "black",  
           caxislabels = round(seq(-0.4, 0.4, length = 5),2), 
           vlabels = Happy_vlabels, 
           vlcex = 0.2)

# plot signicant relationship through scatters
# HF-delta and age
ha_HF-d_age <- ggscatter(HA_Ctl, x = "Age_month", y = "r_HANE_delta_Central_HF",
                       add = "reg.line", conf.int = TRUE,    
                       add.params = list(fill = "lightgray", size = 4),
                       color ="#C60700",
                       size = 8,alpha = 0.6,
                       ggtheme = theme_minimal()) +
  stat_cor(method = "pearson", 
           label.x = 60, label.y = -0.3, 
           label.y.npc = "top",  
           p.accuracy = 0.001  
  ) +  
  scale_x_continuous(breaks = pretty(HA_Ctl$Age_month)) +  
  theme(axis.ticks.y = element_line(color = "black"),  
        axis.ticks.x = element_line(color = "black"), 
        axis.line = element_line(color = "black"), 
        panel.border = element_rect(color = "black", fill = NA, size = 4), 
        panel.grid = element_blank(),
        axis.title = element_text(size = 10, face = "bold"), 
        axis.text = element_text(size = 18, face = "bold"),   
        plot.title = element_text(size = 10, face = "bold"))  
# LF-gamma and age
ha_LF-g_age <- ggscatter(HA_Ctl, x = "Age_month", y = "r_HANE_gamma_Central_LF",
                         add = "reg.line", conf.int = TRUE,    
                         add.params = list(fill = "lightgray", size = 4),
                         color ="#C60700",
                         size = 8,alpha = 0.6,
                         ggtheme = theme_minimal()) +
  stat_cor(method = "pearson", 
           label.x = 60, label.y = -0.3, 
           label.y.npc = "top",  
           p.accuracy = 0.001  
  ) +  
  scale_x_continuous(breaks = pretty(HA_Ctl$Age_month)) +  
  theme(axis.ticks.y = element_line(color = "black"),  
        axis.ticks.x = element_line(color = "black"), 
        axis.line = element_line(color = "black"), 
        panel.border = element_rect(color = "black", fill = NA, size = 4), 
        panel.grid = element_blank(),
        axis.title = element_text(size = 10, face = "bold"), 
        axis.text = element_text(size = 18, face = "bold"),   
        plot.title = element_text(size = 10, face = "bold"))  
