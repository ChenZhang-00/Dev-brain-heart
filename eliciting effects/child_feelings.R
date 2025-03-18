
## This script visualizes  children’s self-reported feelings following the movie viewing.
library(ggplot2)
library(tidyr)
library(dplyr)

child_info <- read.csv("/child_info.csv")

## minus neutral
A_fear_ne <- child_info$fear_A - child_info$neutral_A
V_fear_ne <- child_info$fear_V - child_info$neutral_V
A_happy_ne <- child_info$happy_A - child_info$neutral_A
V_happy_ne <- child_info$happy_V - child_info$neutral_V

## plot scatters to visualize children's self-reported feelings
movie_feeling_diff <- data.frame(
  Arousal = c(A_fear_ne, A_happy_ne),
  Valence = c(V_fear_ne, V_happy_ne),
  Emotion = rep(c("Fear", "Happy"), each = nrow(child_info)),
  ID = rep(child_info$ID, times = 2)
)

ggplot(movie_feeling_diff, aes(x = Arousal, y = Valence, color = Emotion)) +
  geom_point(position = position_jitter(width = 0.4, height = 0.4), size = 4) + 
  scale_color_manual(values = c("Fear" ="#1172BF", "Happy" = "#C60700")) + 
  scale_x_continuous(limits = c(min(movie_feeling_diff$Arousal) - 0.5, max(movie_feeling_diff$Arousal) + 0.5)) + 
  scale_y_continuous(limits = c(min(movie_feeling_diff$Valence) - 0.5, max(movie_feeling_diff$Valence) + 0.5)) + 
  labs(title = NULL,
       x = "Arousal",
       y = "Valence") +
  theme_minimal() +
  theme(legend.title = element_blank(),
        axis.text.x = element_text(face = "bold"), 
        axis.text.y = element_text(face = "bold"))+
  geom_vline(xintercept = seq(-8.5, 8.5, by = 1), color = "black", linetype = "dotted") +
  geom_hline(yintercept = seq(-8.5, 8.5,by = 1), color = "black", linetype = "dotted")

