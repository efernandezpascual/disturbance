library(tidyverse); library(phangorn)

rm(list = ls())

read.csv("data/disturbance-germination-herb.csv", fileEncoding = "latin1") %>%
  pull(temperature) %>%
  mean -> mt

merge(read.csv("data/disturbance-germination-herb.csv", fileEncoding = "latin1"),
      read.csv("data/disturbance-indicators-herb.csv", fileEncoding = "latin1"),
      by = "species") %>%
  mutate(animal = gsub(" ", "_", species)) %>%
  select(-family) %>%
  mutate(g = ngerminated/nseeds) %>%
  mutate(main = 0) %>%
  mutate(temperature = ifelse(temperature > mt, 1, 0)) %>%
  select(g, frequency, severity, temperature, light, alternating, cs, scarified, main) %>%
  gather(Disturbance, x, frequency:severity) %>%
  gather(Germination, z, temperature:main) %>%
  mutate(group = paste(Germination, z)) %>%
  mutate(Germination = fct_relevel(Germination, c("main", 
                                                  "scarified",
                                                  "cs",
                                                  "temperature",
                                                  "alternating", 
                                                  "light"))) %>%
  mutate(Germination = fct_recode(Germination, "Main effect" = "main", 
                                                  "Scarification" = "scarified",
                                                  "Cold strat. " = "cs",
                                                  "Temperature" = "temperature",
                                                  "Alternating t." = "alternating", 
                                                  "Light" = "light"))  %>%
  mutate(Disturbance = fct_recode(Disturbance, 
                                  "(A) Disturbance frequency" = "frequency", 
                                  "(B) Disturbance severity" = "severity"))-> 
  germination

germination %>%
  ggplot(aes(x, g, color = as.factor(group))) +
  facet_grid(Germination ~ Disturbance, scales = "free_x") +
  geom_point(alpha = 0.10) +
  geom_smooth(method = "loess")+
  labs(x = "Indicator value", y = "Final germination proportion") +
  scale_color_discrete(breaks = c("main 0",
                                  "scarified 1", "scarified 0",
                                  "cs 1", "cs 0",
                                "temperature 1", "temperature 0",
                                "alternating 1", "alternating 0",
                                "light 1", "light 0"),
                       labels = c("Disturbance main effect",
                                  "Scarified", "Unscarified",
                                  "Cold-stratified", "Unstratified",
                                  "Temperature warm", "Temperature cold",
                                  "Alternating temp.", "Constant temp.",
                                  "Light", "Darkness"),
                       type = c("grey40",
                                  "#B3EE3A",
                                  "grey40",
                                  "#5CACEE",
                                  "grey40",
                                  "gold",
                                  "#551A8B",
                                  "grey40",
                                  "#40E0D0",
                                  "grey40",
                                  "#FFA500")) +
  ggthemes::theme_tufte() +
  theme(text = element_text(family = "sans", size = 12),
        strip.background = element_blank(),
        legend.position = "bottom",
        title = element_blank(),
        panel.background = element_rect(color = "black", fill = NULL),
        axis.title = element_text(size = 12),
        axis.text.x = element_text(size = 7.5, color = "black"),
        axis.text.y = element_text(size = 12),
        strip.text.x = element_text(size = 10, hjust = 0, vjust = 1, margin = margin(l = 0, b = 4))) -> fig

ggsave(fig, file = "results/figures/loess-herb.png", bg = "white",
       path = NULL, scale = 1, width = 180, height = 180, units = "mm", dpi = 600)

