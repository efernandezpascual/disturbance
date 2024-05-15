library(tidyverse)

### Calculate binomial CIs

bi <- function(x)
{
  bci <- binom::binom.confint(x$ngerminated, x$nseeds, method = "wilson")
  cbind(x, germination = bci[4:6])
}

read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1") %>%
  merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1")) %>%
  group_by(Group) %>%
  summarise(ngerminated = sum(ngerminated), nseeds = sum(nseeds)) %>%
  do(bi(.)) %>%
  mutate(Group = fct_relevel(Group, "Low stress - Low disturbance", "High stress - Low disturbance",
                             "Low stress - High disturbance", "High stress - High disturbance")) %>%
  mutate(Group = fct_recode(Group, 
                            "Low stress\nLow disturbance" = "Low stress - Low disturbance",
                            "High stress\nLow disturbance" = "High stress - Low disturbance",
                            "Low stress\nHigh disturbance" = "Low stress - High disturbance",
                            "High stress\nHigh disturbance" = "High stress - High disturbance")) -> cis

### Calculate individual data points

read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1") %>%
  merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1")) %>%
  mutate(germination.mean = ngerminated / nseeds) %>%
  select(Group, germination.mean) %>%
  mutate(Group = fct_relevel(Group, "Low stress - Low disturbance", "High stress - Low disturbance",
                             "Low stress - High disturbance", "High stress - High disturbance")) %>%
  mutate(Group = fct_recode(Group, 
                            "Low stress\nLow disturbance" = "Low stress - Low disturbance",
                            "High stress\nLow disturbance" = "High stress - Low disturbance",
                            "Low stress\nHigh disturbance" = "Low stress - High disturbance",
                            "High stress\nHigh disturbance" = "High stress - High disturbance")) -> pts

### Binomial indicator figure

cis %>%
  group_by() %>%
  ggplot(aes(Group, germination.mean, fill = Group)) +
  geom_jitter(data = pts, width = .3, aes(color = Group), size = 1, alpha = .3) +
  geom_bar(stat = "identity", position = "dodge", color = "black", alpha = .5) +
  geom_errorbar(aes(ymin = germination.lower, ymax = germination.upper), width = .1,
                position = position_dodge(.9)) +
  scale_fill_manual(values = c(
                      "limegreen",
                      "skyblue",
                      "darkmagenta",
                      "gold")) +
  scale_color_manual(values = c(
                       "limegreen",
                       "skyblue",
                       "darkmagenta",
                       "gold")) +
  ggthemes::theme_tufte() +
  xlab("Stress/disturbance level") + 
  ylab("Final germination proportion") +
  coord_cartesian(ylim = c(0, 1)) +
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
        axis.title.x = element_blank(),
        axis.text = element_text(size = 10, color = "black"),
        axis.text.x = element_text(size = 10,
                                   color = c(
                                     "limegreen",
                                     "skyblue",
                                     "darkmagenta",
                                     "gold")),
        plot.margin = unit(c(0.1,0.1,0.1,0.1), "cm")) +
  geom_hline(yintercept = 0) -> f2; f2

ggsave(f2, file = "results/figures/fig2.png", bg = "white", 
       path = NULL, scale = 1, width = 180, height = 65, units = "mm", dpi = 600)
