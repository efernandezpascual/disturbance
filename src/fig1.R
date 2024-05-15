library(tidyverse)

### Violin plot

read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1") %>%
  gather(Trait, Value, Temperature:Severity) %>%
  na.omit %>%
  mutate(Trait = fct_relevel(Trait, c("Temperature", "Moisture", "Frequency", "Severity"))) %>%
  mutate(Trait = fct_recode(Trait, 
                            "Disturbance frequency" = "Frequency",
                            "Disturbance severity" = "Severity")) %>%
  mutate(Group = fct_relevel(Group, "Low stress - Low disturbance", "High stress - Low disturbance",
                             "Low stress - High disturbance", "High stress - High disturbance")) %>%
  mutate(Group = fct_recode(Group, 
                            "Low stress\nLow disturbance" = "Low stress - Low disturbance",
                            "High stress\nLow disturbance" = "High stress - Low disturbance",
                            "Low stress\nHigh disturbance" = "Low stress - High disturbance",
                            "High stress\nHigh disturbance" = "High stress - High disturbance")) %>%
  ggplot(aes(Trait, Value, color = Group, fill = Group)) + 
  geom_violin(alpha = .5, draw_quantiles = c(0.25, 0.5, 0.75)) +
  facet_wrap(~ Trait, scale = "free", nrow = 1) +
  scale_y_continuous(labels = scales::number_format(accuracy = .1)) +
  ylab("Indicator value") +
  ggthemes::theme_tufte() +
  theme(text = element_text(family = "sans"),
        strip.background = element_blank(),
        legend.position = "top", 
        #legend.direction = "vertical",
        legend.title = element_blank(),
        legend.margin=margin(0,0,0,0),
        legend.box.margin=margin(-1,-1,-4,-1),
        legend.text = element_text(size = 10), 
        panel.background = element_rect(color = "black", fill = NULL),
        #strip.text = element_text(size = 9.8, hjust = 0, margin = margin(l = 0, b = 4)),
        strip.text = element_blank(),
        plot.title = element_text(size = 10),
        axis.title = element_text(size = 10),
        axis.title.x = element_blank(),
        axis.text = element_text(size = 10, color = "black"),
        plot.margin = unit(c(0.1,0.1,0.1,0.1), "cm")) +
  scale_color_manual(values = c( "limegreen",
                                 "skyblue",
                                 "darkmagenta",
                                 "gold")) +
  scale_fill_manual(values = c( "limegreen",
                                "skyblue",
                                "darkmagenta",
                                "gold")) -> f1;f1

ggsave(f1, file = "results/figures/fig1.png", bg = "white", 
       path = NULL, scale = 1, width = 180, height = 65, units = "mm", dpi = 600)