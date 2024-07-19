library(tidyverse)

### Summary table

load(file = "results/models/obj1/m1.Rdata")
load(file = "results/models/obj2/m2.1.Rdata")
load(file = "results/models/obj2/m2.2.Rdata")
load(file = "results/models/obj2/m2.3.Rdata")
load(file = "results/models/obj2/m2.4.Rdata")
load(file = "results/models/obj2/m2.5.Rdata")
load(file = "results/models/obj2/m2.6.Rdata")
load(file = "results/models/obj2/m2.7.Rdata")
load(file = "results/models/obj2/m2.8.Rdata")

rbind(
  summary(m2.1)$solutions %>%
    data.frame %>%
    rownames_to_column(var = "Effect") %>%
    mutate(Model = "m2.1"),
  summary(m2.2)$solutions %>%
    data.frame %>%
    rownames_to_column(var = "Effect") %>%
    mutate(Model = "m2.2"),
  summary(m2.3)$solutions %>%
    data.frame %>%
    rownames_to_column(var = "Effect") %>%
    mutate(Model = "m2.3"),
  summary(m2.4)$solutions %>%
    data.frame %>%
    rownames_to_column(var = "Effect") %>%
    mutate(Model = "m2.4"),
  summary(m2.5)$solutions %>%
    data.frame %>%
    rownames_to_column(var = "Effect") %>%
    mutate(Model = "m2.5"),
  summary(m2.6)$solutions %>%
    data.frame %>%
    rownames_to_column(var = "Effect") %>%
    mutate(Model = "m2.6"),
  summary(m2.7)$solutions %>%
    data.frame %>%
    rownames_to_column(var = "Effect") %>%
    mutate(Model = "m2.7"),
  summary(m2.8)$solutions %>%
    data.frame %>%
    rownames_to_column(var = "Effect") %>%
    mutate(Model = "m2.8")) %>%
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
    Model = fct_relevel(as.factor(Model), c("m2.8",
                                 "m2.7",
                                 "m2.6",
                                 "m2.5",
                                 "m2.4",
                                 "m2.3",
                                 "m2.2",
                                 "m2.1"))) %>%
  mutate(
    Model = fct_recode(Model, "Wetlands - High disturbance" = "m2.8",
                                "Wetlands - Low disturbance" = "m2.7",
                                "Cold stress - High disturbance" = "m2.6",
                                "Cold stress - Low disturbance" = "m2.5",
                                "Water stress - High disturbance" = "m2.4",
                                            "Water stress - Low disturbance" =  "m2.3",
                                "Low stress - High disturbance" = "m2.2",
                                "Low stress - Low disturbance" = "m2.1")) %>%
  filter(! Effect == "Intercept") %>%
  #filter(pMCMC < 0.05) %>%
  ggplot(aes(y = Model, x = post.mean,
             xmin = l.95..CI, xmax = u.95..CI,
             color = Model)) +
  facet_wrap(~ Effect, nrow = 1) +
  geom_point(size = 2) +
  labs(x = "Effect size") +
  geom_errorbarh(height = .3) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  scale_color_manual(values = c("skyblue4",
                                "skyblue",
                                "darkorchid4",
                                "darkmagenta",
                                "goldenrod4",
                                "gold",
                                "forestgreen",
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
        axis.text.y = element_text(size = 9,
                                   color = c("skyblue4",
                                             "skyblue",
                                             "darkorchid4",
                                             "darkmagenta",
                                             "goldenrod4",
                                             "gold",
                                             "forestgreen",
                                             "limegreen")),
        plot.margin = unit(c(0.1,0.1,0.1,0.1), "cm")) ->
  f3;f3

## Export

ggsave(f3, file = "results/figures/fig3.png", bg = "white",
       path = NULL, scale = 1, width = 180, height = 75, units = "mm", dpi = 600)
