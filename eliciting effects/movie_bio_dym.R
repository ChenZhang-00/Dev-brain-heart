## This script generates scatter plots to visualize 
## the relationship between dynamic EEG alpha power fluctuations and emotional intensity.

library(openxlsx)
library(ggplot2)
library(ggpubr)
library(reshape2)
library(tidyr)
library(dplyr)

# read in
# combine brain, heart, and ratings dynamics
heart_dym <- read.csv("/eliciting effects/movie_Heart_dym.csv")[, -1]
brain_dym <- read.csv("/eliciting effects/movie_brain_dyn.csv")[, -1]
ratings_dym <- read.csv("/movie_emotion_editing/Movies_rating_by_RA.csv")[, -1]

# time 1-180s
heart_dym <- rbind(setNames(as.data.frame(matrix(NA, nrow = 2, ncol = ncol(heart_dym))), names(heart_dym)),
                   heart_dym, 
                   setNames(as.data.frame(matrix(NA, nrow = 2, ncol = ncol(heart_dym))), names(heart_dym)))
brain_dym <- rbind(setNames(as.data.frame(matrix(NA, nrow = 2, ncol = ncol(brain_dym))), names(brain_dym)),
                   brain_dym,
                   setNames(as.data.frame(matrix(NA, nrow = 2, ncol = ncol(brain_dym))), names(brain_dym)))
ratings_dym <- ratings_dym[1:180, ]
movie_dym <- bind_cols(Time = 1:180, ratings_dym, heart_dym, brain_dym)

## IBI
## Fear
# IBI and intensity
p_fe_IBI <- ggscatter(movie_dym, x = "Fear_Intensity", y = "Fear_IBI",
                      add = "reg.line", conf.int = TRUE,    
                      add.params = list(fill = "lightgray", size = 3),
                      color = "#1172BF", size = 7, alpha = 0.5,
                      ggtheme = theme_minimal()) +
  stat_cor(method = "pearson", 
           label.x = 3, label.y = -75, 
           label.y.npc = "top",   
           p.accuracy = 0.001) + 
  scale_x_continuous(breaks = pretty(movie_dym$Fear_Intensity)) +  
  theme(axis.ticks.y = element_line(color = "black"),  
        axis.ticks.x = element_line(color = "black"),  
        axis.line = element_line(color = "black"), 
        panel.border = element_rect(color = "black", fill = NA, size = 3), 
        panel.grid = element_blank(),
        axis.title = element_text(size = 10, face = "bold"), 
        axis.text = element_text(size = 18, face = "bold"),
        plot.title = element_text(size = 10, face = "bold"))

ggsave("/eliciting effects/fig/p_fe_IBI.png", plot = p_fe_IBI, width = 10, height = 10, dpi = 1200)

## Happy
# IBI and intensity
p_ha_IBI <- ggscatter(movie_dym, x = "Happy_Intensity", y = "Happy_IBI",
                       add = "reg.line", conf.int = TRUE,    
                       add.params = list(fill = "lightgray", size = 3),
                       color = "#C60700",  size = 7, alpha = 0.5,
                       ggtheme = theme_minimal()) +
  stat_cor(method = "pearson", 
           label.x = 0, label.y = -20, 
           label.y.npc = "top",   
           p.accuracy = 0.001) + 
  scale_x_continuous(breaks = pretty(movie_dym$Happy_Intensity)) + 
  theme(axis.ticks.y = element_line(color = "black"), 
        axis.ticks.x = element_line(color = "black"), 
        axis.line = element_line(color = "black"), 
        panel.border = element_rect(color = "black", fill = NA, size = 3),
        panel.grid = element_blank(),
        axis.title = element_text(size = 10, face = "bold"),  
        axis.text = element_text(size = 18, face = "bold"),  
        plot.title = element_text(size = 10, face = "bold"))   

ggsave("/eliciting effects/fig/p_ha_IBI.png", plot = p_ha_IBI, width = 10, height = 10, dpi = 1200)


## EEG alpha power dynamics
# Fear
# Reshape the data
fear_alpha_long <- movie_dym %>%
  select(Fear_Falpha, Fear_Calpha, Fear_Palpha, Fear_Intensity) %>%
  pivot_longer(cols = c("Fear_Falpha", "Fear_Calpha", "Fear_Palpha"),
               names_to = "Region", 
               values_to = "Value") %>%
  mutate(Value = as.numeric(Value))

