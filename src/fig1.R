library(tidyverse)

### Create stress and disturbance groups

read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1") %>%
  mutate(T = ifelse(Temperature >= (10/3)*2, "High", "Mid")) %>%
  mutate(T = ifelse(Temperature <= (10/3), "Low", T)) %>%
  mutate(M = ifelse(Moisture >= (10/3)*2, "High", "Mid")) %>%
  mutate(M = ifelse(Moisture <= (10/3), "Low", M)) %>%
  mutate(F = ifelse(Frequency <= median(Frequency, na.rm = TRUE), "Low", "High")) %>%
  mutate(S = ifelse(Severity <= median(Severity, na.rm = TRUE), "Low", "High")) %>%
  mutate(Stress = ifelse(M == "High" & T == "Low", "Cold stress", NA)) %>%
  mutate(Stress = ifelse(M == "High" & T == "Mid", "Wetlands", Stress)) %>%
  mutate(Stress = ifelse(M == "Low" & T == "High", "Water stress", Stress)) %>%
  mutate(Stress = ifelse(M == "Low" & T == "Low", "Cold stress", Stress)) %>%
  mutate(Stress = ifelse(M == "Low" & T == "Mid", "Water stress", Stress)) %>%
  mutate(Stress = ifelse(M == "Mid" & T == "High", "Low stress", Stress)) %>%
  mutate(Stress = ifelse(M == "Mid" & T == "Low", "Cold stress", Stress)) %>%
  mutate(Stress = ifelse(M == "Mid" & T == "Mid", "Low stress", Stress))  %>% 
  mutate(Disturbance = ifelse(Frequency <= median(Frequency, na.rm = TRUE) & 
                      Severity <= median(Severity, na.rm = TRUE), 
                      "Low disturbance", "High disturbance")) %>%
  mutate(Group = paste(Stress, Disturbance, sep = " - ")) -> groups

### Stress groups

groups %>%
  group_by(M, T, Stress) %>%
  tally %>%
  cbind(Label = c("Arctoalpine mires\n22 species", 
                  "Wetlands\n118 species", 
                  "Thermomedit.\n110 species", 
                  "Oromedit.\n23 species", 
                  "Mediterranean\n304 species", 
                  "Warm temperate\n27 species", 
                  "Arctoalpine\n140 species", 
                  "Mesophilous\n613 species")) %>%
  group_by() %>%
  mutate(M = fct_relevel(M, "Low", "Mid", "High")) %>%
  mutate(T = fct_relevel(T, "Low", "Mid", "High")) %>%
  mutate(Stress = fct_relevel(Stress, "Low stress",
                             "Water stress",
                             "Cold stress",
                             "Wetlands")) %>%
  ggplot(aes(T, M, fill = Stress)) +
  geom_tile(color = "black") +
  geom_text(aes(label = Label), size = 3, color = "white") +
  ggtitle(label = "(A) Stress groups") + 
  xlab("Temperature indicator") +
  ylab("Moisture indicator") +
  labs(fill = "(A) Stress groups") +
  ggthemes::theme_tufte() +
  theme(text = element_text(family = "sans"),
        strip.background = element_blank(),
        legend.position = "top", 
        #legend.direction = "vertical",
        legend.justification = "left",
        legend.title = element_blank(),
        legend.margin=margin(0,0,0,0),
        legend.box.margin=margin(-1,-1,-4,-1),
        legend.text = element_text(size = 8), 
        legend.key.size = unit(.1, 'cm'), #change legend key size
        legend.key.height = unit(.1, 'cm'), #change legend key height
        legend.key.width = unit(.25, 'cm'), #change legend key width
        panel.background = element_rect(color = "black", fill = NULL),
        strip.text = element_text(size = 10, margin = margin(r = 1, l = 2.5, b = 0)),
        strip.placement = "outside",
        plot.title = element_text(size = 11),
        axis.title = element_text(size = 10),
        axis.text = element_text(size = 8, color = "black"),
        plot.margin = unit(c(0.1,0.1,0.1,0.1), "cm")) +
  scale_color_manual(values = c("limegreen",
                               "gold2",
                               "darkmagenta",
                               "skyblue")) +
  scale_fill_manual(values = c("limegreen",
                               "gold2",
                               "darkmagenta",
                               "skyblue")) -> f1A; f1A

### Disturbance groups

