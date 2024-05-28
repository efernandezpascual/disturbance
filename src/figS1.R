library(tidyverse); library(ggtree); library(tidytree); library(phangorn)

### Map

load("data/coordinates.RData")

coordinates %>%
  mutate(collection_latitude = as.numeric(collection_latitude), 
         collection_longitude = as.numeric(collection_longitude)) %>%
  select(collection_latitude, collection_longitude) %>%
  na.omit %>%
  unique %>%
  ggplot(aes(x = collection_longitude, y = collection_latitude)) +
  geom_polygon(data = map_data("world"), aes(x = long, y = lat, group = group), 
               color = "black", fill = "grey88", size = 0.25, show.legend = FALSE) +
  geom_point(size = 1, shape = 21, color = "black", fill = "limegreen") +
  ggthemes::theme_tufte() +
  coord_fixed(xlim = c(-15,45), ylim = c(30, 70)) +
  labs(title = "(A) Origin of the germination records") +
  theme(text = element_text(family = "sans"),
        panel.border = element_rect(color = "white", fill = NA),
        panel.background = element_rect(color = "white", fill = NULL),
        plot.title = element_text(size = 10),
        legend.position = "bottom",
        legend.direction = "horizontal",
        legend.background = element_blank(),
        legend.box.background = element_rect(colour = NA),
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 8),
        legend.justification = "left",
        legend.margin = margin(0, 0, 0, 0),
        legend.box.margin = margin(-10, -10, 0, 0),
        axis.text = element_blank(),
        axis.ticks = element_blank(),             
        plot.margin = unit(c(0.5, 0.5, 0.5, 0.5), "cm"),
        axis.title = element_blank()) -> f1; f1

### Phylotree

phangorn::nnls.tree(cophenetic(ape::read.tree("results/phylo-tree/disturbance.tre")),
                    ape::read.tree("results/phylo-tree/disturbance.tre"), method = "ultrametric") ->
  nnls_orig

nnls_orig$tip.label %>%
  data.frame %>%
  separate(".", into = c("genus", "species"), sep = "_", remove = FALSE) %>%
  mutate(species = paste(genus, species, sep = " ")) %>%
  merge(read.csv("data/plant_genus_list.csv")) -> species

species$family %>%
  unique %>%
  as.character() -> families

taxize::classification(families, db = "gbif") -> 
  taxonomy # Extract higher taxonomical ranks

as.data.frame(t(sapply(names(taxonomy), function (x) taxonomy[[x]] [, 1])[c(5, 4), ])) %>%
  remove_rownames() %>%
  rename(family = V1, order = V2) -> orders

as.data.frame(t(sapply(names(taxonomy), function (x) taxonomy[[x]] [, 1])[c(5, 3), ]))  %>%
  remove_rownames() %>%
  rename(family = V1, class = V2) -> classes

species %>%
  mutate(label = gsub(" ", "_", species)) %>%
  merge(orders, all.x = TRUE) %>%
  merge(classes, all.x = TRUE) %>%
  select(label, species, genus, family, order, class) %>%
  merge(read.csv("data/clades.csv"), all.x = TRUE) %>%
  as_tibble() %>%
  select(label, 
         species,
         genus,
         family,
         order,
         class,
         clade,
         group) -> 
  ranks 

nnls_orig %>% 
  as_tibble %>%
  full_join(ranks, by = "label") -> o1

o1 %>%
  group_by(clade) %>%
  tally

o1$clade -> o1$label

as.phylo(o1) -> o1

ggtree(o1, layout = "circular", aes(color = label), key_glyph = "rect") +
  scale_color_manual(values = c("gold",
                                "forestgreen",
                                "magenta",
                                "darkorchid",
                                "darkred",
                                "black"),
                     breaks = c("Basal eudicots", "Monocots", "Nymphaeales",
                                "Superasterids", "Superrosids")) +
  guides(color = guide_legend(title = "Clade")) +
  theme(text = element_text(family = "sans")) +
  labs(title = "(B) Phylogeny of the germination dataset") +
  theme(plot.margin = unit(c(0,0,0,0), "mm") ,
        plot.title = element_text(size = 10)) -> f2; f2

### Habitats

load("data/habitats.RData")

eunis %>%
  mutate(eunis = fct_recode(eunis, "Coastal" = "N",
                            "Wetlands" = "Q",
                            "Grasslands" = "R",
                            "Shrublands" = "S",
                            "Forests" = "T",
                            "Anthropogenic" = "V")) %>%
  ggplot(aes(eunis, species, fill = eunis)) +
  geom_bar(stat = "identity", position = "dodge", color = "black") + 
  scale_fill_manual(values = c("turquoise",
                                "red4",
                                "yellowgreen",
                                "gold",
                                "limegreen",
                                "purple3"))+
  ggthemes::theme_tufte() +
  xlab("EUNIS habitats") + 
  ylab("Number of species") +
  labs(title = "(C) Species per habitat") +
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
        axis.text = element_text(size = 6, color = "black"),
        plot.margin = unit(c(0.1,0.1,0.1,0.1), "cm")) -> f3; f3

eunis %>%
  mutate(eunis = fct_recode(eunis, "Coastal" = "N",
                            "Wetlands" = "Q",
                            "Grasslands" = "R",
                            "Shrublands" = "S",
                            "Forests" = "T",
                            "Anthropogenic" = "V")) %>%
  ggplot(aes(eunis, records, fill = eunis)) +
  geom_bar(stat = "identity", position = "dodge", color = "black") + 
  scale_fill_manual(values = c("turquoise",
                               "red4",
                               "yellowgreen",
                               "gold",
                               "limegreen",
                               "purple3"))+
  ggthemes::theme_tufte() +
  xlab("EUNIS habitats") + 
  ylab("Number of records") +
  labs(title = "(D) Germination records per habitat") +
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
        axis.text = element_text(size = 6, color = "black"),
        plot.margin = unit(c(0.1,0.1,0.1,0.1), "cm")) -> f4; f4

### Merge

gridExtra::grid.arrange(f1, f2, nrow = 1) -> fS1A
gridExtra::grid.arrange(f3, f4, nrow = 1) -> fS1B
gridExtra::grid.arrange(fS1A, fS1B, nrow = 2) -> fS1

ggsave(fS1, file = "results/supplementary/figS1.png", bg = "white",
       path = NULL, scale = 1, width = 180, height = 150, units = "mm", dpi = 600)

