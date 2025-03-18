
## This script compares cardiac responses (HRV & IBI) across Fear, Happy, and Neutral movie conditions.

library(ggplot2)
library(dplyr)
library(cowplot)    
library(patchwork)  

Heart_index <- read.csv("/eliciting effects/movie_heart.csv")

df_summary <- Heart_index %>%
  summarise(
    Fear_IBI_mean = mean(Fear_IBI, na.rm = TRUE), Fear_IBI_se = sd(Fear_IBI, na.rm = TRUE) / sqrt(sum(!is.na(Fear_IBI))),
    Happy_IBI_mean = mean(Happy_IBI, na.rm = TRUE), Happy_IBI_se = sd(Happy_IBI, na.rm = TRUE) / sqrt(sum(!is.na(Happy_IBI))),
    Neutral_IBI_mean = mean(Neutral_IBI, na.rm = TRUE), Neutral_IBI_se = sd(Neutral_IBI, na.rm = TRUE) / sqrt(sum(!is.na(Neutral_IBI))),
    Fear_HF_mean = mean(Fear_HF, na.rm = TRUE), Fear_HF_se = sd(Fear_HF, na.rm = TRUE) / sqrt(sum(!is.na(Fear_HF))),
    Happy_HF_mean = mean(Happy_HF, na.rm = TRUE), Happy_HF_se = sd(Happy_HF, na.rm = TRUE) / sqrt(sum(!is.na(Happy_HF))),
    Neutral_HF_mean = mean(Neutral_HF, na.rm = TRUE), Neutral_HF_se = sd(Neutral_HF, na.rm = TRUE) / sqrt(sum(!is.na(Neutral_HF))),
    Fear_LF_mean = mean(Fear_LF, na.rm = TRUE), Fear_LF_se = sd(Fear_LF, na.rm = TRUE) / sqrt(sum(!is.na(Fear_LF))),
    Happy_LF_mean = mean(Happy_LF, na.rm = TRUE), Happy_LF_se = sd(Happy_LF, na.rm = TRUE) / sqrt(sum(!is.na(Happy_LF))),
    Neutral_LF_mean = mean(Neutral_LF, na.rm = TRUE), Neutral_LF_se = sd(Neutral_LF, na.rm = TRUE) / sqrt(sum(!is.na(Neutral_LF)))
  )

df_plot <- data.frame(
  Condition = rep(c("Fear", "Happy", "Neutral"), each = 3),
  Type = rep(c("IBI", "HF-HRV", "LF-HRV"), times = 3),
  Mean = c(df_summary$Fear_IBI_mean,
           df_summary$Fear_HF_mean, df_summary$Fear_LF_mean,
           df_summary$Happy_IBI_mean,
           df_summary$Happy_HF_mean, df_summary$Happy_LF_mean,
           df_summary$Neutral_IBI_mean,
           df_summary$Neutral_HF_mean, df_summary$Neutral_LF_mean),
  SE = c(df_summary$Fear_IBI_se,
         df_summary$Fear_HF_se, df_summary$Fear_LF_se,
         df_summary$Happy_IBI_se,
         df_summary$Happy_HF_se, df_summary$Happy_LF_se,
         df_summary$Neutral_IBI_se,
         df_summary$Neutral_HF_se, df_summary$Neutral_LF_se)
)

plot_bar_with_error <- function(df, title, ymin, ymax) {
  ggplot(df, aes(x = Type, y = Mean, fill = Condition)) +
    geom_bar(stat = "identity", position = position_dodge(width = 0.7), width = 0.6) + 
    geom_errorbar(aes(ymin = Mean - SE, ymax = Mean + SE), 
                  width = 0.2, position = position_dodge(0.7)) + 
    labs(title = NULL, x = NULL, y = NULL) +
    coord_cartesian(ylim = c(ymin, ymax)) +  
    scale_fill_manual(values = c("Fear" = "#1172BF", "Happy" = "#C60700", "Neutral" = "gray")) +  
    theme_minimal() +
    theme(
      legend.position = "none",  
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      axis.line.x = element_line(size = 0.5, color = "black", linetype = "solid"),
      axis.line.y = element_line(size = 0.5, color = "black"),
      axis.ticks.length = unit(0.25, "cm"),
      axis.ticks = element_line(size = 0.5)
    )
}

p1 <- plot_bar_with_error(subset(df_plot, Type == "IBI"), "IBI", 0.65, 0.75)
p2 <- plot_bar_with_error(subset(df_plot, Type %in% c("HF-HRV", "LF-HRV")), "HF & LF", 12.5, 14)

shared_legend <- get_legend(
  ggplot(df_plot, aes(x = Type, y = Mean, fill = Condition)) +
    geom_bar(stat = "identity", position = "dodge") +
    scale_fill_manual(values = c("Fear" = "#1172BF", "Happy" = "#C60700", "Neutral" = "gray")) + 
    theme_minimal() +
    theme(
      legend.position = "top",              
      legend.title = element_blank()        
    ) +
    guides(fill = guide_legend(ncol = 1))   
)

combined_plot <- (p1 + p2) / shared_legend + plot_layout(heights = c(10, 1), widths = c(2, 1, 2))

print(combined_plot)
