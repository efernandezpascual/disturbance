library(tidyverse)

### Calculate binomial CIs

bi <- function(x)
{
  bci <- binom::binom.confint(x$ngerminated, x$nseeds, method = "wilson")
  cbind(x, germination = bci[4:6])
}

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
  mutate(Group = paste(Stress, Disturbance, sep = " - ")) %>%
  merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1")) %>%
  group_by(Group) %>%
  summarise(ngerminated = sum(ngerminated), nseeds = sum(nseeds)) %>%
  do(bi(.)) %>%
  mutate(Group = fct_relevel(Group, "Low stress - Low disturbance", "Low stress - High disturbance",
                             "Water stress - Low disturbance", "Water stress - High disturbance",
                             "Cold stress - Low disturbance", "Cold stress - High disturbance",
                             "Wetlands - Low disturbance", "Wetlands - High disturbance"))%>%
  mutate(Group = fct_recode(Group, 
                            "(1) Low stress - Low disturbance" = "Low stress - Low disturbance", 
                            "(2) Low stress - High disturbance" = "Low stress - High disturbance",
                            "(3) Water stress - Low disturbance" = "Water stress - Low disturbance", 
                            "(4) Water stress - High disturbance" = "Water stress - High disturbance",
                            "(5) Cold stress - Low disturbance" = "Cold stress - Low disturbance", 
                            "(6) Cold stress - High disturbance" = "Cold stress - High disturbance",
                            "(7) Wetlands - Low disturbance" = "Wetlands - Low disturbance", 
                            "(8) Wetlands - High disturbance" = "Wetlands - High disturbance"))  -> cis

### Calculate individual data points

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
  mutate(Group = paste(Stress, Disturbance, sep = " - ")) %>%
  merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1")) %>%
  mutate(germination.mean = ngerminated / nseeds) %>%
  select(Group, germination.mean) %>%
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
                            "(8) Wetlands - High disturbance" = "Wetlands - High disturbance")) %>%
  mutate(number = as.numeric(Group))-> pts

### Binomial indicator figure

cis %>%
  group_by(Group) %>%
  summarise(ngerminated = sum(ngerminated), nseeds = sum(nseeds)) %>%
  mutate(number = as.numeric(Group)) %>%
  ggplot(aes(as.factor(number), germination.mean, fill = Group)) +
  geom_jitter(data = pts, width = .3, aes(color = Group), size = 1, alpha = .3, key_glyph = "rect") +
  geom_bar(stat = "identity", position = "dodge", color = "black", alpha = .5) +
  # geom_errorbar(aes(ymin = germination.lower, ymax = germination.upper), width = .1,
  #               position = position_dodge(.9)) +
  scale_fill_manual(values = c(
    "limegreen",
    "forestgreen",
    "gold",
    "goldenrod4",
    "darkmagenta",
    "darkorchid4",
    "skyblue",
    "skyblue4")) +
  scale_color_manual(values = c(
    "limegreen",
    "forestgreen",
    "gold",
    "goldenrod4",
    "darkmagenta",
    "darkorchid4",
    "skyblue",
    "skyblue4")) +
  ggthemes::theme_tufte() +
  xlab("Stress - disturbance species groups") +
  ylab("Final germination proportion") +
  ggtitle(label = "(A) Germination proportions by stress-disturbance group") + 
  coord_cartesian(ylim = c(0, 1)) +
  theme(text = element_text(family = "sans"),
        strip.background = element_blank(),
        legend.position = "top", 
        #legend.direction = "vertical",
        legend.title = element_blank(),
        legend.spacing.x = unit(0, "mm"),
        legend.spacing.y = unit(0, "mm"),
        legend.text = element_text(size = 8), 
        legend.key.size = unit(.1, 'cm'), #change legend key size
        legend.key.height = unit(.1, 'cm'), #change legend key height
        legend.key.width = unit(.25, 'cm'), #change legend key width
        legend.box.margin=margin(-5,-10,-10,-10),
        panel.background = element_rect(color = "black", fill = NULL),
        strip.text = element_text(size = 9.8, hjust = 0, margin = margin(l = 0, b = 0)),
        #strip.text = element_blank(),
        plot.title = element_text(size = 11),
        axis.title = element_text(size = 10),
        axis.text = element_text(size = 8, color = "black"),
        plot.margin = unit(c(0.1,0.1,0.1,0.1), "cm")) +
  guides(fill = guide_legend 
         (override.aes = list(alpha = 1))) + 
  guides(color = guide_legend 
         (override.aes = list(alpha = 1))) + 
  guides(fill=guide_legend(ncol=2)) +
  geom_hline(yintercept = 0) -> f2a; f2a

### Effect size figure

load(file = "results/models/obj1/m1.B.Rdata")

summary(m1.B)$solutions %>%
  data.frame %>%
  rownames_to_column(var = "Group")%>%
  filter(! Group == "(Intercept)") %>%
  mutate(Group = gsub("Stress", "", Group)) %>%
  mutate(Group = gsub("Disturbance", "", Group)) %>%
  mutate(Group = fct_relevel(Group,
                             "High disturbance",
                             "Wetlands", 
                             "Cold stress",
                             "Water stress")) %>%
  mutate(Group = fct_recode(Group,
                            "High\ndisturbance" = "High disturbance",
                            "Wetlands" = "Wetlands", 
                            "Cold\nstress" = "Cold stress",
                            "Water\nstress"= "Water stress")) %>%
  mutate(number = as.numeric(as.factor(Group))) %>%
  # filter(pMCMC <= 0.05) %>%
  ggplot(aes(y = Group, x = post.mean,
             xmin = l.95..CI, xmax = u.95..CI,
             color = Group)) +
  geom_point(size = 4) +
  labs(x = "Effect size") +
  labs(y = "Stress - disturbance species groups") +
  ggtitle(label = "(B) Effect sizes") + 
  geom_errorbarh(height = .3) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "limegreen", size = 1) +
  scale_color_manual(values = c("grey10",
                                "skyblue",
                                "darkmagenta",
                                "gold")) +
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
        plot.title = element_text(size = 11),
        #strip.text = element_blank(),
        axis.title = element_text(size = 10),
        axis.title.y = element_blank(),
        axis.text = element_text(size = 8, color = "black"),
        axis.text.y = element_text(size = 9,
                                   color = c("grey10",
                                             "skyblue",
                                             "darkmagenta",
                                             "gold")),
        plot.margin = unit(c(0.1,0.1,0.1,0.15), "cm")) -> f2b;f2b

### merge panels

cowplot::plot_grid(f2a, f2b, nrow = 1, rel_widths = (2:1)) -> f2

ggsave(f2, file = "results/figures/fig2.png", bg = "white", 
       path = NULL, scale = 1, width = 180, height = 100, units = "mm", dpi = 600)

