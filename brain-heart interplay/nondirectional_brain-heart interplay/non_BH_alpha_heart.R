## nondirection brain-heart interplay
## This script generates scatter plots to visualize 
## the relationship between dynamic EEG alpha power fluctuations and cardiac activties.

library(openxlsx)
library(ggplot2)
library(ggpubr)
library(reshape2)
library(tidyr) 
library(dplyr)

# read in
# combine brain, heart dynamics
heart_dym <- read.csv("/eliciting effects/movie_Heart_dym.csv")[, -1]
brain_dym <- read.csv("/eliciting effects/movie_brain_dyn.csv")[, -1]
movie_dym <- cbind(heart_dym, brain_dym)

   
# Reshape the data 
fear_alpha_long <- movie_dym %>%
  select(Fear_Falpha, Fear_Calpha, Fear_Palpha, Fear_IBI, Fear_HF, Fear_LF) %>%
  pivot_longer(cols = c("Fear_Falpha", "Fear_Calpha", "Fear_Palpha"),
               names_to = "Region", 
               values_to = "Value") %>%
  mutate(Value = as.numeric(Value))

happy_alpha_long <- movie_dym %>%
  select(Happy_Falpha, Happy_Calpha, Happy_Palpha, Happy_IBI, Happy_HF, Happy_LF) %>%
  pivot_longer(cols = c("Happy_Falpha", "Happy_Calpha", "Happy_Palpha"),
               names_to = "Region", 
               values_to = "Value") %>%
  mutate(Value = as.numeric(Value))

p_fear_IBI_alpha <- ggplot(fear_alpha_long, aes(x = Fear_IBI, y = Value, color = Region)) +
  geom_point(size = 5, alpha = 0.5) +  # Points size
  geom_smooth(method = "lm", se = TRUE, aes(fill = Region), alpha = 0.2, size = 2) +  
  scale_color_manual(values = c("Fear_Falpha" = "red", "Fear_Calpha" = "blue", "Fear_Palpha" = "black")) +  
  scale_fill_manual(values = c("Fear_Falpha" = "red", "Fear_Calpha" = "blue", "Fear_Palpha" = "black")) +  
  stat_cor(data = subset(fear_alpha_long, Region == "Fear_Falpha"), method = "pearson", 
           label.x = -70, 
           label.y = max(fear_alpha_long$Value, na.rm = TRUE) * 0.9, 
           label.y.npc = "top", 
           p.accuracy = 0.001) + 
  stat_cor(data = subset(fear_alpha_long, Region == "Fear_Calpha"), method = "pearson", 
           label.x = -70, 
           label.y = max(fear_alpha_long$Value, na.rm = TRUE) * 0.85,
           label.y.npc = "top", 
           p.accuracy = 0.001) + 
  stat_cor(data = subset(fear_alpha_long, Region == "Fear_Palpha"), method = "pearson", 
           label.x = -70, 
           label.y = max(fear_alpha_long$Value, na.rm = TRUE) * 0.80, 
           label.y.npc = "top", 
           p.accuracy = 0.001) + 
  scale_x_continuous(breaks = pretty(movie_dym$Fear_IBI)) + 
  theme_minimal(base_size = 14, base_family = "sans") + 
  theme(panel.background = element_rect(fill = "white"),  
        axis.ticks.y = element_line(color = "black"),  
        axis.ticks.x = element_line(color = "black"), 
        axis.line = element_line(color = "black"), 
        panel.border = element_rect(color = "black", fill = NA, size = 2),  
        panel.grid = element_blank(),
        axis.title = element_text(size = 10, face = "bold"), 
        axis.text = element_text(size = 18, face = "bold"),  
        plot.title = element_text(size = 10, face = "bold")) + 
  theme(legend.position = "none") +
  labs(x = "Fear IBI", y = "EEG alpha")  

ggsave("/brain-heart interplay/nondirectional_brain-heart interplay/fig/p_fear_IBI_alpha.png", plot = p_fear_IBI_alpha, width = 10, height = 10, dpi = 1200)