groups %>%
  group_by(F, S, Disturbance) %>%
  tally %>%
  cbind(Label = c("Frequent & severe\n544 species", 
                  "Frequent & mild\n134 species", 
                  "Infrequent & severe\n134 species", 
                  "Infrequent & mild\n545 species")) %>%
  group_by() %>%
  mutate(F = fct_relevel(F, "Low", "High")) %>%
  mutate(S = fct_relevel(S, "Low", "High")) %>%
  mutate(Disturbance = fct_relevel(Disturbance, "Low disturbance",
                              "High disturbance")) %>%
  ggplot(aes(F, S, fill = Disturbance)) +
  geom_tile(color = "white") +
  geom_text(aes(label = Label), size = 3, color = "white") +
  ggtitle(label = "(B) Disturbance groups") + 
  xlab("Disturbance frequency indicator") +
  ylab("Disturbance severity indicator") +
  labs(fill = "(B) Disturbance groups") +
  ggthemes::theme_tufte() +
  theme(text = element_text(family = "sans"),
        strip.background = element_blank(),
        legend.position = "top", 
        #legend.direction = "vertical",
        legend.justification = "left",
        legend.title = element_blank(),
        legend.margin=margin(0,0,0,0),
        legend.box.margin=margin(-1,-1,-4,-1),
        legend.text = element_text(size = 8), 
        legend.key.size = unit(.1, 'cm'), #change legend key size
        legend.key.height = unit(.1, 'cm'), #change legend key height
        legend.key.width = unit(.25, 'cm'), #change legend key width
        panel.background = element_rect(color = "black", fill = NULL),
        strip.text = element_text(size = 10, margin = margin(r = 1, l = 2.5, b = 0)),
        strip.placement = "outside",
        plot.title = element_text(size = 11),
        axis.title = element_text(size = 10),
        axis.text = element_text(size = 8, color = "black"),
        plot.margin = unit(c(0.1,0.1,0.1,0.35), "cm")) +
  scale_color_manual(values = c("grey40",
                                "grey10")) +
  scale_fill_manual(values = c("grey40",
                               "grey10")) -> f1B; f1B

### Indicator distribution plot

groups %>%
  gather(Trait, Value, Temperature:Severity) %>%
  mutate(Trait = fct_relevel(Trait, c("Temperature", "Moisture", "Frequency", "Severity"))) %>%
  mutate(Trait = fct_recode(Trait, "Temperature indicator" = "Temperature", 
                                     "Moisture indicator" = "Moisture", 
                                     "Disturbance frequency indicator" = "Frequency", 
                                     "Disturbance severity indicator" = "Severity")) %>%
  mutate(Group = fct_relevel(Group, "Low stress - Low disturbance", "Low stress - High disturbance",
                             "Water stress - Low disturbance", "Water stress - High disturbance",
                             "Cold stress - Low disturbance", "Cold stress - High disturbance",
                             "Wetlands - Low disturbance", "Wetlands - High disturbance")) %>%
  mutate(number = as.numeric(Group)) %>%
  ggplot(aes(as.factor(number), Value, color = Group, fill = Group)) + 
  geom_jitter(width = .25, aes(color = Group), size = 1) +
  facet_wrap(~ Trait, scale = "free", nrow = 1, strip.position = "left") +
  scale_y_continuous(labels = scales::number_format(accuracy = .1)) +
  xlab("Stress - disturbance species groups") +
  ylab("Indicator value") +
  ggtitle(label = "(C) Distribution of indicator values across stress-disturbance species groups") + 
  ggthemes::theme_tufte() +
  theme(text = element_text(family = "sans"),
        strip.background = element_blank(),
        legend.position = "none", 
        #legend.direction = "vertical",
        legend.title = element_blank(),
        legend.margin=margin(0,0,0,0),
        legend.box.margin=margin(-1,-1,-4,-1),
        legend.text = element_text(size = 10), 
        panel.background = element_rect(color = "black", fill = NULL),
        strip.text = element_text(size = 10, margin = margin(r = 1, l = 2.5, b = 0)),
        strip.placement = "outside",
        plot.title = element_text(size = 11),
        axis.title = element_text(size = 10),
        axis.title.y = element_blank(),
        axis.text = element_text(size = 8, color = "black"),
        plot.margin = unit(c(0.35,0.1,0.1,0.1), "cm")) +
  scale_color_manual(values = c("limegreen",
                                 "forestgreen",
                                 "gold",
                                 "goldenrod4",
                                 "darkmagenta",
                                 "darkorchid4",
                                 "skyblue",
                                 "skyblue4")) +
  scale_fill_manual(values = c("limegreen",
                               "forestgreen",
                               "gold",
                               "goldenrod4",
                               "darkmagenta",
                               "darkorchid4",
                               "skyblue",
                               "skyblue4")) -> f1C;f1C

### PCA

