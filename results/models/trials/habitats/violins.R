library(tidyverse)

read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1") -> indicators

# Violin per habitat

indicators %>%
  gather(Habitat, Value, N:V) %>%
  filter(Value != 0) %>%
  select(-Value) %>%
  select(species, Habitat, frequency, severity) %>%
  gather(Trait, Value, frequency:severity) %>%
  na.omit %>%
  mutate(Habitat = fct_relevel(Habitat, "V")) %>%
  mutate(Habitat = fct_recode(Habitat,
                              "Coastal" = "N",
                              "Wetlands" = "Q",
                              "Grasslands" = "R",
                              "Shrublands" = "S",
                              "Forests" = "T",
                              "Anthropogenic" = "V")) %>%
  mutate(Trait = fct_recode(Trait,
                              "Disturbance frequency" = "frequency",
                              "Disturbance severity" = "severity")) %>%
  ggplot(aes(Habitat, Value, color = Habitat, fill = Habitat)) + 
  geom_violin(alpha = 0.5, draw_quantiles = c(0.25, 0.5, 0.75)) +
  facet_wrap(~ Trait, scale = "free", strip.position = "left") +
  scale_y_continuous(labels = scales::number_format(accuracy = .1)) +
  ggthemes::theme_tufte() +
  theme(text = element_text(family = "sans"),
        legend.position = "bottom", legend.box = "horizontal", legend.margin = margin(),
        legend.title = element_blank(),
        legend.text = element_text(size = 12, color = "black"),
        panel.background = element_rect(color = "black", fill = NULL),
        axis.text = element_text(size = 12, color = "black"),
        axis.text.x = element_blank(),
        axis.title = element_blank(), 
        axis.ticks.x = element_blank(),
        strip.placement = "outside",
        strip.text = element_text(size = 12, color = "black")) +
  #guides(colour = guide_legend(nrow = 1)) +
  geom_jitter(shape = 16, position = position_jitter(0.05), alpha = 0.1) +
  scale_color_manual(values = c("purple", "deepskyblue3","orange", "gold", "firebrick", "olivedrab")) +
  scale_fill_manual(values = c("purple", "deepskyblue3","orange", "gold", "firebrick", "olivedrab")) -> violins;  violins

ggsave(violins, file = "results/figures/violins.png", bg = "white", 
       path = NULL, scale = 1, width = 173, height = 100, units = "mm", dpi = 600)

# Disturbance space

indicators %>%
  gather(Habitat, Value, N:V) %>%
  filter(Value != 0) %>%
  select(-Value) %>%
  select(species, Habitat, frequency, severity) %>%
  gather(Trait, Value, frequency:severity) %>%
  na.omit %>%
  spread(Trait, Value) %>%
  mutate(Habitat = fct_relevel(Habitat, "V")) %>%
  mutate(Habitat = fct_recode(Habitat,
                              "Coastal" = "N",
                              "Wetlands" = "Q",
                              "Grasslands" = "R",
                              "Shrublands" = "S",
                              "Forests" = "T",
                              "Anthropogenic" = "V")) -> inds

cent <- aggregate(cbind(frequency, severity) ~ Habitat, data = inds, FUN = mean)
segs <- merge(inds, setNames(cent, c("Habitat", "oDCA1", "oDCA2")), by = "Habitat", sort = FALSE)

inds %>%
  ggplot(aes(frequency, severity, color = Habitat, fill = Habitat)) + 
  geom_segment(alpha = 0.5, data = segs, mapping = aes(xend = oDCA1, yend = oDCA2, color = Habitat), show.legend = F) +
 # geom_point(shape = 21, size = 2, aes(fill = Habitat), show.legend = T) +
  geom_label(data = cent, aes(label = Habitat), color = "black", size = 3) +
  scale_y_continuous(labels = scales::number_format(accuracy = .1)) +
  labs(x = "Disturbance frequency", y = "Disturbance severity") +
  ggthemes::theme_tufte() +
  theme(text = element_text(family = "sans"),
        legend.position = "none", legend.box = "horizontal", legend.margin = margin(),
        legend.title = element_blank(),
        legend.text = element_text(size = 12, color = "black"),
        panel.background = element_rect(color = "black", fill = NULL),
        axis.text = element_text(size = 12, color = "black"),
        axis.title = element_text(size = 12, color = "black"), 
        strip.placement = "outside",
        strip.text = element_text(size = 12, color = "black")) +
  #guides(colour = guide_legend(nrow = 1)) +
  scale_color_manual(values = c("purple", "deepskyblue3","orange", "gold", "firebrick", "olivedrab")) +
  scale_fill_manual(values = c("purple", "deepskyblue3","orange", "gold", "firebrick", "olivedrab")) -> space;  space

ggsave(space, file = "results/figures/space.png", bg = "white", 
       path = NULL, scale = 1, width = 173, height = 150, units = "mm", dpi = 600)

### Bars per habitat

merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1"), 
      read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1"), 
      by = "species") %>%
  mutate(temperature = ifelse(temperature > 18, 1, 0)) %>%
  mutate(animal = gsub(" ", "_", species)) %>%
  select(-ws) %>%
  gather(Habitat, Value, N:V) %>%
  filter(Value != 0) %>%
  gather(Treatment, Level, scarified:temperature) %>%
  group_by(Treatment, Habitat, Level) %>%
  summarise(g = sum(ngerminated) / sum(nseeds)) %>%
  mutate(Habitat = fct_relevel(Habitat, "V")) %>%
  mutate(Habitat = fct_recode(Habitat,
                              "Coastal" = "N",
                              "Wetlands" = "Q",
                              "Grasslands" = "R",
                              "Shrublands" = "S",
                              "Forests" = "T",
                              "Anthropogenic" = "V")) %>%
  ggplot(aes(Level, g, color = Habitat, fill = Habitat)) + 
  geom_bar(stat = "identity", position = "dodge") +
  facet_grid(Treatment ~ Habitat, scale = "free") +
  scale_y_continuous(labels = scales::number_format(accuracy = .1)) +
  ggthemes::theme_tufte() +
  theme(text = element_text(family = "sans"),
        legend.position = "bottom", legend.box = "horizontal", legend.margin = margin(),
        legend.title = element_blank(),
        legend.text = element_text(size = 12, color = "black"),
        panel.background = element_rect(color = "black", fill = NULL),
        axis.text = element_text(size = 12, color = "black"),
        strip.placement = "outside",
        strip.text = element_text(size = 12, color = "black")) +
  #guides(colour = guide_legend(nrow = 1)) +
  geom_jitter(shape = 16, position = position_jitter(0.05), alpha = 0.1) +
  scale_color_manual(values = c("purple", "deepskyblue3","orange", "gold", "firebrick", "olivedrab")) +
  scale_fill_manual(values = c("purple", "deepskyblue3","orange", "gold", "firebrick", "olivedrab")) -> bars;  bars

ggsave(bars, file = "results/figures/bars.png", bg = "white", 
       path = NULL, scale = 1, width = 173, height = 150, units = "mm", dpi = 600)