p_fear_HF_alpha <- ggplot(fear_alpha_long, aes(x = Fear_HF, y = Value, color = Region)) +
  geom_point(size = 5, alpha = 0.5) +  # Points size
  geom_smooth(method = "lm", se = TRUE, aes(fill = Region), alpha = 0.2, size = 2) +  
  scale_color_manual(values = c("Fear_Falpha" = "red", "Fear_Calpha" = "blue", "Fear_Palpha" = "black")) +  
  scale_fill_manual(values = c("Fear_Falpha" = "red", "Fear_Calpha" = "blue", "Fear_Palpha" = "black")) +  
  stat_cor(data = subset(fear_alpha_long, Region == "Fear_Falpha"), method = "pearson", 
           label.x = -0.35, 
           label.y = max(fear_alpha_long$Value, na.rm = TRUE) * 0.95,  
           label.y.npc = "top", 
           p.accuracy = 0.001) +  
  stat_cor(data = subset(fear_alpha_long, Region == "Fear_Calpha"), method = "pearson", 
           label.x = -0.35, 
           label.y = max(fear_alpha_long$Value, na.rm = TRUE) * 0.9,  
           label.y.npc = "top", 
           p.accuracy = 0.001) + 
  stat_cor(data = subset(fear_alpha_long, Region == "Fear_Palpha"), method = "pearson", 
           label.x = -0.35, 
           label.y = max(fear_alpha_long$Value, na.rm = TRUE) * 0.85, 
           label.y.npc = "top", 
           p.accuracy = 0.001) +  
  scale_x_continuous(breaks = pretty(movie_dym$Fear_HF)) +  
  theme_minimal(base_size = 14, base_family = "sans") + 
  theme(panel.background = element_rect(fill = "white"),  
        axis.ticks.y = element_line(color = "black"),  
        axis.ticks.x = element_line(color = "black"), 
        axis.line = element_line(color = "black"), 
        panel.border = element_rect(color = "black", fill = NA, size = 2), 
        panel.grid = element_blank(),
        axis.title = element_text(size = 10, face = "bold"), 
        axis.text = element_text(size = 18, face = "bold"),  
        plot.title = element_text(size = 10, face = "bold")) +  
  theme(legend.position = "none") +
  labs(x = "Fear HF", y = "EEG alpha") 

ggsave("/brain-heart interplay/nondirectional_brain-heart interplay/fig/p_fear_HF_alpha.png", plot = p_fear_HF_alpha, width = 10, height = 10, dpi = 1200)

p_fear_LF_alpha <- ggplot(fear_alpha_long, aes(x = Fear_LF, y = Value, color = Region)) +
  geom_point(size = 5, alpha = 0.5) +  
  geom_smooth(method = "lm", se = TRUE, aes(fill = Region), alpha = 0.2,size = 2) +  
  scale_color_manual(values = c("Fear_Falpha" = "red", "Fear_Calpha" = "blue", "Fear_Palpha" = "black")) +  
  scale_fill_manual(values = c("Fear_Falpha" = "red", "Fear_Calpha" = "blue", "Fear_Palpha" = "black")) + 
  stat_cor(data = subset(fear_alpha_long, Region == "Fear_Falpha"), method = "pearson", 
           label.x = -0.9, 
           label.y = max(fear_alpha_long$Value, na.rm = TRUE) * 0.95,  
           label.y.npc = "top", 
           p.accuracy = 0.001) +  
  stat_cor(data = subset(fear_alpha_long, Region == "Fear_Calpha"), method = "pearson", 
           label.x = -0.9, 
           label.y = max(fear_alpha_long$Value, na.rm = TRUE) * 0.9, 
           label.y.npc = "top", 
           p.accuracy = 0.001) + 
  stat_cor(data = subset(fear_alpha_long, Region == "Fear_Palpha"), method = "pearson", 
           label.x = -0.9, 
           label.y = max(fear_alpha_long$Value, na.rm = TRUE) * 0.85,  
           label.y.npc = "top", 
           p.accuracy = 0.001) + 
  scale_x_continuous(breaks = pretty(movie_dym$Fear_LF)) +  
  theme_minimal(base_size = 14, base_family = "sans") + 
  theme(panel.background = element_rect(fill = "white"),  
        axis.ticks.y = element_line(color = "black"), 
        axis.ticks.x = element_line(color = "black"),  
        axis.line = element_line(color = "black"),  
        panel.border = element_rect(color = "black", fill = NA, size = 2), 
        panel.grid = element_blank(),
        axis.title = element_text(size = 10, face = "bold"),  
        axis.text = element_text(size = 18, face = "bold"),  
        plot.title = element_text(size = 10, face = "bold")) + 
  theme(legend.position = "none") +
  labs(x = "Fear LF", y = "EEG alpha") 

