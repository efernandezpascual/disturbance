# devtools::install_github("jinyizju/U.PhyloMaker")
library(tidyverse); library(U.PhyloMaker)

rm(list = ls())

### Study species

read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1") %>%
  select(species) %>%
  unique %>%
  separate(species, into = c("genus", "epithet"), sep = " ", remove = FALSE) %>%
  select(species, genus) %>%
  unique %>%
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

### Save

write.tree(tree, "results/phylo-tree/disturbance.tre")
