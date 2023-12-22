# devtools::install_github("jinyizju/U.PhyloMaker")
library(tidyverse); library(U.PhyloMaker)

rm(list = ls())

### Study species

read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1") %>%
  select(species, family) %>%
  unique %>%
  separate(species, into = c("genus", "epithet"), sep = " ", remove = FALSE) %>%
  select(species, genus, family) %>%
  unique %>%
  mutate(family = fct_recode(family, 
                             "Asteraceae" = "Compositae",
                             "Fabaceae" = "Leguminosae",
                             "Asphodelaceae" = "Xanthorrhoeaceae")) %>%
  arrange(species) %>%
  na.omit %>%
  mutate(species.relative = ifelse(species == "Soda inermis", "Salsola soda", "")) %>%
  mutate(genus.relative = ifelse(genus == "Soda", "Salsola", "")) -> 
  ranks1

### Genus list for PhyloMaker

read.csv("data/plant_genus_list.csv") -> gen.list

### Load megatree

read.tree("data/plant_megatree.tre") -> megatree

### Generate tree

phylo.maker(ranks1, 
            megatree, 
            gen.list, 
            nodes.type = 1, 
            scenario = 3) ->
  tree

### Tree match stats

tree$sp.list %>%
  group_by(output.note) %>% tally

### Save

write.csv(tree$sp.list, "results/phylo-tree/output_splist.csv", fileEncoding = "latin1", row.names = FALSE)
write.tree(tree$phylo, "results/phylo-tree/disturbance.tre")