ggsave("/brain-heart interplay/nondirectional_brain-heart interplay/fig/p_fear_LF_alpha.png", plot = p_fear_LF_alpha, width = 10, height = 10, dpi = 1200)


p_happy_IBI_alpha <- ggplot(happy_alpha_long, aes(x = Happy_IBI, y = Value, color = Region)) +
  geom_point(size = 5, alpha = 0.5) +  
  geom_smooth(method = "lm", se = TRUE, aes(fill = Region), alpha = 0.2,size = 2) + 
  scale_color_manual(values = c("Happy_Falpha" = "red", "Happy_Calpha" = "blue", "Happy_Palpha" = "black")) + 
  scale_fill_manual(values = c("Happy_Falpha" = "red", "Happy_Calpha" = "blue", "Happy_Palpha" = "black")) +  
  stat_cor(data = subset(happy_alpha_long, Region == "Happy_Falpha"), method = "pearson", 
           label.x = -30, 
           label.y = max(happy_alpha_long$Value, na.rm = TRUE) * 0.9, 
           label.y.npc = "top", 
           p.accuracy = 0.001) + 
  stat_cor(data = subset(happy_alpha_long, Region == "Happy_Calpha"), method = "pearson", 
           label.x = -30, 
           label.y = max(happy_alpha_long$Value, na.rm = TRUE) * 0.85,  
           label.y.npc = "top", 
           p.accuracy = 0.001) +
  stat_cor(data = subset(happy_alpha_long, Region == "Happy_Palpha"), method = "pearson", 
           label.x = -30, 
           label.y = max(happy_alpha_long$Value, na.rm = TRUE) * 0.80,  
           label.y.npc = "top", 
           p.accuracy = 0.001) + 
  scale_x_continuous(breaks = pretty(movie_dym$Happy_IBI)) +  
  theme_minimal(base_size = 14, base_family = "sans") + 
  theme(panel.background = element_rect(fill = "white"), 
        axis.ticks.y = element_line(color = "black"),  
        axis.ticks.x = element_line(color = "black"), 
        axis.line = element_line(color = "black"), 
        panel.border = element_rect(color = "black", fill = NA, size = 2), 
        panel.grid = element_blank(),
        axis.title = element_text(size = 10, face = "bold"),
        axis.text = element_text(size = 18, face = "bold"),  
        plot.title = element_text(size = 10, face = "bold")) + 
  theme(legend.position = "none") +
  labs(x = "Happy IBI", y = "EEG alpha") 

ggsave("/brain-heart interplay/nondirectional_brain-heart interplay/fig/p_happy_IBI_alpha.png", plot = p_happy_IBI_alpha, width = 10, height = 10, dpi = 1200)