groups %>%
  select(Temperature:Severity)%>%
  FactoMineR::PCA(graph = FALSE) -> pca1

pca1$var$contrib

pca1$ind$coord %>%
  cbind(groups) %>%
  mutate(Group = fct_relevel(Group, "Low stress - Low disturbance", "Low stress - High disturbance",
                             "Water stress - Low disturbance", "Water stress - High disturbance",
                             "Cold stress - Low disturbance", "Cold stress - High disturbance",
                             "Wetlands - Low disturbance", "Wetlands - High disturbance")) %>%
  mutate(Group = fct_recode(Group, 
                            "(1) Low stress - Low disturbance" = "Low stress - Low disturbance", 
                            "(2) Low stress - High disturbance" = "Low stress - High disturbance",
                            "(3) Water stress - Low disturbance" = "Water stress - Low disturbance", 
                            "(4) Water stress - High disturbance" = "Water stress - High disturbance",
                            "(5) Cold stress - Low disturbance" = "Cold stress - Low disturbance", 
                            "(6) Cold stress - High disturbance" = "Cold stress - High disturbance",
                            "(7) Wetlands - Low disturbance" = "Wetlands - Low disturbance", 
                            "(8) Wetlands - High disturbance" = "Wetlands - High disturbance")) -> df2

aggregate(cbind(Dim.1, Dim.2) ~ Group, data = df2, FUN = mean) %>%
  mutate(number = as.numeric(Group)) -> cent
merge(df2, setNames(cent, c("Group", "oDCA1", "oDCA2")), by = "Group", sort = FALSE) -> segs

pca1$var$coord[, 1:2] %>% data.frame %>% rownames_to_column(var = "Variable") %>%
  mutate(Variable = fct_recode(Variable, 
                            "Disturbance\nseverity" = "Severity",
                            "Disturbance\nfrequency" = "Frequency")) -> pcaVars

df2 %>%
  ggplot(aes(Dim.1, Dim.2)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
  geom_segment(data = pcaVars, aes(x = 0, y = 0, xend = 4*Dim.1, yend = 4*Dim.2)) +
  geom_segment(data = segs, mapping = aes(xend = oDCA1, yend = oDCA2, color = Group), show.legend = TRUE, alpha = 1,
               key_glyph = "rect") +
  geom_label(data = cent, aes(label = number), label.r = unit(0.5, "lines"), size = 3, fill = "black", color = "white", alpha = 0.5) +
  geom_label(data = pcaVars, aes(x = 4*Dim.1, y = 4*Dim.2, label = Variable),  alpha = .7, show.legend = FALSE, size = 3) +
  ggtitle(label = "(D) PCA ordination of indicator values across stress-disturbance species groups") + 
  ggthemes::theme_tufte() +
  scale_x_continuous(name = paste("Axis 1 (", round(pca1$eig[1, 2], 0),
                                  "% variance explained)", sep = "")) + 
  scale_y_continuous(name = paste("Axis 2 (", round(pca1$eig[2, 2], 0), 
                                  "% variance explained)", sep = "")) +
  theme(text = element_text(family = "sans"),
        strip.background = element_blank(),
        legend.position = "right", 
        #legend.direction = "vertical",
        legend.title = element_blank(),
        legend.margin=margin(0,0,0,0),
        legend.box.margin=margin(-1,-1,-4,-1),
        legend.text = element_text(size = 10), 
        panel.background = element_rect(color = "black", fill = NULL),
        strip.text = element_text(size = 10, margin = margin(r = 1, l = 2.5, b = 0)),
        strip.placement = "outside",
        plot.title = element_text(size = 11),
        axis.title = element_text(size = 10),
        axis.text = element_text(size = 8, color = "black"),
        plot.margin = unit(c(0.35,0.1,0.1,0.1), "cm")) +
  scale_color_manual(values = c("limegreen",
                                "forestgreen",
                                "gold",
                                "goldenrod4",
                                "darkmagenta",
                                "darkorchid4",
                                "skyblue",
                                "skyblue4")) +
  scale_fill_manual(values = c("limegreen",
                               "forestgreen",
                               "gold",
                               "goldenrod4",
                               "darkmagenta",
                               "darkorchid4",
                               "skyblue",
                               "skyblue4")) -> f1D; f1D

### Merge panels

cowplot::plot_grid(f1A, f1B, nrow = 1) -> f1AB
cowplot::plot_grid(f1AB, f1C, f1D, nrow = 3) -> f1

ggsave(f1, file = "results/figures/fig1.png", bg = "white", 
       path = NULL, scale = 1, width = 180, height = 220, units = "mm", dpi = 600)

