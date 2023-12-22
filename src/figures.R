library(tidyverse)

load("results/models/lessrf/all-spp.Rdata"); summary(m1)$solutions %>% write.csv("results/models/summary/Q0.csv", row.names = FALSE)
# load("results/models/lessrf/quality-spp.Rdata"); summary(m1)$solutions%>% write.csv("results/models/summary/Q1.csv", row.names = FALSE)
# load("results/models/lessrf/quality--match-spp.Rdata"); summary(m1)$solutions%>% write.csv("results/models/summary/Q2.csv", row.names = FALSE)
# load("results/models/lessrf/quality-no-gymno.Rdata"); summary(m1)$solutions%>% write.csv("results/models/summary/Q3.csv", row.names = FALSE)
# load("results/models/lessrf/no-scaling.Rdata"); summary(m1)$solutions%>% write.csv("results/models/summary/Q4.csv", row.names = FALSE)

summary(m1)$solutions %>%
  data.frame %>%
  rownames_to_column(var = "Parameter") %>%
  mutate(Parameter = fct_recode(Parameter, 
                                "Intercept:Intercept" = "(Intercept)",
                                "Temperature:Germination cue\n(Main effects)" = "scale(temperature)",
                                "Alternating temperature:Germination cue\n(Main effects)" = "scale(alternating)",
                                "Light:Germination cue\n(Main effects)" = "scale(light)",
                                "Cold stratification:Germination cue\n(Main effects)" = "scale(cs)",
                                "Warm stratification:Germination cue\n(Main effects)" = "scale(ws)",
                                "Scarification:Germination cue\n(Main effects)" = "scale(scarified)",
                                "Main effect:Disturbance\nseverity" = "scale(severity)",
                                "Main effect:Disturbance\nfrequency" = "scale(frequency)",
                                "Main effect:Mowing" = "scale(mowing)",
                                "Main effect:Grazing" = "scale(grazing)",
                                "Main effect:Soil\ndisturbance" = "scale(soil)",
                                "Temperature:Disturbance\nseverity" = "scale(temperature):scale(severity)",
                                "Temperature:Disturbance\nfrequency" = "scale(temperature):scale(frequency)",
                                "Temperature:Mowing" = "scale(temperature):scale(mowing)",
                                "Temperature:Grazing" = "scale(temperature):scale(grazing)",
                                "Temperature:Soil\ndisturbance" = "scale(temperature):scale(soil)",
                                "Alternating temperature:Disturbance\nseverity" = "scale(alternating):scale(severity)",
                                "Alternating temperature:Disturbance\nfrequency" = "scale(alternating):scale(frequency)",
                                "Alternating temperature:Mowing" = "scale(alternating):scale(mowing)",
                                "Alternating temperature:Grazing" = "scale(alternating):scale(grazing)",
                                "Alternating temperature:Soil\ndisturbance" = "scale(alternating):scale(soil)",
                                "Light:Disturbance\nseverity" = "scale(light):scale(severity)",
                                "Light:Disturbance\nfrequency" = "scale(light):scale(frequency)",
                                "Light:Mowing" = "scale(light):scale(mowing)",
                                "Light:Grazing" = "scale(light):scale(grazing)",
                                "Light:Soil\ndisturbance" = "scale(light):scale(soil)",
                                "Cold stratification:Disturbance\nseverity" = "scale(cs):scale(severity)",
                                "Cold stratification:Disturbance\nfrequency" = "scale(cs):scale(frequency)",
                                "Cold stratification:Mowing" = "scale(cs):scale(mowing)",
                                "Cold stratification:Grazing" = "scale(cs):scale(grazing)",
                                "Cold stratification:Soil\ndisturbance" = "scale(cs):scale(soil)",
                                "Warm stratification:Disturbance\nseverity" = "scale(ws):scale(severity)",
                                "Warm stratification:Disturbance\nfrequency" = "scale(ws):scale(frequency)",
                                "Warm stratification:Mowing" = "scale(ws):scale(mowing)",
                                "Warm stratification:Grazing" = "scale(ws):scale(grazing)",
                                "Warm stratification:Soil\ndisturbance" = "scale(ws):scale(soil)",
                                "Scarification:Disturbance\nseverity" = "scale(scarified):scale(severity)",
                                "Scarification:Disturbance\nfrequency" = "scale(scarified):scale(frequency)",
                                "Scarification:Mowing" = "scale(scarified):scale(mowing)",
                                "Scarification:Grazing" = "scale(scarified):scale(grazing)",
                                "Scarification:Soil\ndisturbance" = "scale(scarified):scale(soil)")) %>%
  separate(Parameter, into = c("Effect", "Group"), sep = ":") %>%
  mutate(Effect = fct_relevel(Effect, c("Light", 
                                        "Alternating temperature", 
                                        "Temperature", 
                                        "Warm stratification", 
                                        "Cold stratification", 
                                        "Scarification")),
         Group = fct_relevel(Group, c("Germination cue\n(Main effects)", 
                                      "Disturbance\nfrequency", 
                                      "Disturbance\nseverity", 
                                      "Soil\ndisturbance",
                                      "Mowing",
                                      "Grazing"))) %>%
  filter(! Group == "Intercept") %>%
  #filter(pMCMC <= 0.01) %>%
  ggplot(aes(y = Effect, x = post.mean, 
             xmin = l.95..CI, xmax = u.95..CI,
             color = Effect)) +
  facet_wrap(~ Group, scales = "free_x", nrow = 2) +
  geom_point(size = 2) +
  labs(x = "Effect size") +
  geom_errorbarh(height = .3) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  scale_color_manual(values = c("#FFA500",  
                                "gold", 
                                "#B3EE3A", 
                                "#40E0D0",
                                "#5CACEE", 
                                "#27408B", 
                                "#A020F0",
                                "#551A8B")) +
  ggthemes::theme_tufte() +
  theme(text = element_text(family = "sans", size = 12),
        strip.background = element_blank(),
        legend.position = "none", 
        panel.background = element_rect(color = "black", fill = NULL),
        axis.title.x = element_text(size = 14), 
        axis.title.y = element_blank(),
        axis.text.x = element_text(size = 7.5, color = "black"),
        axis.text.y = element_text(size = 14,
                                   color = c("#FFA500",  
                                             "gold", 
                                             "#B3EE3A", 
                                             "#40E0D0",
                                             "#5CACEE", 
                                             "#27408B", 
                                             "#A020F0",
                                             "#551A8B")),
        strip.text.x = element_text(size = 14)) -> 
  fig; fig

## Export

ggsave(fig, file = "results/figures/FigQ1.png", bg = "white", 
       path = NULL, scale = 1, width = 173, height = 173, units = "mm", dpi = 600)

# Calculate lambda http://www.mpcm-evolution.com/practice/online-practical-material-chapter-11/chapter-11-1-simple-model-mcmcglmm

lambda <- m1$VCV[,"animal"]/(m1$VCV[,"animal"] + m1$VCV[,"units"])

mean(lambda) %>% round(2) 
coda::HPDinterval(lambda)[, 1] %>% round(2) 
coda::HPDinterval(lambda)[, 2] %>% round(2) 

# Random effects

summary(m1)$Gcovariances