# Create the scatter plot
p_fear_alpha <- ggplot(fear_alpha_long, aes(x = Fear_Intensity, y = Value, color = Region)) +
  geom_point(size = 7, alpha = 0.5) +  
  geom_smooth(method = "lm", se = TRUE, aes(fill = Region, size = 2), alpha = 0.2) +  
  scale_color_manual(values = c("Fear_Falpha" = "red", "Fear_Calpha" = "blue", "Fear_Palpha" = "black")) + 
  scale_fill_manual(values = c("Fear_Falpha" = "red", "Fear_Calpha" = "blue", "Fear_Palpha" = "black")) +  
  stat_cor(data = subset(fear_alpha_long, Region == "Fear_Falpha"), method = "pearson", 
           label.x = 3, 
           label.y = max(fear_alpha_long$Value, na.rm = TRUE) * 0.9, 
           label.y.npc = "top", 
           p.accuracy = 0.001) +  # Custom label format
  stat_cor(data = subset(fear_alpha_long, Region == "Fear_Calpha"), method = "pearson", 
           label.x = 3, 
           label.y = max(fear_alpha_long$Value, na.rm = TRUE) * 0.85, 
           label.y.npc = "top", 
           p.accuracy = 0.001) +  # Custom label format
  stat_cor(data = subset(fear_alpha_long, Region == "Fear_Palpha"), method = "pearson", 
           label.x = 3, 
           label.y = max(fear_alpha_long$Value, na.rm = TRUE) * 0.80,  
           label.y.npc = "top", 
           p.accuracy = 0.001) +  # Custom label format
  scale_x_continuous(breaks = pretty(movie_dym$Fear_Intensity)) +  
  theme_minimal(base_size = 14, base_family = "sans") + 
  theme(panel.background = element_rect(fill = "white"),  
        axis.ticks.y = element_line(color = "black"),  
        axis.ticks.x = element_line(color = "black"), 
        axis.line = element_line(color = "black"),  
        panel.border = element_rect(color = "black", fill = NA, size = 3),  
        panel.grid = element_blank(),
        axis.title = element_text(size = 10, face = "bold"),  
        axis.text = element_text(size = 18, face = "bold"),   
        plot.title = element_text(size = 10, face = "bold")) +  
  theme(legend.position = "none") +
  labs(x = "Fear Intensity", y = "EEG alpha")

ggsave("/eliciting effects/fig/p_fear_alpha.png", plot = p_fear_alpha, width = 10, height = 10, dpi = 1200)


# Happy
happy_alpha_long <- movie_dym %>%
  select(Happy_Falpha, Happy_Calpha, Happy_Palpha, Happy_Intensity) %>%
  pivot_longer(cols = c("Happy_Falpha", "Happy_Calpha", "Happy_Palpha"),
               names_to = "Region", 
               values_to = "Value") %>%
  mutate(Value = as.numeric(Value))  

p_happy_alpha <- ggplot(happy_alpha_long, aes(x = Happy_Intensity, y = Value, color = Region)) +
  geom_point(size = 7, alpha = 0.5) +  
  geom_smooth(method = "lm", se = TRUE, aes(fill = Region, size = 2), alpha = 0.2) +  
  scale_color_manual(values = c("Happy_Falpha" = "red", "Happy_Calpha" = "blue", "Happy_Palpha" = "black")) +  
  scale_fill_manual(values = c("Happy_Falpha" = "red", "Happy_Calpha" = "blue", "Happy_Palpha" = "black")) +  
  stat_cor(data = subset(happy_alpha_long, Region == "Happy_Falpha"), method = "pearson", 
           label.x = 1.6, 
           label.y = max(happy_alpha_long$Value, na.rm = TRUE) * 0.9, 
           label.y.npc = "top", 
           p.accuracy = 0.001) +  
  stat_cor(data = subset(happy_alpha_long, Region == "Happy_Calpha"), method = "pearson", 
           label.x = 1.6, 
           label.y = max(happy_alpha_long$Value, na.rm = TRUE) * 0.85, 
           label.y.npc = "top", 
           p.accuracy = 0.001) + 
  stat_cor(data = subset(happy_alpha_long, Region == "Happy_Palpha"), method = "pearson", 
           label.x = 1.6, 
           label.y = max(happy_alpha_long$Value, na.rm = TRUE) * 0.80, 
           label.y.npc = "top", 
           p.accuracy = 0.001) +  
  scale_x_continuous(breaks = pretty(movie_dym$Happy_Intensity)) + 
  theme_minimal(base_size = 14, base_family = "sans") + 
  theme(panel.background = element_rect(fill = "white"), 
        axis.ticks.y = element_line(color = "black"), 
        axis.ticks.x = element_line(color = "black"), 
        axis.line = element_line(color = "black"),
        panel.border = element_rect(color = "black", fill = NA, size = 3),
        panel.grid = element_blank(),
        axis.title = element_text(size = 10, face = "bold"), 
        axis.text = element_text(size = 18, face = "bold"),
        plot.title = element_text(size = 10, face = "bold")) + 
  theme(legend.position = "none") +
  labs(x = "Happy Intensity", y = "EEG alpha")  

ggsave("/eliciting effects/fig/p_happy_alpha.png", plot = p_happy_alpha, width = 10, height = 10, dpi = 1200)
