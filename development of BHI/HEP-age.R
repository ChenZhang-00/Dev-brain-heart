## This script visualizes the association between HEP and child age.

library(ggplot2)
library(dplyr)
library(fmsb)

# read in
HEP <- read.csv("/brain-heart interplay/HEP/HEP_for_each.csv")
child_info <- read.csv("/child_info.csv")
HEP_child <- merge(child_info, HEP, by = "ID", all = TRUE)

HEP_child$TEP100_FeNe_Ftl <- HEP_child$TEP_100_Fear_Ftl - HEP_child$TEP_100_Neutral_Ftl
TEP_age_fe_Ftl <- ggscatter(HEP_child, x = "Age_month", y = "TEP100_FeNe_Ftl",
                       add = "reg.line", conf.int = TRUE,    
                       add.params = list(fill = "lightgray", size = 4),
                       color ="#1172BF",
                       size = 8,alpha = 0.6,
                       ggtheme = theme_minimal()) +
  stat_cor(method = "pearson", 
           label.x = 110, label.y = 2.5, 
           label.y.npc = "top",  
           p.accuracy = 0.001  
  ) + 
  scale_x_continuous(breaks = seq(60, 120, by = 12), 
                     labels = seq(5, 10, by = 1)) +   
  theme(axis.ticks.y = element_line(color = "black"),  
        axis.ticks.x = element_line(color = "black"),  
        axis.line = element_line(color = "black"), 
        panel.border = element_rect(color = "black", fill = NA, size = 4),  
        panel.grid = element_blank(),
        axis.title = element_text(size = 10, face = "bold"), 
        axis.text = element_text(size = 18, face = "bold"),  
        plot.title = element_text(size = 10, face = "bold"))   

HEP_child$TEP100_NeFe_Ptr <- HEP_child$TEP_100_Neutral_Ptr - HEP_child$TEP_100_Fear_Ptr
TEP_age_fe_Ptr <- ggscatter(HEP_child, x = "Age_month", y = "TEP100_NeFe_Ptr",
                            add = "reg.line", conf.int = TRUE,    
                            add.params = list(fill = "lightgray", size = 4),
                            color ="#1172BF",
                            size = 8,alpha = 0.6,
                            ggtheme = theme_minimal()) +
  stat_cor(method = "pearson", 
           label.x = 110, label.y = 1.5, 
           label.y.npc = "top",  
           p.accuracy = 0.001
  ) +  
  scale_x_continuous(breaks = seq(60, 120, by = 12),  
                     labels = seq(5, 10, by = 1)) +  
  theme(axis.ticks.y = element_line(color = "black"), 
        axis.ticks.x = element_line(color = "black"), 
        axis.line = element_line(color = "black"), 
        panel.border = element_rect(color = "black", fill = NA, size = 4),  
        panel.grid = element_blank(),
        axis.title = element_text(size = 10, face = "bold"),  
        axis.text = element_text(size = 18, face = "bold"),   
        plot.title = element_text(size = 10, face = "bold"))   

HEP_child$TEP100_HaNe_Ctl <- HEP_child$TEP_100_Happy_Ctl - HEP_child$TEP_100_Neutral_Ctl
TEP_age_ha_Ctl <- ggscatter(HEP_child, x = "Age_month", y = "TEP100_HaNe_Ctl",
                       add = "reg.line", conf.int = TRUE,    
                       add.params = list(fill = "lightgray", size = 4),
                       color = "#C60700",
                       size = 8,alpha = 0.6,
                       ggtheme = theme_minimal()) +
  stat_cor(method = "pearson", 
           label.x = 110, label.y = 1, 
           label.y.npc = "top",  
           p.accuracy = 0.001  
           
  ) +  
  scale_x_continuous(breaks = seq(60, 120, by = 12), 
                     labels = seq(5, 10, by = 1)) +   
  theme(axis.ticks.y = element_line(color = "black"),  
        axis.ticks.x = element_line(color = "black"), 
        axis.line = element_line(color = "black"), 
        panel.border = element_rect(color = "black", fill = NA, size = 4),  
        panel.grid = element_blank(),
        axis.title = element_text(size = 10, face = "bold"),  
        axis.text = element_text(size = 18, face = "bold"),   
        plot.title = element_text(size = 10, face = "bold"))   