p_happy_HF_alpha <- ggplot(happy_alpha_long, aes(x = Happy_HF, y = Value, color = Region)) +
  geom_point(size = 5, alpha = 0.5) + 
  geom_smooth(method = "lm", se = TRUE, aes(fill = Region), alpha = 0.2, size = 2) +  
  scale_color_manual(values = c("Happy_Falpha" = "red", "Happy_Calpha" = "blue", "Happy_Palpha" = "black")) + 
  scale_fill_manual(values = c("Happy_Falpha" = "red", "Happy_Calpha" = "blue", "Happy_Palpha" = "black")) +
  stat_cor(data = subset(happy_alpha_long, Region == "Happy_Falpha"), method = "pearson", 
           label.x = -0.25, 
           label.y = max(happy_alpha_long$Value, na.rm = TRUE) * 0.95,  
           label.y.npc = "top", 
           p.accuracy = 0.001,size = 3) +  
  stat_cor(data = subset(happy_alpha_long, Region == "Happy_Calpha"), method = "pearson", 
           label.x = -0.25, 
           label.y = max(happy_alpha_long$Value, na.rm = TRUE) * 0.9, 
           label.y.npc = "top", 
           p.accuracy = 0.001,size = 3) +  
  stat_cor(data = subset(happy_alpha_long, Region == "Happy_Palpha"), method = "pearson", 
           label.x = -0.25, 
           label.y = max(happy_alpha_long$Value, na.rm = TRUE) * 0.85, 
           label.y.npc = "top", 
           p.accuracy = 0.001,size = 3) +  
  scale_x_continuous(breaks = pretty(movie_dym$Happy_HF)) +  
  theme_minimal(base_size = 14, base_family = "sans") + 
  theme(panel.background = element_rect(fill = "white"), 
        axis.ticks.y = element_line(color = "black"),  
        axis.ticks.x = element_line(color = "black"), 
        axis.line = element_line(color = "black"),  
        panel.border = element_rect(color = "black", fill = NA, size = 2), 
        panel.grid = element_blank(),
        axis.title = element_text(size = 10, face = "bold"),  
        axis.text = element_text(size = 18, face = "bold"),  
        plot.title = element_text(size = 10, face = "bold")) +  
  theme(legend.position = "none") +
  labs(x = "Happy HF", y = "EEG alpha")  

ggsave("/brain-heart interplay/nondirectional_brain-heart interplay/fig/p_happy_HF_alpha.png", plot = p_happy_HF_alpha, width = 10, height = 10, dpi = 1200)

p_happy_LF_alpha <- ggplot(happy_alpha_long, aes(x = Happy_LF, y = Value, color = Region)) +
  geom_point(size = 5, alpha = 0.5) +  
  geom_smooth(method = "lm", se = TRUE, aes(fill = Region), alpha = 0.2, size = 2) +  
  scale_color_manual(values = c("Happy_Falpha" = "red", "Happy_Calpha" = "blue", "Happy_Palpha" = "black")) + 
  scale_fill_manual(values = c("Happy_Falpha" = "red", "Happy_Calpha" = "blue", "Happy_Palpha" = "black")) +  
  stat_cor(data = subset(happy_alpha_long, Region == "Happy_Falpha"), method = "pearson", 
           label.x = -0.08, 
           label.y = min(happy_alpha_long$Value, na.rm = TRUE) * 0.95,  
           label.y.npc = "top", 
           p.accuracy = 0.001) +  
  stat_cor(data = subset(happy_alpha_long, Region == "Happy_Calpha"), method = "pearson", 
           label.x = -0.08, 
           label.y = min(happy_alpha_long$Value, na.rm = TRUE) * 0.9, 
           label.y.npc = "top", 
           p.accuracy = 0.001) +  
  stat_cor(data = subset(happy_alpha_long, Region == "Happy_Palpha"), method = "pearson", 
           label.x = -0.08, 
           label.y = min(happy_alpha_long$Value, na.rm = TRUE) * 0.85,  
           label.y.npc = "top", 
           p.accuracy = 0.001) +  
  scale_x_continuous(breaks = pretty(movie_dym$Happy_LF)) + 
  theme_minimal(base_size = 14, base_family = "sans") + 
  theme(panel.background = element_rect(fill = "white"),  
        axis.ticks.y = element_line(color = "black"),  
        axis.ticks.x = element_line(color = "black"),  
        axis.line = element_line(color = "black"), 
        panel.border = element_rect(color = "black", fill = NA, size = 2), 
        panel.grid = element_blank(),
        axis.title = element_text(size = 10, face = "bold"),  
        axis.text = element_text(size = 18, face = "bold"),  
        plot.title = element_text(size = 10, face = "bold")) +  
  theme(legend.position = "none") +
  labs(x = "Happy LF", y = "EEG alpha")  

ggsave("/brain-heart interplay/nondirectional_brain-heart interplay/fig/p_happy_LF_alpha.png", plot = p_happy_LF_alpha, width = 10, height = 10, dpi = 1200)
