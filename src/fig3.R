library(tidyverse)

### Summary table

rbind(
  summary(m2.LL)$solutions %>%
    data.frame %>%
    rownames_to_column(var = "Effect") %>%
    mutate(Model = "m2.LL"),
  summary(m2.LH)$solutions %>%
    data.frame %>%
    rownames_to_column(var = "Effect") %>%
    mutate(Model = "m2.LH"),
  summary(m2.HL)$solutions %>%
    data.frame %>%
    rownames_to_column(var = "Effect") %>%
    mutate(Model = "m2.HL"),
  summary(m2.HH)$solutions %>%
    data.frame %>%
    rownames_to_column(var = "Effect") %>%
    mutate(Model = "m2.HH")) %>%
  group_by %>%
  mutate(Effect = fct_recode(Effect,
                             "Intercept" = "(Intercept)",
                             "Average\ntemperature" = "scale(temperature)",
                             "Alternating\ntemperature" = "scale(alternating)",
                             "Light" = "scale(light)",
                             "Cold\nstratification" = "scale(cs)",
                             "Scarification" = "scale(scarified)"),
         Effect = fct_relevel(Effect, c("Scarification",
                                        "Cold\nstratification",
                                        "Average\ntemperature",
                                        "Alternating\ntemperature",
                                        "Light"
                                        ))) %>%
  mutate(
    Model = fct_relevel(Model, c("m2.HH",
                                 "m2.LH",
                                 "m2.HL",
                                 "m2.LL")),
    Model = fct_recode(Model,
                       "Low stress\nLow disturbance" = "m2.LL",
                       "High stress\nLow disturbance" = "m2.HL",
                       "Low stress\nHigh disturbance" = "m2.LH",
                       "High stress\nHigh disturbance" = "m2.HH")) %>%
  filter(! Effect == "Intercept") %>%
  #filter(pMCMC <= 0.05) %>%
  ggplot(aes(y = Model, x = post.mean,
             xmin = l.95..CI, xmax = u.95..CI,
             color = Model)) +
  facet_wrap(~ Effect, nrow = 1) +
  geom_point(size = 2) +
  labs(x = "Effect size") +
  geom_errorbarh(height = .3) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  scale_color_manual(values = c("gold",
                                "darkmagenta",
                                "skyblue",
                                "limegreen")) +
  ggthemes::theme_tufte() +
  theme(text = element_text(family = "sans"),
        strip.background = element_blank(),
        legend.position = "none", 
        #legend.direction = "vertical",
        legend.title = element_text(size = 10),
        legend.spacing.x = unit(0, "mm"),
        legend.spacing.y = unit(0, "mm"),
        legend.text = element_text(size = 10), 
        panel.background = element_rect(color = "black", fill = NULL),
        strip.text = element_text(size = 9.8, hjust = 0, margin = margin(l = 0, b = 4)),
        #strip.text = element_blank(),
        plot.title = element_text(size = 10),
        axis.title = element_text(size = 10),
        axis.title.y = element_blank(),
        axis.text.x = element_text(size = 7, color = "black"),
        axis.text.y = element_text(size = 10,
                                   color = c("gold",
                                             "darkmagenta",
                                             "skyblue",
                                             "limegreen")),
        plot.margin = unit(c(0.1,0.1,0.1,0.1), "cm")) ->
  f3;f3

## Export

ggsave(f3, file = "results/figures/fig3.png", bg = "white",
       path = NULL, scale = 1, width = 180, height = 65, units = "mm", dpi = 600)
