# # library(tidyverse); library(phangorn)
# # 
# # rm(list = ls())
# # 
# # merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1"), 
# #       read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1"), 
# #       by = "species") %>%
# #   mutate(animal = gsub(" ", "_", species)) %>%
# #   filter(species != "Soda inermis") %>%
# #   select(-family) -> germination
# # 
# # germination %>%
# #   select(species, temperature) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 2) %>%
# #   pull(species) -> temperaturespp
# # 
# # germination %>%
# #   select(species, alternating) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> alternatingspp
# # 
# # germination %>%
# #   select(species, light) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> lightspp
# # 
# # germination %>%
# #   select(species, ws) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> wsspp
# # 
# # germination %>%
# #   select(species, cs) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> csspp
# # 
# # germination %>%
# #   select(species, scarified) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> scarifiedspp
# # 
# # ### Read tree
# # 
# # phangorn::nnls.tree(cophenetic(ape::read.tree("results/phylo-tree/disturbance.tre")), 
# #                     ape::read.tree("results/phylo-tree/disturbance.tre"), method = "ultrametric") -> 
# #   nnls_orig
# # 
# # nnls_orig$node.label <- NULL
# # 
# # ### Set number of iterations
# # nite = 1000000
# # nbur = 100000
# # nthi = 10000
# # 
# # # Less iterations
# # nite = 100000
# # nbur = 1000
# # nthi = 100
# # 
# # ### Set priors for germination models (as many prior as random factors)
# # 
# # priors <- list(R = list(V = 1, nu = 50), 
# #                G = list(G1 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500), 
# #                         G2 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G3 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G4 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G5 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G6 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G7 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G8 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G9 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500)))   
# # 
# # ### Model 1: main effects
# # 
# # MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
# #                      scale(temperature) +
# #                      scale(alternating) +
# #                      scale(light) +
# #                      scale(cs) +
# #                      scale(ws) +
# #                      scale(scarified),
# #                    random = ~ animal + 
# #                      species + 
# #                      datasourceGUID +
# #                      country + 
# #                      seedlotGUID +
# #                      commercial +
# #                      stored +
# #                      sterilization + 
# #                      substrate,
# #                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
# #                    nitt = nite, thin = nthi, burnin = nbur,
# #                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# # 
# # summary(m1)
# # save(m1, file = "results/models/main-effects.Rdata")
# # 
# # ### Model 2: temperature
# # 
# # MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
# #                      scale(temperature) * scale(severity) +
# #                      scale(temperature) * scale(frequency) +
# #                      scale(temperature) * scale(mowing) +
# #                      scale(temperature) * scale(grazing) +
# #                      scale(temperature) * scale(soil),
# #                    random = ~ animal + 
# #                      species + 
# #                      datasourceGUID +
# #                      country + 
# #                      seedlotGUID +
# #                      commercial +
# #                      stored +
# #                      sterilization + 
# #                      substrate,
# #                    family = "multinomial2", pedigree = nnls_orig, prior = priors, 
# #                    data = filter(germination, species %in% temperaturespp),
# #                    nitt = nite, thin = nthi, burnin = nbur,
# #                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m2
# # 
# # summary(m2)
# # save(m2, file = "results/models/temperature.Rdata")
# # 
# # ### Model 3: alternating
# # 
# # MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
# #                      scale(alternating) * scale(severity) +
# #                      scale(alternating) * scale(frequency) +
# #                      scale(alternating) * scale(mowing) +
# #                      scale(alternating) * scale(grazing) +
# #                      scale(alternating) * scale(soil),
# #                    random = ~ animal + 
# #                      species + 
# #                      datasourceGUID +
# #                      country + 
# #                      seedlotGUID +
# #                      commercial +
# #                      stored +
# #                      sterilization + 
# #                      substrate,
# #                    family = "multinomial2", pedigree = nnls_orig, prior = priors, 
# #                    data = filter(germination, species %in% alternatingspp),
# #                    nitt = nite, thin = nthi, burnin = nbur,
# #                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m3
# # 
# # summary(m3)
# # save(m3, file = "results/models/alternating.Rdata")
# # 
# # ### Model 4: light
# # 
# # MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
# #                      scale(light) * scale(severity) +
# #                      scale(light) * scale(frequency) +
# #                      scale(light) * scale(mowing) +
# #                      scale(light) * scale(grazing) +
# #                      scale(light) * scale(soil),
# #                    random = ~ animal + 
# #                      species + 
# #                      datasourceGUID +
# #                      country + 
# #                      seedlotGUID +
# #                      commercial +
# #                      stored +
# #                      sterilization + 
# #                      substrate,
# #                    family = "multinomial2", pedigree = nnls_orig, prior = priors, 
# #                    data = filter(germination, species %in% lightspp),
# #                    nitt = nite, thin = nthi, burnin = nbur,
# #                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m4
# # 
# # summary(m4)
# # save(m4, file = "results/models/light.Rdata")
# # 
# # ### Model 5: warm stratification
# # 
# # MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
# #                      scale(ws) * scale(severity) +
# #                      scale(ws) * scale(frequency) +
# #                      scale(ws) * scale(mowing) +
# #                      scale(ws) * scale(grazing) +
# #                      scale(ws) * scale(soil),
# #                    random = ~ animal + 
# #                      species + 
# #                      datasourceGUID +
# #                      country + 
# #                      seedlotGUID +
# #                      commercial +
# #                      stored +
# #                      sterilization + 
# #                      substrate,
# #                    family = "multinomial2", pedigree = nnls_orig, prior = priors, 
# #                    data = filter(germination, species %in% wsspp),
# #                    nitt = nite, thin = nthi, burnin = nbur,
# #                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m5
# # 
# # summary(m5)
# # save(m5, file = "results/models/ws.Rdata")
# # 
# # ### Model 6: cold stratification
# # 
# # MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
# #                      scale(cs) * scale(severity) +
# #                      scale(cs) * scale(frequency) +
# #                      scale(cs) * scale(mowing) +
# #                      scale(cs) * scale(grazing) +
# #                      scale(cs) * scale(soil),
# #                    random = ~ animal + 
# #                      species + 
# #                      datasourceGUID +
# #                      country + 
# #                      seedlotGUID +
# #                      commercial +
# #                      stored +
# #                      sterilization + 
# #                      substrate,
# #                    family = "multinomial2", pedigree = nnls_orig, prior = priors, 
# #                    data = filter(germination, species %in% csspp),
# #                    nitt = nite, thin = nthi, burnin = nbur,
# #                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m6
# # 
# # summary(m6)
# # save(m6, file = "results/models/cs.Rdata")
# # 
# # ### Model 7: scarified
# # 
# # MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
# #                      scale(scarified) * scale(severity) +
# #                      scale(scarified) * scale(frequency) +
# #                      scale(scarified) * scale(mowing) +
# #                      scale(scarified) * scale(grazing) +
# #                      scale(scarified) * scale(soil),
# #                    random = ~ animal + 
# #                      species + 
# #                      datasourceGUID +
# #                      country + 
# #                      seedlotGUID +
# #                      commercial +
# #                      stored +
# #                      sterilization + 
# #                      substrate,
# #                    family = "multinomial2", pedigree = nnls_orig, prior = priors, 
# #                    data = filter(germination, species %in% scarifiedspp),
# #                    nitt = nite, thin = nthi, burnin = nbur,
# #                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m7
# # 
# # summary(m7)
# # save(m7, file = "results/models/scarified.Rdata")
# # 
# # ### Models with species in tree only
# # 
# # library(tidyverse); library(phangorn)
# # 
# # rm(list = ls())
# # 
# # read.csv("results/phylo-tree/output_splist.csv", fileEncoding = "latin1") %>%
# #   filter(output.note == "present in megatree") %>% pull(species) -> treespp
# # 
# # merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1"), 
# #       read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1"), 
# #       by = "species") %>%
# #   mutate(animal = gsub(" ", "_", species)) %>%
# #   filter(species != "Soda inermis") %>%
# #   filter(species %in% treespp) %>%
# #   select(-family) -> germination
# # 
# # germination %>%
# #   select(species, temperature) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 2) %>%
# #   pull(species) -> temperaturespp
# # 
# # germination %>%
# #   select(species, alternating) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> alternatingspp
# # 
# # germination %>%
# #   select(species, light) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> lightspp
# # 
# # germination %>%
# #   select(species, ws) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> wsspp
# # 
# # germination %>%
# #   select(species, cs) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> csspp
# # 
# # germination %>%
# #   select(species, scarified) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> scarifiedspp
# # 
# # ### Read tree
# # 
# # phangorn::nnls.tree(cophenetic(ape::read.tree("results/phylo-tree/disturbance.tre")), 
# #                     ape::read.tree("results/phylo-tree/disturbance.tre"), method = "ultrametric") -> 
# #   nnls_orig
# # 
# # nnls_orig$node.label <- NULL
# # 
# # ### Set number of iterations
# # nite = 1000000
# # nbur = 10000
# # nthi = 1000
# # 
# # # Less iterations
# # nite = 100000
# # nbur = 1000
# # nthi = 100
# # 
# # ### Set priors for germination models (as many prior as random factors)
# # 
# # priors <- list(R = list(V = 1, nu = 50), 
# #                G = list(G1 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500), 
# #                         G2 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G3 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G4 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G5 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G6 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G7 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G8 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G9 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500)))   
# # 
# # ### Model 1: main effects
# # 
# # MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
# #                      scale(temperature) +
# #                      scale(alternating) +
# #                      scale(light) +
# #                      scale(cs) +
# #                      scale(ws) +
# #                      scale(scarified),
# #                    random = ~ animal + 
# #                      species + 
# #                      datasourceGUID +
# #                      country + 
# #                      seedlotGUID +
# #                      commercial +
# #                      stored +
# #                      sterilization + 
# #                      substrate,
# #                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
# #                    nitt = nite, thin = nthi, burnin = nbur,
# #                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# # 
# # summary(m1)
# # save(m1, file = "results/models/species-in-tree/main-effects.Rdata")
# # 
# # ### Model 2: temperature
# # 
# # MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
# #                      scale(temperature) * scale(severity) +
# #                      scale(temperature) * scale(frequency) +
# #                      scale(temperature) * scale(mowing) +
# #                      scale(temperature) * scale(grazing) +
# #                      scale(temperature) * scale(soil),
# #                    random = ~ animal + 
# #                      species + 
# #                      datasourceGUID +
# #                      country + 
# #                      seedlotGUID +
# #                      commercial +
# #                      stored +
# #                      sterilization + 
# #                      substrate,
# #                    family = "multinomial2", pedigree = nnls_orig, prior = priors, 
# #                    data = filter(germination, species %in% temperaturespp),
# #                    nitt = nite, thin = nthi, burnin = nbur,
# #                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m2
# # 
# # summary(m2)
# # save(m2, file = "results/models/species-in-tree/temperature.Rdata")
# # 
# # ### Model 3: alternating
# # 
# # MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
# #                      scale(alternating) * scale(severity) +
# #                      scale(alternating) * scale(frequency) +
# #                      scale(alternating) * scale(mowing) +
# #                      scale(alternating) * scale(grazing) +
# #                      scale(alternating) * scale(soil),
# #                    random = ~ animal + 
# #                      species + 
# #                      datasourceGUID +
# #                      country + 
# #                      seedlotGUID +
# #                      commercial +
# #                      stored +
# #                      sterilization + 
# #                      substrate,
# #                    family = "multinomial2", pedigree = nnls_orig, prior = priors, 
# #                    data = filter(germination, species %in% alternatingspp),
# #                    nitt = nite, thin = nthi, burnin = nbur,
# #                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m3
# # 
# # summary(m3)
# # save(m3, file = "results/models/species-in-tree/alternating.Rdata")
# # 
# # ### Model 4: light
# # 
# # MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
# #                      scale(light) * scale(severity) +
# #                      scale(light) * scale(frequency) +
# #                      scale(light) * scale(mowing) +
# #                      scale(light) * scale(grazing) +
# #                      scale(light) * scale(soil),
# #                    random = ~ animal + 
# #                      species + 
# #                      datasourceGUID +
# #                      country + 
# #                      seedlotGUID +
# #                      commercial +
# #                      stored +
# #                      sterilization + 
# #                      substrate,
# #                    family = "multinomial2", pedigree = nnls_orig, prior = priors, 
# #                    data = filter(germination, species %in% lightspp),
# #                    nitt = nite, thin = nthi, burnin = nbur,
# #                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m4
# # 
# # summary(m4)
# # save(m4, file = "results/models/species-in-tree/light.Rdata")
# # 
# # ### Model 5: warm stratification
# # 
# # MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
# #                      scale(ws) * scale(severity) +
# #                      scale(ws) * scale(frequency) +
# #                      scale(ws) * scale(mowing) +
# #                      scale(ws) * scale(grazing) +
# #                      scale(ws) * scale(soil),
# #                    random = ~ animal + 
# #                      species + 
# #                      datasourceGUID +
# #                      country + 
# #                      seedlotGUID +
# #                      commercial +
# #                      stored +
# #                      sterilization + 
# #                      substrate,
# #                    family = "multinomial2", pedigree = nnls_orig, prior = priors, 
# #                    data = filter(germination, species %in% wsspp),
# #                    nitt = nite, thin = nthi, burnin = nbur,
# #                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m5
# # 
# # summary(m5)
# # save(m5, file = "results/models/species-in-tree/ws.Rdata")
# # 
# # ### Model 6: cold stratification
# # 
# # MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
# #                      scale(cs) * scale(severity) +
# #                      scale(cs) * scale(frequency) +
# #                      scale(cs) * scale(mowing) +
# #                      scale(cs) * scale(grazing) +
# #                      scale(cs) * scale(soil),
# #                    random = ~ animal + 
# #                      species + 
# #                      datasourceGUID +
# #                      country + 
# #                      seedlotGUID +
# #                      commercial +
# #                      stored +
# #                      sterilization + 
# #                      substrate,
# #                    family = "multinomial2", pedigree = nnls_orig, prior = priors, 
# #                    data = filter(germination, species %in% csspp),
# #                    nitt = nite, thin = nthi, burnin = nbur,
# #                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m6
# # 
# # summary(m6)
# # save(m6, file = "results/models/species-in-tree/cs.Rdata")
# # 
# # ### Model 7: scarified
# # 
# # MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
# #                      scale(scarified) * scale(severity) +
# #                      scale(scarified) * scale(frequency) +
# #                      scale(scarified) * scale(mowing) +
# #                      scale(scarified) * scale(grazing) +
# #                      scale(scarified) * scale(soil),
# #                    random = ~ animal + 
# #                      species + 
# #                      datasourceGUID +
# #                      country + 
# #                      seedlotGUID +
# #                      commercial +
# #                      stored +
# #                      sterilization + 
# #                      substrate,
# #                    family = "multinomial2", pedigree = nnls_orig, prior = priors, 
# #                    data = filter(germination, species %in% scarifiedspp),
# #                    nitt = nite, thin = nthi, burnin = nbur,
# #                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m7
# # 
# # summary(m7)
# # save(m7, file = "results/models/species-in-tree/scarified.Rdata")
# # 
# # ### Full models all species
# # 
# # library(tidyverse); library(phangorn)
# # 
# # rm(list = ls())
# # 
# # merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1"), 
# #       read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1"), 
# #       by = "species") %>%
# #   mutate(animal = gsub(" ", "_", species)) %>%
# #   filter(species != "Soda inermis") %>%
# #   select(-family) -> germination
# # 
# # germination %>%
# #   select(species, temperature) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 2) %>%
# #   pull(species) -> temperaturespp
# # 
# # germination %>%
# #   select(species, alternating) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> alternatingspp
# # 
# # germination %>%
# #   select(species, light) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> lightspp
# # 
# # germination %>%
# #   select(species, ws) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> wsspp
# # 
# # germination %>%
# #   select(species, cs) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> csspp
# # 
# # germination %>%
# #   select(species, scarified) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> scarifiedspp
# # 
# # ### Read tree
# # 
# # phangorn::nnls.tree(cophenetic(ape::read.tree("results/phylo-tree/disturbance.tre")), 
# #                     ape::read.tree("results/phylo-tree/disturbance.tre"), method = "ultrametric") -> 
# #   nnls_orig
# # 
# # nnls_orig$node.label <- NULL
# # 
# # ### Set number of iterations
# # nite = 1000000
# # nbur = 100000
# # nthi = 10000
# # 
# # # Less iterations
# # nite = 100000
# # nbur = 1000
# # nthi = 100
# # 
# # # # Less iterations
# # # nite = 100
# # # nbur = 10
# # # nthi = 1
# # 
# # ### Set priors for germination models (as many prior as random factors)
# # 
# # priors <- list(R = list(V = 1, nu = 50), 
# #                G = list(G1 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500), 
# #                         G2 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G3 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G4 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G5 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G6 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G7 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G8 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G9 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500)))   
# # 
# # ### Model 1: main effects
# # 
# # MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
# #                      scale(temperature) +
# #                      scale(alternating) +
# #                      scale(light) +
# #                      scale(cs) +
# #                      scale(ws) +
# #                      scale(scarified) +
# #                      scale(temperature) * scale(severity) +
# #                      scale(temperature) * scale(frequency) +
# #                      scale(temperature) * scale(mowing) +
# #                      scale(temperature) * scale(grazing) +
# #                      scale(temperature) * scale(soil) +
# #                      scale(alternating) * scale(severity) +
# #                      scale(alternating) * scale(frequency) +
# #                      scale(alternating) * scale(mowing) +
# #                      scale(alternating) * scale(grazing) +
# #                      scale(alternating) * scale(soil) +
# #                      scale(light) * scale(severity) +
# #                      scale(light) * scale(frequency) +
# #                      scale(light) * scale(mowing) +
# #                      scale(light) * scale(grazing) +
# #                      scale(light) * scale(soil) +
# #                      scale(cs) * scale(severity) +
# #                      scale(cs) * scale(frequency) +
# #                      scale(cs) * scale(mowing) +
# #                      scale(cs) * scale(grazing) +
# #                      scale(cs) * scale(soil) + 
# #                      scale(ws) * scale(severity) +
# #                      scale(ws) * scale(frequency) +
# #                      scale(ws) * scale(mowing) +
# #                      scale(ws) * scale(grazing) +
# #                      scale(ws) * scale(soil) +
# #                      scale(scarified) * scale(severity) +
# #                      scale(scarified) * scale(frequency) +
# #                      scale(scarified) * scale(mowing) +
# #                      scale(scarified) * scale(grazing) +
# #                      scale(scarified) * scale(soil),
# #                    random = ~ animal + 
# #                      species + 
# #                      datasourceGUID +
# #                      country + 
# #                      seedlotGUID +
# #                      commercial +
# #                      stored +
# #                      sterilization + 
# #                      substrate,
# #                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
# #                    nitt = nite, thin = nthi, burnin = nbur,
# #                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# # 
# # summary(m1)
# # save(m1, file = "results/models/full/all-spp.Rdata")
# # 
# # ### Full models quality spp
# # 
# # library(tidyverse); library(phangorn)
# # 
# # rm(list = ls())
# # 
# # merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1"), 
# #       read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1"), 
# #       by = "species") %>%
# #   mutate(animal = gsub(" ", "_", species)) %>%
# #   filter(species != "Soda inermis") %>%
# #   select(-family) -> germination
# # 
# # germination %>%
# #   select(species, temperature) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 2) %>%
# #   pull(species) -> temperaturespp
# # 
# # germination %>%
# #   select(species, alternating) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> alternatingspp
# # 
# # germination %>%
# #   select(species, light) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> lightspp
# # 
# # germination %>%
# #   select(species, ws) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> wsspp
# # 
# # germination %>%
# #   select(species, cs) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> csspp
# # 
# # germination %>%
# #   select(species, scarified) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> scarifiedspp
# # 
# # germination %>%
# #   filter(species %in% temperaturespp |
# #            species %in% alternatingspp |
# #            species %in% lightspp |
# #            species %in% csspp |
# #            species %in% wsspp |
# #            species %in% scarifiedspp) -> germination
# # 
# # ### Read tree
# # 
# # phangorn::nnls.tree(cophenetic(ape::read.tree("results/phylo-tree/disturbance.tre")), 
# #                     ape::read.tree("results/phylo-tree/disturbance.tre"), method = "ultrametric") -> 
# #   nnls_orig
# # 
# # nnls_orig$node.label <- NULL
# # 
# # ### Set number of iterations
# # nite = 1000000
# # nbur = 100000
# # nthi = 10000
# # 
# # # Less iterations
# # nite = 100000
# # nbur = 1000
# # nthi = 100
# # 
# # # # Less iterations
# # # nite = 100
# # # nbur = 10
# # # nthi = 1
# # 
# # ### Set priors for germination models (as many prior as random factors)
# # 
# # priors <- list(R = list(V = 1, nu = 50), 
# #                G = list(G1 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500), 
# #                         G2 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G3 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G4 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G5 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G6 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G7 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G8 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G9 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500)))   
# # 
# # ### Model 1: main effects
# # 
# # MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
# #                      scale(temperature) +
# #                      scale(alternating) +
# #                      scale(light) +
# #                      scale(cs) +
# #                      scale(ws) +
# #                      scale(scarified) +
# #                      scale(temperature) * scale(severity) +
# #                      scale(temperature) * scale(frequency) +
# #                      scale(temperature) * scale(mowing) +
# #                      scale(temperature) * scale(grazing) +
# #                      scale(temperature) * scale(soil) +
# #                      scale(alternating) * scale(severity) +
# #                      scale(alternating) * scale(frequency) +
# #                      scale(alternating) * scale(mowing) +
# #                      scale(alternating) * scale(grazing) +
# #                      scale(alternating) * scale(soil) +
# #                      scale(light) * scale(severity) +
# #                      scale(light) * scale(frequency) +
# #                      scale(light) * scale(mowing) +
# #                      scale(light) * scale(grazing) +
# #                      scale(light) * scale(soil) +
# #                      scale(cs) * scale(severity) +
# #                      scale(cs) * scale(frequency) +
# #                      scale(cs) * scale(mowing) +
# #                      scale(cs) * scale(grazing) +
# #                      scale(cs) * scale(soil) + 
# #                      scale(ws) * scale(severity) +
# #                      scale(ws) * scale(frequency) +
# #                      scale(ws) * scale(mowing) +
# #                      scale(ws) * scale(grazing) +
# #                      scale(ws) * scale(soil) +
# #                      scale(scarified) * scale(severity) +
# #                      scale(scarified) * scale(frequency) +
# #                      scale(scarified) * scale(mowing) +
# #                      scale(scarified) * scale(grazing) +
# #                      scale(scarified) * scale(soil),
# #                    random = ~ animal + 
# #                      species + 
# #                      datasourceGUID +
# #                      country + 
# #                      seedlotGUID +
# #                      commercial +
# #                      stored +
# #                      sterilization + 
# #                      substrate,
# #                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
# #                    nitt = nite, thin = nthi, burnin = nbur,
# #                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# # 
# # summary(m1)
# # save(m1, file = "results/models/full/quality-spp.Rdata")
# # 
# # ### Full models quality and tree match
# # 
# # library(tidyverse); library(phangorn)
# # 
# # rm(list = ls())
# # 
# # merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1"), 
# #       read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1"), 
# #       by = "species") %>%
# #   mutate(animal = gsub(" ", "_", species)) %>%
# #   filter(species != "Soda inermis") %>%
# #   select(-family) -> germination
# # 
# # germination %>%
# #   select(species, temperature) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 2) %>%
# #   pull(species) -> temperaturespp
# # 
# # germination %>%
# #   select(species, alternating) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> alternatingspp
# # 
# # germination %>%
# #   select(species, light) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> lightspp
# # 
# # germination %>%
# #   select(species, ws) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> wsspp
# # 
# # germination %>%
# #   select(species, cs) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> csspp
# # 
# # germination %>%
# #   select(species, scarified) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> scarifiedspp
# # 
# # read.csv("results/phylo-tree/output_splist.csv", fileEncoding = "latin1") %>%
# #   filter(output.note == "present in megatree") %>% pull(species) -> treespp
# # 
# # germination %>%
# #   filter(species %in% temperaturespp |
# #            species %in% alternatingspp |
# #            species %in% lightspp |
# #            species %in% csspp |
# #            species %in% wsspp |
# #            species %in% scarifiedspp) %>%
# #   filter(species %in% treespp) -> germination
# # 
# # ### Read tree
# # 
# # phangorn::nnls.tree(cophenetic(ape::read.tree("results/phylo-tree/disturbance.tre")), 
# #                     ape::read.tree("results/phylo-tree/disturbance.tre"), method = "ultrametric") -> 
# #   nnls_orig
# # 
# # nnls_orig$node.label <- NULL
# # 
# # ### Set number of iterations
# # nite = 1000000
# # nbur = 100000
# # nthi = 10000
# # 
# # # Less iterations
# # nite = 100000
# # nbur = 1000
# # nthi = 100
# # 
# # # # Less iterations
# # # nite = 100
# # # nbur = 10
# # # nthi = 1
# # 
# # ### Set priors for germination models (as many prior as random factors)
# # 
# # priors <- list(R = list(V = 1, nu = 50), 
# #                G = list(G1 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500), 
# #                         G2 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G3 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G4 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G5 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G6 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G7 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G8 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G9 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500)))   
# # 
# # ### Model 1: main effects
# # 
# # MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
# #                      scale(temperature) +
# #                      scale(alternating) +
# #                      scale(light) +
# #                      scale(cs) +
# #                      scale(ws) +
# #                      scale(scarified) +
# #                      scale(temperature) * scale(severity) +
# #                      scale(temperature) * scale(frequency) +
# #                      scale(temperature) * scale(mowing) +
# #                      scale(temperature) * scale(grazing) +
# #                      scale(temperature) * scale(soil) +
# #                      scale(alternating) * scale(severity) +
# #                      scale(alternating) * scale(frequency) +
# #                      scale(alternating) * scale(mowing) +
# #                      scale(alternating) * scale(grazing) +
# #                      scale(alternating) * scale(soil) +
# #                      scale(light) * scale(severity) +
# #                      scale(light) * scale(frequency) +
# #                      scale(light) * scale(mowing) +
# #                      scale(light) * scale(grazing) +
# #                      scale(light) * scale(soil) +
# #                      scale(cs) * scale(severity) +
# #                      scale(cs) * scale(frequency) +
# #                      scale(cs) * scale(mowing) +
# #                      scale(cs) * scale(grazing) +
# #                      scale(cs) * scale(soil) + 
# #                      scale(ws) * scale(severity) +
# #                      scale(ws) * scale(frequency) +
# #                      scale(ws) * scale(mowing) +
# #                      scale(ws) * scale(grazing) +
# #                      scale(ws) * scale(soil) +
# #                      scale(scarified) * scale(severity) +
# #                      scale(scarified) * scale(frequency) +
# #                      scale(scarified) * scale(mowing) +
# #                      scale(scarified) * scale(grazing) +
# #                      scale(scarified) * scale(soil),
# #                    random = ~ animal + 
# #                      species + 
# #                      datasourceGUID +
# #                      country + 
# #                      seedlotGUID +
# #                      commercial +
# #                      stored +
# #                      sterilization + 
# #                      substrate,
# #                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
# #                    nitt = nite, thin = nthi, burnin = nbur,
# #                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# # 
# # summary(m1)
# # save(m1, file = "results/models/full/quality--match-spp.Rdata")
# # 
# # quit()
# # n
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # ### Full models all species
# # 
# # library(tidyverse); library(phangorn)
# # 
# # rm(list = ls())
# # 
# # merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1"), 
# #       read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1"), 
# #       by = "species") %>%
# #   mutate(animal = gsub(" ", "_", species)) %>%
# #   filter(species != "Soda inermis") %>%
# #   select(-family) -> germination
# # 
# # germination %>%
# #   select(species, temperature) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 2) %>%
# #   pull(species) -> temperaturespp
# # 
# # germination %>%
# #   select(species, alternating) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> alternatingspp
# # 
# # germination %>%
# #   select(species, light) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> lightspp
# # 
# # germination %>%
# #   select(species, ws) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> wsspp
# # 
# # germination %>%
# #   select(species, cs) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> csspp
# # 
# # germination %>%
# #   select(species, scarified) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> scarifiedspp
# # 
# # ### Read tree
# # 
# # phangorn::nnls.tree(cophenetic(ape::read.tree("results/phylo-tree/disturbance.tre")), 
# #                     ape::read.tree("results/phylo-tree/disturbance.tre"), method = "ultrametric") -> 
# #   nnls_orig
# # 
# # nnls_orig$node.label <- NULL
# # 
# # ### Set number of iterations
# # nite = 1000000
# # nbur = 100000
# # nthi = 10000
# # 
# # # Less iterations
# # nite = 100000
# # nbur = 1000
# # nthi = 100
# # 
# # # # Less iterations
# # # nite = 100
# # # nbur = 10
# # # nthi = 1
# # 
# # ### Set priors for germination models (as many prior as random factors)
# # 
# # priors <- list(R = list(V = 1, nu = 50), 
# #                G = list(G1 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500), 
# #                         G2 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G3 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G4 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G5 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G6 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G7 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500)))   
# # 
# # ### Model 1: main effects
# # 
# # MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
# #                      scale(temperature) +
# #                      scale(alternating) +
# #                      scale(light) +
# #                      scale(cs) +
# #                      scale(ws) +
# #                      scale(scarified) +
# #                      scale(temperature) * scale(severity) +
# #                      scale(temperature) * scale(frequency) +
# #                      scale(temperature) * scale(mowing) +
# #                      scale(temperature) * scale(grazing) +
# #                      scale(temperature) * scale(soil) +
# #                      scale(alternating) * scale(severity) +
# #                      scale(alternating) * scale(frequency) +
# #                      scale(alternating) * scale(mowing) +
# #                      scale(alternating) * scale(grazing) +
# #                      scale(alternating) * scale(soil) +
# #                      scale(light) * scale(severity) +
# #                      scale(light) * scale(frequency) +
# #                      scale(light) * scale(mowing) +
# #                      scale(light) * scale(grazing) +
# #                      scale(light) * scale(soil) +
# #                      scale(cs) * scale(severity) +
# #                      scale(cs) * scale(frequency) +
# #                      scale(cs) * scale(mowing) +
# #                      scale(cs) * scale(grazing) +
# #                      scale(cs) * scale(soil) + 
# #                      scale(ws) * scale(severity) +
# #                      scale(ws) * scale(frequency) +
# #                      scale(ws) * scale(mowing) +
# #                      scale(ws) * scale(grazing) +
# #                      scale(ws) * scale(soil) +
# #                      scale(scarified) * scale(severity) +
# #                      scale(scarified) * scale(frequency) +
# #                      scale(scarified) * scale(mowing) +
# #                      scale(scarified) * scale(grazing) +
# #                      scale(scarified) * scale(soil),
# #                    random = ~ animal + 
# #                      species + 
# #                      datasourceGUID +
# #                      country + 
# #                      seedlotGUID +
# #                      stored +
# #                      substrate,
# #                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
# #                    nitt = nite, thin = nthi, burnin = nbur,
# #                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# # 
# # summary(m1)
# # save(m1, file = "results/models/lessrf/all-spp.Rdata")
# # 
# # ### Full models quality spp
# # 
# # library(tidyverse); library(phangorn)
# # 
# # rm(list = ls())
# # 
# # merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1"), 
# #       read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1"), 
# #       by = "species") %>%
# #   mutate(animal = gsub(" ", "_", species)) %>%
# #   filter(species != "Soda inermis") %>%
# #   select(-family) -> germination
# # 
# # germination %>%
# #   select(species, temperature) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 2) %>%
# #   pull(species) -> temperaturespp
# # 
# # germination %>%
# #   select(species, alternating) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> alternatingspp
# # 
# # germination %>%
# #   select(species, light) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> lightspp
# # 
# # germination %>%
# #   select(species, ws) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> wsspp
# # 
# # germination %>%
# #   select(species, cs) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> csspp
# # 
# # germination %>%
# #   select(species, scarified) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> scarifiedspp
# # 
# # germination %>%
# #   filter(species %in% temperaturespp |
# #            species %in% alternatingspp |
# #            species %in% lightspp |
# #            species %in% csspp |
# #            species %in% wsspp |
# #            species %in% scarifiedspp) -> germination
# # 
# # ### Read tree
# # 
# # phangorn::nnls.tree(cophenetic(ape::read.tree("results/phylo-tree/disturbance.tre")), 
# #                     ape::read.tree("results/phylo-tree/disturbance.tre"), method = "ultrametric") -> 
# #   nnls_orig
# # 
# # nnls_orig$node.label <- NULL
# # 
# # ### Set number of iterations
# # nite = 1000000
# # nbur = 100000
# # nthi = 10000
# # 
# # # Less iterations
# # nite = 100000
# # nbur = 1000
# # nthi = 100
# # 
# # # # Less iterations
# # # nite = 100
# # # nbur = 10
# # # nthi = 1
# # 
# # ### Set priors for germination models (as many prior as random factors)
# # 
# # priors <- list(R = list(V = 1, nu = 50), 
# #                G = list(G1 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500), 
# #                         G2 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G3 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G4 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G5 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G6 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G7 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500)))   
# # 
# # ### Model 1: main effects
# # 
# # MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
# #                      scale(temperature) +
# #                      scale(alternating) +
# #                      scale(light) +
# #                      scale(cs) +
# #                      scale(ws) +
# #                      scale(scarified) +
# #                      scale(temperature) * scale(severity) +
# #                      scale(temperature) * scale(frequency) +
# #                      scale(temperature) * scale(mowing) +
# #                      scale(temperature) * scale(grazing) +
# #                      scale(temperature) * scale(soil) +
# #                      scale(alternating) * scale(severity) +
# #                      scale(alternating) * scale(frequency) +
# #                      scale(alternating) * scale(mowing) +
# #                      scale(alternating) * scale(grazing) +
# #                      scale(alternating) * scale(soil) +
# #                      scale(light) * scale(severity) +
# #                      scale(light) * scale(frequency) +
# #                      scale(light) * scale(mowing) +
# #                      scale(light) * scale(grazing) +
# #                      scale(light) * scale(soil) +
# #                      scale(cs) * scale(severity) +
# #                      scale(cs) * scale(frequency) +
# #                      scale(cs) * scale(mowing) +
# #                      scale(cs) * scale(grazing) +
# #                      scale(cs) * scale(soil) + 
# #                      scale(ws) * scale(severity) +
# #                      scale(ws) * scale(frequency) +
# #                      scale(ws) * scale(mowing) +
# #                      scale(ws) * scale(grazing) +
# #                      scale(ws) * scale(soil) +
# #                      scale(scarified) * scale(severity) +
# #                      scale(scarified) * scale(frequency) +
# #                      scale(scarified) * scale(mowing) +
# #                      scale(scarified) * scale(grazing) +
# #                      scale(scarified) * scale(soil),
# #                    random = ~ animal + 
# #                      species + 
# #                      datasourceGUID +
# #                      country + 
# #                      seedlotGUID +
# #                      stored +
# #                      substrate,
# #                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
# #                    nitt = nite, thin = nthi, burnin = nbur,
# #                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# # 
# # summary(m1)
# # save(m1, file = "results/models/lessrf/quality-spp.Rdata")
# # 
# # ### Full models quality and tree match
# # 
# # library(tidyverse); library(phangorn)
# # 
# # rm(list = ls())
# # 
# # merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1"), 
# #       read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1"), 
# #       by = "species") %>%
# #   mutate(animal = gsub(" ", "_", species)) %>%
# #   filter(species != "Soda inermis") %>%
# #   select(-family) -> germination
# # 
# # germination %>%
# #   select(species, temperature) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 2) %>%
# #   pull(species) -> temperaturespp
# # 
# # germination %>%
# #   select(species, alternating) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> alternatingspp
# # 
# # germination %>%
# #   select(species, light) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> lightspp
# # 
# # germination %>%
# #   select(species, ws) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> wsspp
# # 
# # germination %>%
# #   select(species, cs) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> csspp
# # 
# # germination %>%
# #   select(species, scarified) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> scarifiedspp
# # 
# # read.csv("results/phylo-tree/output_splist.csv", fileEncoding = "latin1") %>%
# #   filter(output.note == "present in megatree") %>% pull(species) -> treespp
# # 
# # germination %>%
# #   filter(species %in% temperaturespp |
# #            species %in% alternatingspp |
# #            species %in% lightspp |
# #            species %in% csspp |
# #            species %in% wsspp |
# #            species %in% scarifiedspp) %>%
# #   filter(species %in% treespp) -> germination
# # 
# # ### Read tree
# # 
# # phangorn::nnls.tree(cophenetic(ape::read.tree("results/phylo-tree/disturbance.tre")), 
# #                     ape::read.tree("results/phylo-tree/disturbance.tre"), method = "ultrametric") -> 
# #   nnls_orig
# # 
# # nnls_orig$node.label <- NULL
# # 
# # ### Set number of iterations
# # nite = 1000000
# # nbur = 100000
# # nthi = 10000
# # 
# # # Less iterations
# # nite = 100000
# # nbur = 1000
# # nthi = 100
# # 
# # # # Less iterations
# # # nite = 100
# # # nbur = 10
# # # nthi = 1
# # 
# # ### Set priors for germination models (as many prior as random factors)
# # 
# # priors <- list(R = list(V = 1, nu = 50), 
# #                G = list(G1 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500), 
# #                         G2 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G3 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G4 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G5 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G6 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G7 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500)))   
# # 
# # ### Model 1: main effects
# # 
# # MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
# #                      scale(temperature) +
# #                      scale(alternating) +
# #                      scale(light) +
# #                      scale(cs) +
# #                      scale(ws) +
# #                      scale(scarified) +
# #                      scale(temperature) * scale(severity) +
# #                      scale(temperature) * scale(frequency) +
# #                      scale(temperature) * scale(mowing) +
# #                      scale(temperature) * scale(grazing) +
# #                      scale(temperature) * scale(soil) +
# #                      scale(alternating) * scale(severity) +
# #                      scale(alternating) * scale(frequency) +
# #                      scale(alternating) * scale(mowing) +
# #                      scale(alternating) * scale(grazing) +
# #                      scale(alternating) * scale(soil) +
# #                      scale(light) * scale(severity) +
# #                      scale(light) * scale(frequency) +
# #                      scale(light) * scale(mowing) +
# #                      scale(light) * scale(grazing) +
# #                      scale(light) * scale(soil) +
# #                      scale(cs) * scale(severity) +
# #                      scale(cs) * scale(frequency) +
# #                      scale(cs) * scale(mowing) +
# #                      scale(cs) * scale(grazing) +
# #                      scale(cs) * scale(soil) + 
# #                      scale(ws) * scale(severity) +
# #                      scale(ws) * scale(frequency) +
# #                      scale(ws) * scale(mowing) +
# #                      scale(ws) * scale(grazing) +
# #                      scale(ws) * scale(soil) +
# #                      scale(scarified) * scale(severity) +
# #                      scale(scarified) * scale(frequency) +
# #                      scale(scarified) * scale(mowing) +
# #                      scale(scarified) * scale(grazing) +
# #                      scale(scarified) * scale(soil),
# #                    random = ~ animal + 
# #                      species + 
# #                      datasourceGUID +
# #                      country + 
# #                      seedlotGUID +
# #                      stored +
# #                      substrate,
# #                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
# #                    nitt = nite, thin = nthi, burnin = nbur,
# #                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# # 
# # summary(m1)
# # save(m1, file = "results/models/lessrf/quality--match-spp.Rdata")
# 
# # ### Full models quality and tree match and no gymnos
# # 
# # library(tidyverse); library(phangorn)
# # 
# # rm(list = ls())
# # 
# # merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1"), 
# #       read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1"), 
# #       by = "species") %>%
# #   mutate(animal = gsub(" ", "_", species)) %>%
# #   filter(species != "Soda inermis") %>%
# #   filter( family %in% c("Pinaceae", "Cupressaceae", "Taxaceae", "Taxodiaceae")) %>%
# #   select(-family) -> germination
# # 
# # germination %>%
# #   group_by(species)
# # 
# # germination %>%
# #   select(species, temperature) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 2) %>%
# #   pull(species) -> temperaturespp
# # 
# # germination %>%
# #   select(species, alternating) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> alternatingspp
# # 
# # germination %>%
# #   select(species, light) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> lightspp
# # 
# # germination %>%
# #   select(species, ws) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> wsspp
# # 
# # germination %>%
# #   select(species, cs) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> csspp
# # 
# # germination %>%
# #   select(species, scarified) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> scarifiedspp
# # 
# # read.csv("results/phylo-tree/output_splist.csv", fileEncoding = "latin1") %>%
# #   filter(output.note == "present in megatree") %>% pull(species) -> treespp
# # 
# # germination %>%
# #   filter(species %in% temperaturespp |
# #            species %in% alternatingspp |
# #            species %in% lightspp |
# #            species %in% csspp |
# #            species %in% wsspp |
# #            species %in% scarifiedspp) %>%
# #   filter(species %in% treespp) -> germination
# # 
# # ### Read tree
# # 
# # phangorn::nnls.tree(cophenetic(ape::read.tree("results/phylo-tree/disturbance.tre")), 
# #                     ape::read.tree("results/phylo-tree/disturbance.tre"), method = "ultrametric") -> 
# #   nnls_orig
# # 
# # nnls_orig$node.label <- NULL
# # 
# # ### Set number of iterations
# # nite = 1000000
# # nbur = 100000
# # nthi = 10000
# # 
# # # Less iterations
# # nite = 100000
# # nbur = 1000
# # nthi = 100
# # 
# # # # Less iterations
# # # nite = 100
# # # nbur = 10
# # # nthi = 1
# # 
# # ### Set priors for germination models (as many prior as random factors)
# # 
# # priors <- list(R = list(V = 1, nu = 50), 
# #                G = list(G1 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500), 
# #                         G2 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G3 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G4 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G5 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G6 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G7 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500)))   
# # 
# # ### Model 1: main effects
# # 
# # MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
# #                      scale(temperature) +
# #                      scale(alternating) +
# #                      scale(light) +
# #                      scale(cs) +
# #                      scale(ws) +
# #                      scale(scarified) +
# #                      scale(temperature) * scale(severity) +
# #                      scale(temperature) * scale(frequency) +
# #                      scale(temperature) * scale(mowing) +
# #                      scale(temperature) * scale(grazing) +
# #                      scale(temperature) * scale(soil) +
# #                      scale(alternating) * scale(severity) +
# #                      scale(alternating) * scale(frequency) +
# #                      scale(alternating) * scale(mowing) +
# #                      scale(alternating) * scale(grazing) +
# #                      scale(alternating) * scale(soil) +
# #                      scale(light) * scale(severity) +
# #                      scale(light) * scale(frequency) +
# #                      scale(light) * scale(mowing) +
# #                      scale(light) * scale(grazing) +
# #                      scale(light) * scale(soil) +
# #                      scale(cs) * scale(severity) +
# #                      scale(cs) * scale(frequency) +
# #                      scale(cs) * scale(mowing) +
# #                      scale(cs) * scale(grazing) +
# #                      scale(cs) * scale(soil) + 
# #                      scale(ws) * scale(severity) +
# #                      scale(ws) * scale(frequency) +
# #                      scale(ws) * scale(mowing) +
# #                      scale(ws) * scale(grazing) +
# #                      scale(ws) * scale(soil) +
# #                      scale(scarified) * scale(severity) +
# #                      scale(scarified) * scale(frequency) +
# #                      scale(scarified) * scale(mowing) +
# #                      scale(scarified) * scale(grazing) +
# #                      scale(scarified) * scale(soil),
# #                    random = ~ animal + 
# #                      species + 
# #                      datasourceGUID +
# #                      country + 
# #                      seedlotGUID +
# #                      stored +
# #                      substrate,
# #                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
# #                    nitt = nite, thin = nthi, burnin = nbur,
# #                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# # 
# # summary(m1)
# # save(m1, file = "results/models/lessrf/quality-no-gymno.Rdata")
# # 
# # ### Full models all species
# # 
# # library(tidyverse); library(phangorn)
# # 
# # rm(list = ls())
# # 
# # merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1"), 
# #       read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1"), 
# #       by = "species") %>%
# #   mutate(animal = gsub(" ", "_", species)) %>%
# #   filter(species != "Soda inermis") %>%
# #   select(-family) -> germination
# # 
# # germination %>%
# #   select(species, temperature) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 2) %>%
# #   pull(species) -> temperaturespp
# # 
# # germination %>%
# #   select(species, alternating) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> alternatingspp
# # 
# # germination %>%
# #   select(species, light) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> lightspp
# # 
# # germination %>%
# #   select(species, ws) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> wsspp
# # 
# # germination %>%
# #   select(species, cs) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> csspp
# # 
# # germination %>%
# #   select(species, scarified) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> scarifiedspp
# # 
# # ### Read tree
# # 
# # phangorn::nnls.tree(cophenetic(ape::read.tree("results/phylo-tree/disturbance.tre")), 
# #                     ape::read.tree("results/phylo-tree/disturbance.tre"), method = "ultrametric") -> 
# #   nnls_orig
# # 
# # nnls_orig$node.label <- NULL
# # 
# # ### Set number of iterations
# # nite = 1000000
# # nbur = 100000
# # nthi = 10000
# # 
# # # Less iterations
# # nite = 100000
# # nbur = 1000
# # nthi = 100
# # 
# # # # Less iterations
# # # nite = 100
# # # nbur = 10
# # # nthi = 1
# # 
# # ### Set priors for germination models (as many prior as random factors)
# # 
# # priors <- list(R = list(V = 1, nu = 50), 
# #                G = list(G1 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500), 
# #                         G2 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G3 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G4 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G5 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G6 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G7 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500)))   
# # 
# # ### Model 1: main effects
# # 
# # MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
# #                      temperature +
# #                      alternating +
# #                      light +
# #                      cs +
# #                      ws +
# #                      scarified +
# #                      temperature * severity +
# #                      temperature * frequency +
# #                      temperature * mowing +
# #                      temperature * grazing +
# #                      temperature * soil +
# #                      alternating * severity +
# #                      alternating * frequency +
# #                      alternating * mowing +
# #                      alternating * grazing +
# #                      alternating * soil +
# #                      light * severity +
# #                      light * frequency +
# #                      light * mowing +
# #                      light * grazing +
# #                      light * soil +
# #                      cs * severity +
# #                      cs * frequency +
# #                      cs * mowing +
# #                      cs * grazing +
# #                      cs * soil + 
# #                      ws * severity +
# #                      ws * frequency +
# #                      ws * mowing +
# #                      ws * grazing +
# #                      ws * soil +
# #                      scarified * severity +
# #                      scarified * frequency +
# #                      scarified * mowing +
# #                      scarified * grazing +
# #                      scarified * soil,
# #                    random = ~ animal + 
# #                      species + 
# #                      datasourceGUID +
# #                      country + 
# #                      seedlotGUID +
# #                      stored +
# #                      substrate,
# #                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
# #                    nitt = nite, thin = nthi, burnin = nbur,
# #                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# # 
# # summary(m1)
# # save(m1, file = "results/models/lessrf/no-scaling.Rdata")
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# # 
# # 
# # 
# # 
# # 
# # ### Full models all species
# # 
# # library(tidyverse); library(phangorn)
# # 
# # rm(list = ls())
# # 
# # merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1"), 
# #       read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1"), 
# #       by = "species") %>%
# #   mutate(animal = gsub(" ", "_", species)) %>%
# #   filter(species != "Soda inermis") %>%
# #   select(-family) -> germination
# # 
# # germination %>%
# #   select(species, temperature) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 2) %>%
# #   pull(species) -> temperaturespp
# # 
# # germination %>%
# #   select(species, alternating) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> alternatingspp
# # 
# # germination %>%
# #   select(species, light) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> lightspp
# # 
# # germination %>%
# #   select(species, ws) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> wsspp
# # 
# # germination %>%
# #   select(species, cs) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> csspp
# # 
# # germination %>%
# #   select(species, scarified) %>%
# #   unique %>% 
# #   group_by(species) %>%
# #   tally %>%
# #   filter(n > 1) %>%
# #   pull(species) -> scarifiedspp
# # 
# # ### Read tree
# # 
# # phangorn::nnls.tree(cophenetic(ape::read.tree("results/phylo-tree/disturbance.tre")), 
# #                     ape::read.tree("results/phylo-tree/disturbance.tre"), method = "ultrametric") -> 
# #   nnls_orig
# # 
# # nnls_orig$node.label <- NULL
# # 
# # ### Set number of iterations
# # nite = 1000000
# # nbur = 100000
# # nthi = 10000
# # 
# # # Less iterations
# # nite = 100000
# # nbur = 1000
# # nthi = 100
# # 
# # # Less iterations
# # nite = 1000
# # nbur = 100
# # nthi = 10
# # 
# # ### Set priors for germination models (as many prior as random factors)
# # 
# # priors <- list(R = list(V = 1, nu = 50), 
# #                G = list(G1 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500), 
# #                         G2 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G3 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G4 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G5 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G6 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G7 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500)))   
# # 
# # ### Model 1: main effects
# # 
# # MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
# #                      scale(temperature) * scale(frequency),
# #                    random = ~ animal + 
# #                      species + 
# #                      datasourceGUID +
# #                      country + 
# #                      seedlotGUID +
# #                      stored +
# #                      substrate,
# #                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
# #                    nitt = nite, thin = nthi, burnin = nbur,
# #                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# # 
# # summary(m1)
# 
# #save(m1, file = "results/models/lessrf/no-scaling.Rdata")
# 
# # ### Coastal
# # 
# # library(tidyverse); library(phangorn)
# # 
# # rm(list = ls())
# # 
# # merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1"), 
# #       read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1"), 
# #       by = "species") %>%
# #   mutate(animal = gsub(" ", "_", species)) %>%
# #   filter(N == 1) %>%
# #   select(-family) -> germination
# # 
# # germination %>%
# #   group_by(species)
# # 
# # ### Read tree
# # 
# # phangorn::nnls.tree(cophenetic(ape::read.tree("results/phylo-tree/disturbance.tre")), 
# #                     ape::read.tree("results/phylo-tree/disturbance.tre"), method = "ultrametric") -> 
# #   nnls_orig
# # 
# # nnls_orig$node.label <- NULL
# # 
# # ### Set number of iterations
# # nite = 1000000
# # nbur = 100000
# # nthi = 10000
# # 
# # # Less iterations
# # nite = 100000
# # nbur = 20000
# # nthi = 100
# # 
# # # # # Less iterations
# # # nite = 1000
# # # nbur = 500
# # # nthi = 50
# # # 
# # # # # Less iterations
# # # nite = 100
# # # nbur = 50
# # # nthi = 5
# # 
# # ### Set priors for germination models (as many prior as random factors)
# # 
# # priors <- list(R = list(V = 1, nu = 50), 
# #                G = list(G1 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500), 
# #                         G2 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G3 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G4 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G5 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G6 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G7 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500)))   
# # 
# # ### Model 1: main effects
# # 
# # MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
# #                      scale(temperature) +
# #                      scale(alternating) +
# #                      scale(light) +
# #                      scale(cs) +
# #                      scale(scarified) +
# #                      scale(temperature) * scale(severity) +
# #                      scale(temperature) * scale(frequency) +
# #                      scale(alternating) * scale(severity) +
# #                      scale(alternating) * scale(frequency) +
# #                      scale(light) * scale(severity) +
# #                      scale(light) * scale(frequency) +
# #                      scale(cs) * scale(severity) +
# #                      scale(cs) * scale(frequency) +
# #                      scale(scarified) * scale(severity) +
# #                      scale(scarified) * scale(frequency),
# #                    random = ~ animal + 
# #                      species + 
# #                      datasourceGUID +
# #                      country + 
# #                      seedlotGUID +
# #                      stored +
# #                      substrate,
# #                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
# #                    nitt = nite, thin = nthi, burnin = nbur,
# #                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# # 
# # summary(m1)
# # save(m1, file = "results/models/simplified/coastal.Rdata")
# # 
# # summary(m1)$solutions %>%
# #   data.frame %>%
# #   rownames_to_column(var = "Parameter") %>%
# #   mutate(Parameter = fct_recode(Parameter, 
# #                                 "Intercept:Intercept" = "(Intercept)",
# #                                 "Temperature:Germination cue\n(Main effects)" = "scale(temperature)",
# #                                 "Alternating temperature:Germination cue\n(Main effects)" = "scale(alternating)",
# #                                 "Light:Germination cue\n(Main effects)" = "scale(light)",
# #                                 "Cold stratification:Germination cue\n(Main effects)" = "scale(cs)",
# #                                 "Warm stratification:Germination cue\n(Main effects)" = "scale(ws)",
# #                                 "Scarification:Germination cue\n(Main effects)" = "scale(scarified)",
# #                                 "Main effect:Disturbance\nseverity" = "scale(severity)",
# #                                 "Main effect:Disturbance\nfrequency" = "scale(frequency)",
# #                                 "Main effect:Mowing" = "scale(mowing)",
# #                                 "Main effect:Grazing" = "scale(grazing)",
# #                                 "Main effect:Soil\ndisturbance" = "scale(soil)",
# #                                 "Temperature:Disturbance\nseverity" = "scale(temperature):scale(severity)",
# #                                 "Temperature:Disturbance\nfrequency" = "scale(temperature):scale(frequency)",
# #                                 "Temperature:Mowing" = "scale(temperature):scale(mowing)",
# #                                 "Temperature:Grazing" = "scale(temperature):scale(grazing)",
# #                                 "Temperature:Soil\ndisturbance" = "scale(temperature):scale(soil)",
# #                                 "Alternating temperature:Disturbance\nseverity" = "scale(alternating):scale(severity)",
# #                                 "Alternating temperature:Disturbance\nfrequency" = "scale(alternating):scale(frequency)",
# #                                 "Alternating temperature:Mowing" = "scale(alternating):scale(mowing)",
# #                                 "Alternating temperature:Grazing" = "scale(alternating):scale(grazing)",
# #                                 "Alternating temperature:Soil\ndisturbance" = "scale(alternating):scale(soil)",
# #                                 "Light:Disturbance\nseverity" = "scale(light):scale(severity)",
# #                                 "Light:Disturbance\nfrequency" = "scale(light):scale(frequency)",
# #                                 "Light:Mowing" = "scale(light):scale(mowing)",
# #                                 "Light:Grazing" = "scale(light):scale(grazing)",
# #                                 "Light:Soil\ndisturbance" = "scale(light):scale(soil)",
# #                                 "Cold stratification:Disturbance\nseverity" = "scale(cs):scale(severity)",
# #                                 "Cold stratification:Disturbance\nfrequency" = "scale(cs):scale(frequency)",
# #                                 "Cold stratification:Mowing" = "scale(cs):scale(mowing)",
# #                                 "Cold stratification:Grazing" = "scale(cs):scale(grazing)",
# #                                 "Cold stratification:Soil\ndisturbance" = "scale(cs):scale(soil)",
# #                                 "Warm stratification:Disturbance\nseverity" = "scale(ws):scale(severity)",
# #                                 "Warm stratification:Disturbance\nfrequency" = "scale(ws):scale(frequency)",
# #                                 "Warm stratification:Mowing" = "scale(ws):scale(mowing)",
# #                                 "Warm stratification:Grazing" = "scale(ws):scale(grazing)",
# #                                 "Warm stratification:Soil\ndisturbance" = "scale(ws):scale(soil)",
# #                                 "Scarification:Disturbance\nseverity" = "scale(scarified):scale(severity)",
# #                                 "Scarification:Disturbance\nfrequency" = "scale(scarified):scale(frequency)",
# #                                 "Scarification:Mowing" = "scale(scarified):scale(mowing)",
# #                                 "Scarification:Grazing" = "scale(scarified):scale(grazing)",
# #                                 "Scarification:Soil\ndisturbance" = "scale(scarified):scale(soil)")) %>%
# #   separate(Parameter, into = c("Effect", "Group"), sep = ":") %>%
# #   mutate(Effect = fct_relevel(Effect, c("Light", 
# #                                         "Alternating temperature", 
# #                                         "Temperature", 
# #                                         "Warm stratification", 
# #                                         "Cold stratification", 
# #                                         "Scarification")),
# #          Group = fct_relevel(Group, c("Germination cue\n(Main effects)", 
# #                                       "Disturbance\nfrequency", 
# #                                       "Disturbance\nseverity", 
# #                                       "Soil\ndisturbance",
# #                                       "Mowing",
# #                                       "Grazing"))) %>%
# #   filter(! Group == "Intercept") %>%
# # filter(pMCMC <= 0.01) %>%
# #   ggplot(aes(y = Effect, x = post.mean, 
# #              xmin = l.95..CI, xmax = u.95..CI,
# #              color = Effect)) +
# #   facet_wrap(~ Group, scales = "free_x", nrow = 1) +
# #   geom_point(size = 2) +
# #   labs(x = "Effect size") +
# #   geom_errorbarh(height = .3) +
# #   geom_vline(xintercept = 0, linetype = "dashed") +
# #   scale_color_manual(values = c("#FFA500",  
# #                                 "gold", 
# #                                 "#B3EE3A", 
# #                                 "#40E0D0",
# #                                 "#5CACEE", 
# #                                 "#27408B", 
# #                                 "#A020F0",
# #                                 "#551A8B")) +
# #   ggthemes::theme_tufte() +
# #   theme(text = element_text(family = "sans", size = 12),
# #         strip.background = element_blank(),
# #         legend.position = "none", 
# #         panel.background = element_rect(color = "black", fill = NULL),
# #         axis.title.x = element_text(size = 14), 
# #         axis.title.y = element_blank(),
# #         axis.text.x = element_text(size = 7.5, color = "black"),
# #         axis.text.y = element_text(size = 14,
# #                                    color = c("#FFA500",  
# #                                              "gold", 
# #                                              "#B3EE3A", 
# #                                              "#40E0D0",
# #                                              "#5CACEE", 
# #                                              "#27408B", 
# #                                              "#A020F0",
# #                                              "#551A8B")),
# #         strip.text.x = element_text(size = 14)) -> 
# #   fig; fig
# # 
# # ## Export
# # 
# # ggsave(fig, file = "results/figures/FigHN.png", bg = "white", 
# #        path = NULL, scale = 1, width = 173, height = 173, units = "mm", dpi = 600)
# # 
# # # Calculate lambda http://www.mpcm-evolution.com/practice/online-practical-material-chapter-11/chapter-11-1-simple-model-mcmcglmm
# # 
# # lambda <- m1$VCV[,"animal"]/(m1$VCV[,"animal"] + m1$VCV[,"units"])
# # 
# # mean(lambda) %>% round(2) 
# # coda::HPDinterval(lambda)[, 1] %>% round(2) 
# # coda::HPDinterval(lambda)[, 2] %>% round(2) 
# # 
# # # Random effects
# # 
# # summary(m1)$Gcovariances
# # 
# # 
# # 
# # 
# # 
# # ### Wetland
# # 
# # library(tidyverse); library(phangorn)
# # 
# # rm(list = ls())
# # 
# # merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1"), 
# #       read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1"), 
# #       by = "species") %>%
# #   mutate(animal = gsub(" ", "_", species)) %>%
# #   filter(Q == 1) %>%
# #   select(-family) -> germination
# # 
# # germination %>%
# #   group_by(species)
# # 
# # ### Read tree
# # 
# # phangorn::nnls.tree(cophenetic(ape::read.tree("results/phylo-tree/disturbance.tre")), 
# #                     ape::read.tree("results/phylo-tree/disturbance.tre"), method = "ultrametric") -> 
# #   nnls_orig
# # 
# # nnls_orig$node.label <- NULL
# # 
# # ### Set number of iterations
# # nite = 1000000
# # nbur = 100000
# # nthi = 10000
# # 
# # # Less iterations
# # nite = 100000
# # nbur = 20000
# # nthi = 100
# # 
# # # # # Less iterations
# # # nite = 1000
# # # nbur = 500
# # # nthi = 50
# # # 
# # # # # Less iterations
# # # nite = 100
# # # nbur = 50
# # # nthi = 5
# # 
# # ### Set priors for germination models (as many prior as random factors)
# # 
# # priors <- list(R = list(V = 1, nu = 50), 
# #                G = list(G1 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500), 
# #                         G2 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G3 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G4 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G5 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G6 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G7 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500)))   
# # 
# # ### Model 1: main effects
# # 
# # MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
# #                      scale(temperature) +
# #                      scale(alternating) +
# #                      scale(light) +
# #                      scale(cs) +
# #                      scale(scarified) +
# #                      scale(temperature) * scale(severity) +
# #                      scale(temperature) * scale(frequency) +
# #                      scale(alternating) * scale(severity) +
# #                      scale(alternating) * scale(frequency) +
# #                      scale(light) * scale(severity) +
# #                      scale(light) * scale(frequency) +
# #                      scale(cs) * scale(severity) +
# #                      scale(cs) * scale(frequency) +
# #                      scale(scarified) * scale(severity) +
# #                      scale(scarified) * scale(frequency),
# #                    random = ~ animal + 
# #                      species + 
# #                      datasourceGUID +
# #                      country + 
# #                      seedlotGUID +
# #                      stored +
# #                      substrate,
# #                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
# #                    nitt = nite, thin = nthi, burnin = nbur,
# #                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# # 
# # summary(m1)
# # save(m1, file = "results/models/simplified/wetland.Rdata")
# # 
# # summary(m1)$solutions %>%
# #   data.frame %>%
# #   rownames_to_column(var = "Parameter") %>%
# #   mutate(Parameter = fct_recode(Parameter, 
# #                                 "Intercept:Intercept" = "(Intercept)",
# #                                 "Temperature:Germination cue\n(Main effects)" = "scale(temperature)",
# #                                 "Alternating temperature:Germination cue\n(Main effects)" = "scale(alternating)",
# #                                 "Light:Germination cue\n(Main effects)" = "scale(light)",
# #                                 "Cold stratification:Germination cue\n(Main effects)" = "scale(cs)",
# #                                 "Warm stratification:Germination cue\n(Main effects)" = "scale(ws)",
# #                                 "Scarification:Germination cue\n(Main effects)" = "scale(scarified)",
# #                                 "Main effect:Disturbance\nseverity" = "scale(severity)",
# #                                 "Main effect:Disturbance\nfrequency" = "scale(frequency)",
# #                                 "Main effect:Mowing" = "scale(mowing)",
# #                                 "Main effect:Grazing" = "scale(grazing)",
# #                                 "Main effect:Soil\ndisturbance" = "scale(soil)",
# #                                 "Temperature:Disturbance\nseverity" = "scale(temperature):scale(severity)",
# #                                 "Temperature:Disturbance\nfrequency" = "scale(temperature):scale(frequency)",
# #                                 "Temperature:Mowing" = "scale(temperature):scale(mowing)",
# #                                 "Temperature:Grazing" = "scale(temperature):scale(grazing)",
# #                                 "Temperature:Soil\ndisturbance" = "scale(temperature):scale(soil)",
# #                                 "Alternating temperature:Disturbance\nseverity" = "scale(alternating):scale(severity)",
# #                                 "Alternating temperature:Disturbance\nfrequency" = "scale(alternating):scale(frequency)",
# #                                 "Alternating temperature:Mowing" = "scale(alternating):scale(mowing)",
# #                                 "Alternating temperature:Grazing" = "scale(alternating):scale(grazing)",
# #                                 "Alternating temperature:Soil\ndisturbance" = "scale(alternating):scale(soil)",
# #                                 "Light:Disturbance\nseverity" = "scale(light):scale(severity)",
# #                                 "Light:Disturbance\nfrequency" = "scale(light):scale(frequency)",
# #                                 "Light:Mowing" = "scale(light):scale(mowing)",
# #                                 "Light:Grazing" = "scale(light):scale(grazing)",
# #                                 "Light:Soil\ndisturbance" = "scale(light):scale(soil)",
# #                                 "Cold stratification:Disturbance\nseverity" = "scale(cs):scale(severity)",
# #                                 "Cold stratification:Disturbance\nfrequency" = "scale(cs):scale(frequency)",
# #                                 "Cold stratification:Mowing" = "scale(cs):scale(mowing)",
# #                                 "Cold stratification:Grazing" = "scale(cs):scale(grazing)",
# #                                 "Cold stratification:Soil\ndisturbance" = "scale(cs):scale(soil)",
# #                                 "Warm stratification:Disturbance\nseverity" = "scale(ws):scale(severity)",
# #                                 "Warm stratification:Disturbance\nfrequency" = "scale(ws):scale(frequency)",
# #                                 "Warm stratification:Mowing" = "scale(ws):scale(mowing)",
# #                                 "Warm stratification:Grazing" = "scale(ws):scale(grazing)",
# #                                 "Warm stratification:Soil\ndisturbance" = "scale(ws):scale(soil)",
# #                                 "Scarification:Disturbance\nseverity" = "scale(scarified):scale(severity)",
# #                                 "Scarification:Disturbance\nfrequency" = "scale(scarified):scale(frequency)",
# #                                 "Scarification:Mowing" = "scale(scarified):scale(mowing)",
# #                                 "Scarification:Grazing" = "scale(scarified):scale(grazing)",
# #                                 "Scarification:Soil\ndisturbance" = "scale(scarified):scale(soil)")) %>%
# #   separate(Parameter, into = c("Effect", "Group"), sep = ":") %>%
# #   mutate(Effect = fct_relevel(Effect, c("Light", 
# #                                         "Alternating temperature", 
# #                                         "Temperature", 
# #                                         "Warm stratification", 
# #                                         "Cold stratification", 
# #                                         "Scarification")),
# #          Group = fct_relevel(Group, c("Germination cue\n(Main effects)", 
# #                                       "Disturbance\nfrequency", 
# #                                       "Disturbance\nseverity", 
# #                                       "Soil\ndisturbance",
# #                                       "Mowing",
# #                                       "Grazing"))) %>%
# #   filter(! Group == "Intercept") %>%
# # filter(pMCMC <= 0.01) %>%
# #   ggplot(aes(y = Effect, x = post.mean, 
# #              xmin = l.95..CI, xmax = u.95..CI,
# #              color = Effect)) +
# #   facet_wrap(~ Group, scales = "free_x", nrow = 1) +
# #   geom_point(size = 2) +
# #   labs(x = "Effect size") +
# #   geom_errorbarh(height = .3) +
# #   geom_vline(xintercept = 0, linetype = "dashed") +
# #   scale_color_manual(values = c("#FFA500",  
# #                                 "gold", 
# #                                 "#B3EE3A", 
# #                                 "#40E0D0",
# #                                 "#5CACEE", 
# #                                 "#27408B", 
# #                                 "#A020F0",
# #                                 "#551A8B")) +
# #   ggthemes::theme_tufte() +
# #   theme(text = element_text(family = "sans", size = 12),
# #         strip.background = element_blank(),
# #         legend.position = "none", 
# #         panel.background = element_rect(color = "black", fill = NULL),
# #         axis.title.x = element_text(size = 14), 
# #         axis.title.y = element_blank(),
# #         axis.text.x = element_text(size = 7.5, color = "black"),
# #         axis.text.y = element_text(size = 14,
# #                                    color = c("#FFA500",  
# #                                              "gold", 
# #                                              "#B3EE3A", 
# #                                              "#40E0D0",
# #                                              "#5CACEE", 
# #                                              "#27408B", 
# #                                              "#A020F0",
# #                                              "#551A8B")),
# #         strip.text.x = element_text(size = 14)) -> 
# #   fig; fig
# # 
# # ## Export
# # 
# # ggsave(fig, file = "results/figures/FigHQ.png", bg = "white", 
# #        path = NULL, scale = 1, width = 173, height = 173, units = "mm", dpi = 600)
# # 
# # # Calculate lambda http://www.mpcm-evolution.com/practice/online-practical-material-chapter-11/chapter-11-1-simple-model-mcmcglmm
# # 
# # lambda <- m1$VCV[,"animal"]/(m1$VCV[,"animal"] + m1$VCV[,"units"])
# # 
# # mean(lambda) %>% round(2) 
# # coda::HPDinterval(lambda)[, 1] %>% round(2) 
# # coda::HPDinterval(lambda)[, 2] %>% round(2) 
# # 
# # # Random effects
# # 
# # summary(m1)$Gcovariances
# # 
# # 
# # 
# # 
# # ### grassland
# # 
# # library(tidyverse); library(phangorn)
# # 
# # rm(list = ls())
# # 
# # merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1"), 
# #       read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1"), 
# #       by = "species") %>%
# #   mutate(animal = gsub(" ", "_", species)) %>%
# #   filter(R == 1) %>%
# #   select(-family) -> germination
# # 
# # germination %>%
# #   group_by(species)
# # 
# # ### Read tree
# # 
# # phangorn::nnls.tree(cophenetic(ape::read.tree("results/phylo-tree/disturbance.tre")), 
# #                     ape::read.tree("results/phylo-tree/disturbance.tre"), method = "ultrametric") -> 
# #   nnls_orig
# # 
# # nnls_orig$node.label <- NULL
# # 
# # ### Set number of iterations
# # nite = 1000000
# # nbur = 100000
# # nthi = 10000
# # 
# # # Less iterations
# # nite = 100000
# # nbur = 20000
# # nthi = 100
# # 
# # # # # Less iterations
# # # nite = 1000
# # # nbur = 500
# # # nthi = 50
# # # 
# # # # # Less iterations
# # # nite = 100
# # # nbur = 50
# # # nthi = 5
# # 
# # ### Set priors for germination models (as many prior as random factors)
# # 
# # priors <- list(R = list(V = 1, nu = 50), 
# #                G = list(G1 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500), 
# #                         G2 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G3 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G4 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G5 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G6 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G7 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500)))   
# # 
# # ### Model 1: main effects
# # 
# # MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
# #                      scale(temperature) +
# #                      scale(alternating) +
# #                      scale(light) +
# #                      scale(cs) +
# #                      scale(scarified) +
# #                      scale(temperature) * scale(severity) +
# #                      scale(temperature) * scale(frequency) +
# #                      scale(alternating) * scale(severity) +
# #                      scale(alternating) * scale(frequency) +
# #                      scale(light) * scale(severity) +
# #                      scale(light) * scale(frequency) +
# #                      scale(cs) * scale(severity) +
# #                      scale(cs) * scale(frequency) +
# #                      scale(scarified) * scale(severity) +
# #                      scale(scarified) * scale(frequency),
# #                    random = ~ animal + 
# #                      species + 
# #                      datasourceGUID +
# #                      country + 
# #                      seedlotGUID +
# #                      stored +
# #                      substrate,
# #                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
# #                    nitt = nite, thin = nthi, burnin = nbur,
# #                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# # 
# # summary(m1)
# # save(m1, file = "results/models/simplified/grassland.Rdata")
# # 
# # summary(m1)$solutions %>%
# #   data.frame %>%
# #   rownames_to_column(var = "Parameter") %>%
# #   mutate(Parameter = fct_recode(Parameter, 
# #                                 "Intercept:Intercept" = "(Intercept)",
# #                                 "Temperature:Germination cue\n(Main effects)" = "scale(temperature)",
# #                                 "Alternating temperature:Germination cue\n(Main effects)" = "scale(alternating)",
# #                                 "Light:Germination cue\n(Main effects)" = "scale(light)",
# #                                 "Cold stratification:Germination cue\n(Main effects)" = "scale(cs)",
# #                                 "Warm stratification:Germination cue\n(Main effects)" = "scale(ws)",
# #                                 "Scarification:Germination cue\n(Main effects)" = "scale(scarified)",
# #                                 "Main effect:Disturbance\nseverity" = "scale(severity)",
# #                                 "Main effect:Disturbance\nfrequency" = "scale(frequency)",
# #                                 "Main effect:Mowing" = "scale(mowing)",
# #                                 "Main effect:Grazing" = "scale(grazing)",
# #                                 "Main effect:Soil\ndisturbance" = "scale(soil)",
# #                                 "Temperature:Disturbance\nseverity" = "scale(temperature):scale(severity)",
# #                                 "Temperature:Disturbance\nfrequency" = "scale(temperature):scale(frequency)",
# #                                 "Temperature:Mowing" = "scale(temperature):scale(mowing)",
# #                                 "Temperature:Grazing" = "scale(temperature):scale(grazing)",
# #                                 "Temperature:Soil\ndisturbance" = "scale(temperature):scale(soil)",
# #                                 "Alternating temperature:Disturbance\nseverity" = "scale(alternating):scale(severity)",
# #                                 "Alternating temperature:Disturbance\nfrequency" = "scale(alternating):scale(frequency)",
# #                                 "Alternating temperature:Mowing" = "scale(alternating):scale(mowing)",
# #                                 "Alternating temperature:Grazing" = "scale(alternating):scale(grazing)",
# #                                 "Alternating temperature:Soil\ndisturbance" = "scale(alternating):scale(soil)",
# #                                 "Light:Disturbance\nseverity" = "scale(light):scale(severity)",
# #                                 "Light:Disturbance\nfrequency" = "scale(light):scale(frequency)",
# #                                 "Light:Mowing" = "scale(light):scale(mowing)",
# #                                 "Light:Grazing" = "scale(light):scale(grazing)",
# #                                 "Light:Soil\ndisturbance" = "scale(light):scale(soil)",
# #                                 "Cold stratification:Disturbance\nseverity" = "scale(cs):scale(severity)",
# #                                 "Cold stratification:Disturbance\nfrequency" = "scale(cs):scale(frequency)",
# #                                 "Cold stratification:Mowing" = "scale(cs):scale(mowing)",
# #                                 "Cold stratification:Grazing" = "scale(cs):scale(grazing)",
# #                                 "Cold stratification:Soil\ndisturbance" = "scale(cs):scale(soil)",
# #                                 "Warm stratification:Disturbance\nseverity" = "scale(ws):scale(severity)",
# #                                 "Warm stratification:Disturbance\nfrequency" = "scale(ws):scale(frequency)",
# #                                 "Warm stratification:Mowing" = "scale(ws):scale(mowing)",
# #                                 "Warm stratification:Grazing" = "scale(ws):scale(grazing)",
# #                                 "Warm stratification:Soil\ndisturbance" = "scale(ws):scale(soil)",
# #                                 "Scarification:Disturbance\nseverity" = "scale(scarified):scale(severity)",
# #                                 "Scarification:Disturbance\nfrequency" = "scale(scarified):scale(frequency)",
# #                                 "Scarification:Mowing" = "scale(scarified):scale(mowing)",
# #                                 "Scarification:Grazing" = "scale(scarified):scale(grazing)",
# #                                 "Scarification:Soil\ndisturbance" = "scale(scarified):scale(soil)")) %>%
# #   separate(Parameter, into = c("Effect", "Group"), sep = ":") %>%
# #   mutate(Effect = fct_relevel(Effect, c("Light", 
# #                                         "Alternating temperature", 
# #                                         "Temperature", 
# #                                         "Warm stratification", 
# #                                         "Cold stratification", 
# #                                         "Scarification")),
# #          Group = fct_relevel(Group, c("Germination cue\n(Main effects)", 
# #                                       "Disturbance\nfrequency", 
# #                                       "Disturbance\nseverity", 
# #                                       "Soil\ndisturbance",
# #                                       "Mowing",
# #                                       "Grazing"))) %>%
# #   filter(! Group == "Intercept") %>%
# # filter(pMCMC <= 0.01) %>%
# #   ggplot(aes(y = Effect, x = post.mean, 
# #              xmin = l.95..CI, xmax = u.95..CI,
# #              color = Effect)) +
# #   facet_wrap(~ Group, scales = "free_x", nrow = 1) +
# #   geom_point(size = 2) +
# #   labs(x = "Effect size") +
# #   geom_errorbarh(height = .3) +
# #   geom_vline(xintercept = 0, linetype = "dashed") +
# #   scale_color_manual(values = c("#FFA500",  
# #                                 "gold", 
# #                                 "#B3EE3A", 
# #                                 "#40E0D0",
# #                                 "#5CACEE", 
# #                                 "#27408B", 
# #                                 "#A020F0",
# #                                 "#551A8B")) +
# #   ggthemes::theme_tufte() +
# #   theme(text = element_text(family = "sans", size = 12),
# #         strip.background = element_blank(),
# #         legend.position = "none", 
# #         panel.background = element_rect(color = "black", fill = NULL),
# #         axis.title.x = element_text(size = 14), 
# #         axis.title.y = element_blank(),
# #         axis.text.x = element_text(size = 7.5, color = "black"),
# #         axis.text.y = element_text(size = 14,
# #                                    color = c("#FFA500",  
# #                                              "gold", 
# #                                              "#B3EE3A", 
# #                                              "#40E0D0",
# #                                              "#5CACEE", 
# #                                              "#27408B", 
# #                                              "#A020F0",
# #                                              "#551A8B")),
# #         strip.text.x = element_text(size = 14)) -> 
# #   fig; fig
# # 
# # ## Export
# # 
# # ggsave(fig, file = "results/figures/FigHR.png", bg = "white", 
# #        path = NULL, scale = 1, width = 173, height = 173, units = "mm", dpi = 600)
# # 
# # # Calculate lambda http://www.mpcm-evolution.com/practice/online-practical-material-chapter-11/chapter-11-1-simple-model-mcmcglmm
# # 
# # lambda <- m1$VCV[,"animal"]/(m1$VCV[,"animal"] + m1$VCV[,"units"])
# # 
# # mean(lambda) %>% round(2) 
# # coda::HPDinterval(lambda)[, 1] %>% round(2) 
# # coda::HPDinterval(lambda)[, 2] %>% round(2) 
# # 
# # # Random effects
# # 
# # summary(m1)$Gcovariances
# # 
# # 
# # 
# # 
# # ### Shrubland
# # 
# # library(tidyverse); library(phangorn)
# # 
# # rm(list = ls())
# # 
# # merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1"), 
# #       read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1"), 
# #       by = "species") %>%
# #   mutate(animal = gsub(" ", "_", species)) %>%
# #   filter(S == 1) %>%
# #   select(-family) -> germination
# # 
# # germination %>%
# #   group_by(species)
# # 
# # ### Read tree
# # 
# # phangorn::nnls.tree(cophenetic(ape::read.tree("results/phylo-tree/disturbance.tre")), 
# #                     ape::read.tree("results/phylo-tree/disturbance.tre"), method = "ultrametric") -> 
# #   nnls_orig
# # 
# # nnls_orig$node.label <- NULL
# # 
# # ### Set number of iterations
# # nite = 1000000
# # nbur = 100000
# # nthi = 10000
# # 
# # # Less iterations
# # nite = 100000
# # nbur = 20000
# # nthi = 100
# # 
# # # # # Less iterations
# # # nite = 1000
# # # nbur = 500
# # # nthi = 50
# # # 
# # # # # Less iterations
# # # nite = 100
# # # nbur = 50
# # # nthi = 5
# # 
# # ### Set priors for germination models (as many prior as random factors)
# # 
# # priors <- list(R = list(V = 1, nu = 50), 
# #                G = list(G1 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500), 
# #                         G2 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G3 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G4 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G5 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G6 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G7 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500)))   
# # 
# # ### Model 1: main effects
# # 
# # MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
# #                      scale(temperature) +
# #                      scale(alternating) +
# #                      scale(light) +
# #                      scale(cs) +
# #                      scale(scarified) +
# #                      scale(temperature) * scale(severity) +
# #                      scale(temperature) * scale(frequency) +
# #                      scale(alternating) * scale(severity) +
# #                      scale(alternating) * scale(frequency) +
# #                      scale(light) * scale(severity) +
# #                      scale(light) * scale(frequency) +
# #                      scale(cs) * scale(severity) +
# #                      scale(cs) * scale(frequency) +
# #                      scale(scarified) * scale(severity) +
# #                      scale(scarified) * scale(frequency),
# #                    random = ~ animal + 
# #                      species + 
# #                      datasourceGUID +
# #                      country + 
# #                      seedlotGUID +
# #                      stored +
# #                      substrate,
# #                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
# #                    nitt = nite, thin = nthi, burnin = nbur,
# #                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# # 
# # summary(m1)
# # save(m1, file = "results/models/simplified/shrubland.Rdata")
# # 
# # summary(m1)$solutions %>%
# #   data.frame %>%
# #   rownames_to_column(var = "Parameter") %>%
# #   mutate(Parameter = fct_recode(Parameter, 
# #                                 "Intercept:Intercept" = "(Intercept)",
# #                                 "Temperature:Germination cue\n(Main effects)" = "scale(temperature)",
# #                                 "Alternating temperature:Germination cue\n(Main effects)" = "scale(alternating)",
# #                                 "Light:Germination cue\n(Main effects)" = "scale(light)",
# #                                 "Cold stratification:Germination cue\n(Main effects)" = "scale(cs)",
# #                                 "Warm stratification:Germination cue\n(Main effects)" = "scale(ws)",
# #                                 "Scarification:Germination cue\n(Main effects)" = "scale(scarified)",
# #                                 "Main effect:Disturbance\nseverity" = "scale(severity)",
# #                                 "Main effect:Disturbance\nfrequency" = "scale(frequency)",
# #                                 "Main effect:Mowing" = "scale(mowing)",
# #                                 "Main effect:Grazing" = "scale(grazing)",
# #                                 "Main effect:Soil\ndisturbance" = "scale(soil)",
# #                                 "Temperature:Disturbance\nseverity" = "scale(temperature):scale(severity)",
# #                                 "Temperature:Disturbance\nfrequency" = "scale(temperature):scale(frequency)",
# #                                 "Temperature:Mowing" = "scale(temperature):scale(mowing)",
# #                                 "Temperature:Grazing" = "scale(temperature):scale(grazing)",
# #                                 "Temperature:Soil\ndisturbance" = "scale(temperature):scale(soil)",
# #                                 "Alternating temperature:Disturbance\nseverity" = "scale(alternating):scale(severity)",
# #                                 "Alternating temperature:Disturbance\nfrequency" = "scale(alternating):scale(frequency)",
# #                                 "Alternating temperature:Mowing" = "scale(alternating):scale(mowing)",
# #                                 "Alternating temperature:Grazing" = "scale(alternating):scale(grazing)",
# #                                 "Alternating temperature:Soil\ndisturbance" = "scale(alternating):scale(soil)",
# #                                 "Light:Disturbance\nseverity" = "scale(light):scale(severity)",
# #                                 "Light:Disturbance\nfrequency" = "scale(light):scale(frequency)",
# #                                 "Light:Mowing" = "scale(light):scale(mowing)",
# #                                 "Light:Grazing" = "scale(light):scale(grazing)",
# #                                 "Light:Soil\ndisturbance" = "scale(light):scale(soil)",
# #                                 "Cold stratification:Disturbance\nseverity" = "scale(cs):scale(severity)",
# #                                 "Cold stratification:Disturbance\nfrequency" = "scale(cs):scale(frequency)",
# #                                 "Cold stratification:Mowing" = "scale(cs):scale(mowing)",
# #                                 "Cold stratification:Grazing" = "scale(cs):scale(grazing)",
# #                                 "Cold stratification:Soil\ndisturbance" = "scale(cs):scale(soil)",
# #                                 "Warm stratification:Disturbance\nseverity" = "scale(ws):scale(severity)",
# #                                 "Warm stratification:Disturbance\nfrequency" = "scale(ws):scale(frequency)",
# #                                 "Warm stratification:Mowing" = "scale(ws):scale(mowing)",
# #                                 "Warm stratification:Grazing" = "scale(ws):scale(grazing)",
# #                                 "Warm stratification:Soil\ndisturbance" = "scale(ws):scale(soil)",
# #                                 "Scarification:Disturbance\nseverity" = "scale(scarified):scale(severity)",
# #                                 "Scarification:Disturbance\nfrequency" = "scale(scarified):scale(frequency)",
# #                                 "Scarification:Mowing" = "scale(scarified):scale(mowing)",
# #                                 "Scarification:Grazing" = "scale(scarified):scale(grazing)",
# #                                 "Scarification:Soil\ndisturbance" = "scale(scarified):scale(soil)")) %>%
# #   separate(Parameter, into = c("Effect", "Group"), sep = ":") %>%
# #   mutate(Effect = fct_relevel(Effect, c("Light", 
# #                                         "Alternating temperature", 
# #                                         "Temperature", 
# #                                         "Warm stratification", 
# #                                         "Cold stratification", 
# #                                         "Scarification")),
# #          Group = fct_relevel(Group, c("Germination cue\n(Main effects)", 
# #                                       "Disturbance\nfrequency", 
# #                                       "Disturbance\nseverity", 
# #                                       "Soil\ndisturbance",
# #                                       "Mowing",
# #                                       "Grazing"))) %>%
# #   filter(! Group == "Intercept") %>%
# # filter(pMCMC <= 0.01) %>%
# #   ggplot(aes(y = Effect, x = post.mean, 
# #              xmin = l.95..CI, xmax = u.95..CI,
# #              color = Effect)) +
# #   facet_wrap(~ Group, scales = "free_x", nrow = 1) +
# #   geom_point(size = 2) +
# #   labs(x = "Effect size") +
# #   geom_errorbarh(height = .3) +
# #   geom_vline(xintercept = 0, linetype = "dashed") +
# #   scale_color_manual(values = c("#FFA500",  
# #                                 "gold", 
# #                                 "#B3EE3A", 
# #                                 "#40E0D0",
# #                                 "#5CACEE", 
# #                                 "#27408B", 
# #                                 "#A020F0",
# #                                 "#551A8B")) +
# #   ggthemes::theme_tufte() +
# #   theme(text = element_text(family = "sans", size = 12),
# #         strip.background = element_blank(),
# #         legend.position = "none", 
# #         panel.background = element_rect(color = "black", fill = NULL),
# #         axis.title.x = element_text(size = 14), 
# #         axis.title.y = element_blank(),
# #         axis.text.x = element_text(size = 7.5, color = "black"),
# #         axis.text.y = element_text(size = 14,
# #                                    color = c("#FFA500",  
# #                                              "gold", 
# #                                              "#B3EE3A", 
# #                                              "#40E0D0",
# #                                              "#5CACEE", 
# #                                              "#27408B", 
# #                                              "#A020F0",
# #                                              "#551A8B")),
# #         strip.text.x = element_text(size = 14)) -> 
# #   fig; fig
# # 
# # ## Export
# # 
# # ggsave(fig, file = "results/figures/FigHS.png", bg = "white", 
# #        path = NULL, scale = 1, width = 173, height = 173, units = "mm", dpi = 600)
# # 
# # # Calculate lambda http://www.mpcm-evolution.com/practice/online-practical-material-chapter-11/chapter-11-1-simple-model-mcmcglmm
# # 
# # lambda <- m1$VCV[,"animal"]/(m1$VCV[,"animal"] + m1$VCV[,"units"])
# # 
# # mean(lambda) %>% round(2) 
# # coda::HPDinterval(lambda)[, 1] %>% round(2) 
# # coda::HPDinterval(lambda)[, 2] %>% round(2) 
# # 
# # # Random effects
# # 
# # summary(m1)$Gcovariances
# # 
# # 
# # 
# # 
# # ### forest
# # 
# # library(tidyverse); library(phangorn)
# # 
# # rm(list = ls())
# # 
# # merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1"), 
# #       read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1"), 
# #       by = "species") %>%
# #   mutate(animal = gsub(" ", "_", species)) %>%
# #   filter(T == 1) %>%
# #   select(-family) -> germination
# # 
# # germination %>%
# #   group_by(species)
# # 
# # ### Read tree
# # 
# # phangorn::nnls.tree(cophenetic(ape::read.tree("results/phylo-tree/disturbance.tre")), 
# #                     ape::read.tree("results/phylo-tree/disturbance.tre"), method = "ultrametric") -> 
# #   nnls_orig
# # 
# # nnls_orig$node.label <- NULL
# # 
# # ### Set number of iterations
# # nite = 1000000
# # nbur = 100000
# # nthi = 10000
# # 
# # # Less iterations
# # nite = 100000
# # nbur = 20000
# # nthi = 100
# # 
# # # # # Less iterations
# # # nite = 1000
# # # nbur = 500
# # # nthi = 50
# # # 
# # # # # Less iterations
# # # nite = 100
# # # nbur = 50
# # # nthi = 5
# # 
# # ### Set priors for germination models (as many prior as random factors)
# # 
# # priors <- list(R = list(V = 1, nu = 50), 
# #                G = list(G1 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500), 
# #                         G2 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G3 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G4 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G5 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G6 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G7 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500)))   
# # 
# # ### Model 1: main effects
# # 
# # MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
# #                      scale(temperature) +
# #                      scale(alternating) +
# #                      scale(light) +
# #                      scale(cs) +
# #                      scale(scarified) +
# #                      scale(temperature) * scale(severity) +
# #                      scale(temperature) * scale(frequency) +
# #                      scale(alternating) * scale(severity) +
# #                      scale(alternating) * scale(frequency) +
# #                      scale(light) * scale(severity) +
# #                      scale(light) * scale(frequency) +
# #                      scale(cs) * scale(severity) +
# #                      scale(cs) * scale(frequency) +
# #                      scale(scarified) * scale(severity) +
# #                      scale(scarified) * scale(frequency),
# #                    random = ~ animal + 
# #                      species + 
# #                      datasourceGUID +
# #                      country + 
# #                      seedlotGUID +
# #                      stored +
# #                      substrate,
# #                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
# #                    nitt = nite, thin = nthi, burnin = nbur,
# #                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# # 
# # summary(m1)
# # save(m1, file = "results/models/simplified/forest.Rdata")
# # 
# # summary(m1)$solutions %>%
# #   data.frame %>%
# #   rownames_to_column(var = "Parameter") %>%
# #   mutate(Parameter = fct_recode(Parameter, 
# #                                 "Intercept:Intercept" = "(Intercept)",
# #                                 "Temperature:Germination cue\n(Main effects)" = "scale(temperature)",
# #                                 "Alternating temperature:Germination cue\n(Main effects)" = "scale(alternating)",
# #                                 "Light:Germination cue\n(Main effects)" = "scale(light)",
# #                                 "Cold stratification:Germination cue\n(Main effects)" = "scale(cs)",
# #                                 "Warm stratification:Germination cue\n(Main effects)" = "scale(ws)",
# #                                 "Scarification:Germination cue\n(Main effects)" = "scale(scarified)",
# #                                 "Main effect:Disturbance\nseverity" = "scale(severity)",
# #                                 "Main effect:Disturbance\nfrequency" = "scale(frequency)",
# #                                 "Main effect:Mowing" = "scale(mowing)",
# #                                 "Main effect:Grazing" = "scale(grazing)",
# #                                 "Main effect:Soil\ndisturbance" = "scale(soil)",
# #                                 "Temperature:Disturbance\nseverity" = "scale(temperature):scale(severity)",
# #                                 "Temperature:Disturbance\nfrequency" = "scale(temperature):scale(frequency)",
# #                                 "Temperature:Mowing" = "scale(temperature):scale(mowing)",
# #                                 "Temperature:Grazing" = "scale(temperature):scale(grazing)",
# #                                 "Temperature:Soil\ndisturbance" = "scale(temperature):scale(soil)",
# #                                 "Alternating temperature:Disturbance\nseverity" = "scale(alternating):scale(severity)",
# #                                 "Alternating temperature:Disturbance\nfrequency" = "scale(alternating):scale(frequency)",
# #                                 "Alternating temperature:Mowing" = "scale(alternating):scale(mowing)",
# #                                 "Alternating temperature:Grazing" = "scale(alternating):scale(grazing)",
# #                                 "Alternating temperature:Soil\ndisturbance" = "scale(alternating):scale(soil)",
# #                                 "Light:Disturbance\nseverity" = "scale(light):scale(severity)",
# #                                 "Light:Disturbance\nfrequency" = "scale(light):scale(frequency)",
# #                                 "Light:Mowing" = "scale(light):scale(mowing)",
# #                                 "Light:Grazing" = "scale(light):scale(grazing)",
# #                                 "Light:Soil\ndisturbance" = "scale(light):scale(soil)",
# #                                 "Cold stratification:Disturbance\nseverity" = "scale(cs):scale(severity)",
# #                                 "Cold stratification:Disturbance\nfrequency" = "scale(cs):scale(frequency)",
# #                                 "Cold stratification:Mowing" = "scale(cs):scale(mowing)",
# #                                 "Cold stratification:Grazing" = "scale(cs):scale(grazing)",
# #                                 "Cold stratification:Soil\ndisturbance" = "scale(cs):scale(soil)",
# #                                 "Warm stratification:Disturbance\nseverity" = "scale(ws):scale(severity)",
# #                                 "Warm stratification:Disturbance\nfrequency" = "scale(ws):scale(frequency)",
# #                                 "Warm stratification:Mowing" = "scale(ws):scale(mowing)",
# #                                 "Warm stratification:Grazing" = "scale(ws):scale(grazing)",
# #                                 "Warm stratification:Soil\ndisturbance" = "scale(ws):scale(soil)",
# #                                 "Scarification:Disturbance\nseverity" = "scale(scarified):scale(severity)",
# #                                 "Scarification:Disturbance\nfrequency" = "scale(scarified):scale(frequency)",
# #                                 "Scarification:Mowing" = "scale(scarified):scale(mowing)",
# #                                 "Scarification:Grazing" = "scale(scarified):scale(grazing)",
# #                                 "Scarification:Soil\ndisturbance" = "scale(scarified):scale(soil)")) %>%
# #   separate(Parameter, into = c("Effect", "Group"), sep = ":") %>%
# #   mutate(Effect = fct_relevel(Effect, c("Light", 
# #                                         "Alternating temperature", 
# #                                         "Temperature", 
# #                                         "Warm stratification", 
# #                                         "Cold stratification", 
# #                                         "Scarification")),
# #          Group = fct_relevel(Group, c("Germination cue\n(Main effects)", 
# #                                       "Disturbance\nfrequency", 
# #                                       "Disturbance\nseverity", 
# #                                       "Soil\ndisturbance",
# #                                       "Mowing",
# #                                       "Grazing"))) %>%
# #   filter(! Group == "Intercept") %>%
# # filter(pMCMC <= 0.01) %>%
# #   ggplot(aes(y = Effect, x = post.mean, 
# #              xmin = l.95..CI, xmax = u.95..CI,
# #              color = Effect)) +
# #   facet_wrap(~ Group, scales = "free_x", nrow = 1) +
# #   geom_point(size = 2) +
# #   labs(x = "Effect size") +
# #   geom_errorbarh(height = .3) +
# #   geom_vline(xintercept = 0, linetype = "dashed") +
# #   scale_color_manual(values = c("#FFA500",  
# #                                 "gold", 
# #                                 "#B3EE3A", 
# #                                 "#40E0D0",
# #                                 "#5CACEE", 
# #                                 "#27408B", 
# #                                 "#A020F0",
# #                                 "#551A8B")) +
# #   ggthemes::theme_tufte() +
# #   theme(text = element_text(family = "sans", size = 12),
# #         strip.background = element_blank(),
# #         legend.position = "none", 
# #         panel.background = element_rect(color = "black", fill = NULL),
# #         axis.title.x = element_text(size = 14), 
# #         axis.title.y = element_blank(),
# #         axis.text.x = element_text(size = 7.5, color = "black"),
# #         axis.text.y = element_text(size = 14,
# #                                    color = c("#FFA500",  
# #                                              "gold", 
# #                                              "#B3EE3A", 
# #                                              "#40E0D0",
# #                                              "#5CACEE", 
# #                                              "#27408B", 
# #                                              "#A020F0",
# #                                              "#551A8B")),
# #         strip.text.x = element_text(size = 14)) -> 
# #   fig; fig
# # 
# # ## Export
# # 
# # ggsave(fig, file = "results/figures/FigHT.png", bg = "white", 
# #        path = NULL, scale = 1, width = 173, height = 173, units = "mm", dpi = 600)
# # 
# # # Calculate lambda http://www.mpcm-evolution.com/practice/online-practical-material-chapter-11/chapter-11-1-simple-model-mcmcglmm
# # 
# # lambda <- m1$VCV[,"animal"]/(m1$VCV[,"animal"] + m1$VCV[,"units"])
# # 
# # mean(lambda) %>% round(2) 
# # coda::HPDinterval(lambda)[, 1] %>% round(2) 
# # coda::HPDinterval(lambda)[, 2] %>% round(2) 
# # 
# # # Random effects
# # 
# # summary(m1)$Gcovariances
# # 
# # 
# # 
# # ### anthro
# # 
# # library(tidyverse); library(phangorn)
# # 
# # rm(list = ls())
# # 
# # merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1"), 
# #       read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1"), 
# #       by = "species") %>%
# #   mutate(animal = gsub(" ", "_", species)) %>%
# #   filter(V == 1) %>%
# #   select(-family) -> germination
# # 
# # germination %>%
# #   group_by(species)
# # 
# # ### Read tree
# # 
# # phangorn::nnls.tree(cophenetic(ape::read.tree("results/phylo-tree/disturbance.tre")), 
# #                     ape::read.tree("results/phylo-tree/disturbance.tre"), method = "ultrametric") -> 
# #   nnls_orig
# # 
# # nnls_orig$node.label <- NULL
# # 
# # ### Set number of iterations
# # nite = 1000000
# # nbur = 100000
# # nthi = 10000
# # 
# # # Less iterations
# # nite = 100000
# # nbur = 20000
# # nthi = 100
# # 
# # # # # Less iterations
# # # nite = 1000
# # # nbur = 500
# # # nthi = 50
# # # # 
# # # # # Less iterations
# # # nite = 100
# # # nbur = 50
# # # nthi = 5
# # 
# # ### Set priors for germination models (as many prior as random factors)
# # 
# # priors <- list(R = list(V = 1, nu = 50), 
# #                G = list(G1 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500), 
# #                         G2 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G3 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G4 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G5 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G6 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G7 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500)))   
# # 
# # ### Model 1: main effects
# # 
# # MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
# #                      scale(temperature) +
# #                      scale(alternating) +
# #                      scale(light) +
# #                      scale(cs) +
# #                      scale(scarified) +
# #                      scale(temperature) * scale(severity) +
# #                      scale(temperature) * scale(frequency) +
# #                      scale(alternating) * scale(severity) +
# #                      scale(alternating) * scale(frequency) +
# #                      scale(light) * scale(severity) +
# #                      scale(light) * scale(frequency) +
# #                      scale(cs) * scale(severity) +
# #                      scale(cs) * scale(frequency) +
# #                      scale(scarified) * scale(severity) +
# #                      scale(scarified) * scale(frequency),
# #                    random = ~ animal + 
# #                      species + 
# #                      datasourceGUID +
# #                      country + 
# #                      seedlotGUID +
# #                      stored +
# #                      substrate,
# #                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
# #                    nitt = nite, thin = nthi, burnin = nbur,
# #                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# # 
# # summary(m1)
# # save(m1, file = "results/models/simplified/anthro.Rdata")
# # 
# # summary(m1)$solutions %>%
# #   data.frame %>%
# #   rownames_to_column(var = "Parameter") %>%
# #   mutate(Parameter = fct_recode(Parameter, 
# #                                 "Intercept:Intercept" = "(Intercept)",
# #                                 "Temperature:Germination cue\n(Main effects)" = "scale(temperature)",
# #                                 "Alternating temperature:Germination cue\n(Main effects)" = "scale(alternating)",
# #                                 "Light:Germination cue\n(Main effects)" = "scale(light)",
# #                                 "Cold stratification:Germination cue\n(Main effects)" = "scale(cs)",
# #                                 "Warm stratification:Germination cue\n(Main effects)" = "scale(ws)",
# #                                 "Scarification:Germination cue\n(Main effects)" = "scale(scarified)",
# #                                 "Main effect:Disturbance\nseverity" = "scale(severity)",
# #                                 "Main effect:Disturbance\nfrequency" = "scale(frequency)",
# #                                 "Main effect:Mowing" = "scale(mowing)",
# #                                 "Main effect:Grazing" = "scale(grazing)",
# #                                 "Main effect:Soil\ndisturbance" = "scale(soil)",
# #                                 "Temperature:Disturbance\nseverity" = "scale(temperature):scale(severity)",
# #                                 "Temperature:Disturbance\nfrequency" = "scale(temperature):scale(frequency)",
# #                                 "Temperature:Mowing" = "scale(temperature):scale(mowing)",
# #                                 "Temperature:Grazing" = "scale(temperature):scale(grazing)",
# #                                 "Temperature:Soil\ndisturbance" = "scale(temperature):scale(soil)",
# #                                 "Alternating temperature:Disturbance\nseverity" = "scale(alternating):scale(severity)",
# #                                 "Alternating temperature:Disturbance\nfrequency" = "scale(alternating):scale(frequency)",
# #                                 "Alternating temperature:Mowing" = "scale(alternating):scale(mowing)",
# #                                 "Alternating temperature:Grazing" = "scale(alternating):scale(grazing)",
# #                                 "Alternating temperature:Soil\ndisturbance" = "scale(alternating):scale(soil)",
# #                                 "Light:Disturbance\nseverity" = "scale(light):scale(severity)",
# #                                 "Light:Disturbance\nfrequency" = "scale(light):scale(frequency)",
# #                                 "Light:Mowing" = "scale(light):scale(mowing)",
# #                                 "Light:Grazing" = "scale(light):scale(grazing)",
# #                                 "Light:Soil\ndisturbance" = "scale(light):scale(soil)",
# #                                 "Cold stratification:Disturbance\nseverity" = "scale(cs):scale(severity)",
# #                                 "Cold stratification:Disturbance\nfrequency" = "scale(cs):scale(frequency)",
# #                                 "Cold stratification:Mowing" = "scale(cs):scale(mowing)",
# #                                 "Cold stratification:Grazing" = "scale(cs):scale(grazing)",
# #                                 "Cold stratification:Soil\ndisturbance" = "scale(cs):scale(soil)",
# #                                 "Warm stratification:Disturbance\nseverity" = "scale(ws):scale(severity)",
# #                                 "Warm stratification:Disturbance\nfrequency" = "scale(ws):scale(frequency)",
# #                                 "Warm stratification:Mowing" = "scale(ws):scale(mowing)",
# #                                 "Warm stratification:Grazing" = "scale(ws):scale(grazing)",
# #                                 "Warm stratification:Soil\ndisturbance" = "scale(ws):scale(soil)",
# #                                 "Scarification:Disturbance\nseverity" = "scale(scarified):scale(severity)",
# #                                 "Scarification:Disturbance\nfrequency" = "scale(scarified):scale(frequency)",
# #                                 "Scarification:Mowing" = "scale(scarified):scale(mowing)",
# #                                 "Scarification:Grazing" = "scale(scarified):scale(grazing)",
# #                                 "Scarification:Soil\ndisturbance" = "scale(scarified):scale(soil)")) %>%
# #   separate(Parameter, into = c("Effect", "Group"), sep = ":") %>%
# #   mutate(Effect = fct_relevel(Effect, c("Light", 
# #                                         "Alternating temperature", 
# #                                         "Temperature", 
# #                                         "Warm stratification", 
# #                                         "Cold stratification", 
# #                                         "Scarification")),
# #          Group = fct_relevel(Group, c("Germination cue\n(Main effects)", 
# #                                       "Disturbance\nfrequency", 
# #                                       "Disturbance\nseverity", 
# #                                       "Soil\ndisturbance",
# #                                       "Mowing",
# #                                       "Grazing"))) %>%
# #   filter(! Group == "Intercept") %>%
# # filter(pMCMC <= 0.01) %>%
# #   ggplot(aes(y = Effect, x = post.mean, 
# #              xmin = l.95..CI, xmax = u.95..CI,
# #              color = Effect)) +
# #   facet_wrap(~ Group, scales = "free_x", nrow = 1) +
# #   geom_point(size = 2) +
# #   labs(x = "Effect size") +
# #   geom_errorbarh(height = .3) +
# #   geom_vline(xintercept = 0, linetype = "dashed") +
# #   scale_color_manual(values = c("#FFA500",  
# #                                 "gold", 
# #                                 "#B3EE3A", 
# #                                 "#40E0D0",
# #                                 "#5CACEE", 
# #                                 "#27408B", 
# #                                 "#A020F0",
# #                                 "#551A8B")) +
# #   ggthemes::theme_tufte() +
# #   theme(text = element_text(family = "sans", size = 12),
# #         strip.background = element_blank(),
# #         legend.position = "none", 
# #         panel.background = element_rect(color = "black", fill = NULL),
# #         axis.title.x = element_text(size = 14), 
# #         axis.title.y = element_blank(),
# #         axis.text.x = element_text(size = 7.5, color = "black"),
# #         axis.text.y = element_text(size = 14,
# #                                    color = c("#FFA500",  
# #                                              "gold", 
# #                                              "#B3EE3A", 
# #                                              "#40E0D0",
# #                                              "#5CACEE", 
# #                                              "#27408B", 
# #                                              "#A020F0",
# #                                              "#551A8B")),
# #         strip.text.x = element_text(size = 14)) -> 
# #   fig; fig
# # 
# # ## Export
# # 
# # ggsave(fig, file = "results/figures/FigHV.png", bg = "white", 
# #        path = NULL, scale = 1, width = 173, height = 173, units = "mm", dpi = 600)
# # 
# # # Calculate lambda http://www.mpcm-evolution.com/practice/online-practical-material-chapter-11/chapter-11-1-simple-model-mcmcglmm
# # 
# # lambda <- m1$VCV[,"animal"]/(m1$VCV[,"animal"] + m1$VCV[,"units"])
# # 
# # mean(lambda) %>% round(2) 
# # coda::HPDinterval(lambda)[, 1] %>% round(2) 
# # coda::HPDinterval(lambda)[, 2] %>% round(2) 
# # 
# # # Random effects
# # 
# # summary(m1)$Gcovariances
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# ### Simplified models all spp
# 
# library(tidyverse); library(phangorn)
# 
# rm(list = ls())
# 
# read.csv("results/phylo-tree/output_splist.csv", fileEncoding = "latin1") %>%
#   filter(output.note == "present in megatree") %>% pull(species) -> treespp
# 
# merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1"), 
#       read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1"), 
#       by = "species") %>%
#   mutate(animal = gsub(" ", "_", species)) %>%
#   # filter(species %in% treespp) %>%
#   # filter(! family %in% c("Pinaceae", "Cupressaceae", "Taxaceae", "Taxodiaceae")) %>%
#   select(-family) -> germination
# 
# ### Read tree
# 
# phangorn::nnls.tree(cophenetic(ape::read.tree("results/phylo-tree/disturbance.tre")), 
#                     ape::read.tree("results/phylo-tree/disturbance.tre"), method = "ultrametric") -> 
#   nnls_orig
# 
# nnls_orig$node.label <- NULL
# 
# ### Set number of iterations
# nite = 1000000
# nbur = 200000
# nthi = 1000
# 
# # # Less iterations
# # nite = 100000
# # nbur = 20000
# # nthi = 100
# 
# # # # Less iterations
# # nite = 1000
# # nbur = 500
# # nthi = 50
# # 
# # # # Less iterations
# # nite = 100
# # nbur = 50
# # nthi = 5
# 
# 
# ### Set priors for germination models (as many prior as random factors)
# 
# priors <- list(R = list(V = 1, nu = 50), 
#                G = list(G1 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500), 
#                         G2 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
#                         G3 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
#                         G4 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
#                         G5 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
#                         G6 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
#                         G7 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500)))   
# 
# ### Model 1: main effects
# 
# MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
#                      scale(temperature) +
#                      scale(alternating) +
#                      scale(light) +
#                      scale(cs) +
#                      scale(scarified) +
#                      scale(temperature) * scale(severity) +
#                      scale(temperature) * scale(frequency) +
#                      scale(alternating) * scale(severity) +
#                      scale(alternating) * scale(frequency) +
#                      scale(light) * scale(severity) +
#                      scale(light) * scale(frequency) +
#                      scale(cs) * scale(severity) +
#                      scale(cs) * scale(frequency) +
#                      scale(scarified) * scale(severity) +
#                      scale(scarified) * scale(frequency),
#                    random = ~ animal + 
#                      species + 
#                      datasourceGUID +
#                      country + 
#                      seedlotGUID +
#                      stored +
#                      substrate,
#                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
#                    nitt = nite, thin = nthi, burnin = nbur,
#                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# 
# summary(m1)
# save(m1, file = "results/models/simplified/1M/all-spp.Rdata")
# 
# summary(m1)$solutions %>%
#   data.frame %>%
#   rownames_to_column(var = "Parameter") %>%
#   mutate(Parameter = fct_recode(Parameter, 
#                                 "Intercept:Intercept" = "(Intercept)",
#                                 "Temperature:Germination cue\n(Main effects)" = "scale(temperature)",
#                                 "Alternating temperature:Germination cue\n(Main effects)" = "scale(alternating)",
#                                 "Light:Germination cue\n(Main effects)" = "scale(light)",
#                                 "Cold stratification:Germination cue\n(Main effects)" = "scale(cs)",
#                                 "Warm stratification:Germination cue\n(Main effects)" = "scale(ws)",
#                                 "Scarification:Germination cue\n(Main effects)" = "scale(scarified)",
#                                 "Main effect:Disturbance\nseverity" = "scale(severity)",
#                                 "Main effect:Disturbance\nfrequency" = "scale(frequency)",
#                                 "Main effect:Mowing" = "scale(mowing)",
#                                 "Main effect:Grazing" = "scale(grazing)",
#                                 "Main effect:Soil\ndisturbance" = "scale(soil)",
#                                 "Temperature:Disturbance\nseverity" = "scale(temperature):scale(severity)",
#                                 "Temperature:Disturbance\nfrequency" = "scale(temperature):scale(frequency)",
#                                 "Temperature:Mowing" = "scale(temperature):scale(mowing)",
#                                 "Temperature:Grazing" = "scale(temperature):scale(grazing)",
#                                 "Temperature:Soil\ndisturbance" = "scale(temperature):scale(soil)",
#                                 "Alternating temperature:Disturbance\nseverity" = "scale(alternating):scale(severity)",
#                                 "Alternating temperature:Disturbance\nfrequency" = "scale(alternating):scale(frequency)",
#                                 "Alternating temperature:Mowing" = "scale(alternating):scale(mowing)",
#                                 "Alternating temperature:Grazing" = "scale(alternating):scale(grazing)",
#                                 "Alternating temperature:Soil\ndisturbance" = "scale(alternating):scale(soil)",
#                                 "Light:Disturbance\nseverity" = "scale(light):scale(severity)",
#                                 "Light:Disturbance\nfrequency" = "scale(light):scale(frequency)",
#                                 "Light:Mowing" = "scale(light):scale(mowing)",
#                                 "Light:Grazing" = "scale(light):scale(grazing)",
#                                 "Light:Soil\ndisturbance" = "scale(light):scale(soil)",
#                                 "Cold stratification:Disturbance\nseverity" = "scale(cs):scale(severity)",
#                                 "Cold stratification:Disturbance\nfrequency" = "scale(cs):scale(frequency)",
#                                 "Cold stratification:Mowing" = "scale(cs):scale(mowing)",
#                                 "Cold stratification:Grazing" = "scale(cs):scale(grazing)",
#                                 "Cold stratification:Soil\ndisturbance" = "scale(cs):scale(soil)",
#                                 "Warm stratification:Disturbance\nseverity" = "scale(ws):scale(severity)",
#                                 "Warm stratification:Disturbance\nfrequency" = "scale(ws):scale(frequency)",
#                                 "Warm stratification:Mowing" = "scale(ws):scale(mowing)",
#                                 "Warm stratification:Grazing" = "scale(ws):scale(grazing)",
#                                 "Warm stratification:Soil\ndisturbance" = "scale(ws):scale(soil)",
#                                 "Scarification:Disturbance\nseverity" = "scale(scarified):scale(severity)",
#                                 "Scarification:Disturbance\nfrequency" = "scale(scarified):scale(frequency)",
#                                 "Scarification:Mowing" = "scale(scarified):scale(mowing)",
#                                 "Scarification:Grazing" = "scale(scarified):scale(grazing)",
#                                 "Scarification:Soil\ndisturbance" = "scale(scarified):scale(soil)")) %>%
#   separate(Parameter, into = c("Effect", "Group"), sep = ":") %>%
#   mutate(Effect = fct_relevel(Effect, c("Light", 
#                                         "Alternating temperature", 
#                                         "Temperature", 
#                                         "Warm stratification", 
#                                         "Cold stratification", 
#                                         "Scarification")),
#          Group = fct_relevel(Group, c("Germination cue\n(Main effects)", 
#                                       "Disturbance\nfrequency", 
#                                       "Disturbance\nseverity", 
#                                       "Soil\ndisturbance",
#                                       "Mowing",
#                                       "Grazing"))) %>%
#   filter(! Group == "Intercept") %>%
# filter(pMCMC <= 0.05) %>%
#   ggplot(aes(y = Effect, x = post.mean, 
#              xmin = l.95..CI, xmax = u.95..CI,
#              color = Effect)) +
#   facet_wrap(~ Group, scales = "free_x", nrow = 1) +
#   geom_point(size = 2) +
#   labs(x = "Effect size") +
#   geom_errorbarh(height = .3) +
#   geom_vline(xintercept = 0, linetype = "dashed") +
#   scale_color_manual(values = c("#FFA500",  
#                                 "gold", 
#                                 "#B3EE3A", 
#                                 "#40E0D0",
#                                 "#5CACEE", 
#                                 "#27408B", 
#                                 "#A020F0",
#                                 "#551A8B")) +
#   ggthemes::theme_tufte() +
#   theme(text = element_text(family = "sans", size = 12),
#         strip.background = element_blank(),
#         legend.position = "none", 
#         panel.background = element_rect(color = "black", fill = NULL),
#         axis.title.x = element_text(size = 14), 
#         axis.title.y = element_blank(),
#         axis.text.x = element_text(size = 7.5, color = "black"),
#         axis.text.y = element_text(size = 14,
#                                    color = c("#FFA500",  
#                                              "gold", 
#                                              "#B3EE3A", 
#                                              "#40E0D0",
#                                              "#5CACEE", 
#                                              "#27408B", 
#                                              "#A020F0",
#                                              "#551A8B")),
#         strip.text.x = element_text(size = 14)) -> 
#   fig; fig
# 
# ## Export
# 
# ggsave(fig, file = "results/figures/FigQ01M.png", bg = "white", 
#        path = NULL, scale = 1, width = 173, height = 173, units = "mm", dpi = 600)
# 
# # Calculate lambda http://www.mpcm-evolution.com/practice/online-practical-material-chapter-11/chapter-11-1-simple-model-mcmcglmm
# 
# lambda <- m1$VCV[,"animal"]/(m1$VCV[,"animal"] + m1$VCV[,"units"])
# 
# mean(lambda) %>% round(2) 
# coda::HPDinterval(lambda)[, 1] %>% round(2) 
# coda::HPDinterval(lambda)[, 2] %>% round(2) 
# 
# # Random effects
# 
# summary(m1)$Gcovariances
# 
# # ### Simplified models tree spp
# # 
# # library(tidyverse); library(phangorn)
# # 
# # rm(list = ls())
# # 
# # read.csv("results/phylo-tree/output_splist.csv", fileEncoding = "latin1") %>%
# #   filter(output.note == "present in megatree") %>% pull(species) -> treespp
# # 
# # merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1"), 
# #       read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1"), 
# #       by = "species") %>%
# #   mutate(animal = gsub(" ", "_", species)) %>%
# #   filter(species %in% treespp) %>%
# #   # filter(! family %in% c("Pinaceae", "Cupressaceae", "Taxaceae", "Taxodiaceae")) %>%
# #   select(-family) -> germination
# # 
# # germination %>%
# #   group_by(species)
# # 
# # ### Read tree
# # 
# # phangorn::nnls.tree(cophenetic(ape::read.tree("results/phylo-tree/disturbance.tre")), 
# #                     ape::read.tree("results/phylo-tree/disturbance.tre"), method = "ultrametric") -> 
# #   nnls_orig
# # 
# # nnls_orig$node.label <- NULL
# # 
# # ### Set number of iterations
# # nite = 1000000
# # nbur = 100000
# # nthi = 10000
# # 
# # # Less iterations
# # nite = 100000
# # nbur = 20000
# # nthi = 100
# # 
# # # # # Less iterations
# # # nite = 1000
# # # nbur = 500
# # # nthi = 50
# # # 
# # # # # Less iterations
# # # nite = 100
# # # nbur = 50
# # # nthi = 5
# # 
# # ### Set priors for germination models (as many prior as random factors)
# # 
# # priors <- list(R = list(V = 1, nu = 50), 
# #                G = list(G1 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500), 
# #                         G2 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G3 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G4 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G5 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G6 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
# #                         G7 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500)))   
# # 
# # ### Model 1: main effects
# # 
# # MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
# #                      scale(temperature) +
# #                      scale(alternating) +
# #                      scale(light) +
# #                      scale(cs) +
# #                      scale(scarified) +
# #                      scale(temperature) * scale(severity) +
# #                      scale(temperature) * scale(frequency) +
# #                      scale(alternating) * scale(severity) +
# #                      scale(alternating) * scale(frequency) +
# #                      scale(light) * scale(severity) +
# #                      scale(light) * scale(frequency) +
# #                      scale(cs) * scale(severity) +
# #                      scale(cs) * scale(frequency) +
# #                      scale(scarified) * scale(severity) +
# #                      scale(scarified) * scale(frequency),
# #                    random = ~ animal + 
# #                      species + 
# #                      datasourceGUID +
# #                      country + 
# #                      seedlotGUID +
# #                      stored +
# #                      substrate,
# #                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
# #                    nitt = nite, thin = nthi, burnin = nbur,
# #                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# # 
# # summary(m1)
# # save(m1, file = "results/models/simplified/tree-spp.Rdata")
# # 
# # summary(m1)$solutions %>%
# #   data.frame %>%
# #   rownames_to_column(var = "Parameter") %>%
# #   mutate(Parameter = fct_recode(Parameter, 
# #                                 "Intercept:Intercept" = "(Intercept)",
# #                                 "Temperature:Germination cue\n(Main effects)" = "scale(temperature)",
# #                                 "Alternating temperature:Germination cue\n(Main effects)" = "scale(alternating)",
# #                                 "Light:Germination cue\n(Main effects)" = "scale(light)",
# #                                 "Cold stratification:Germination cue\n(Main effects)" = "scale(cs)",
# #                                 "Warm stratification:Germination cue\n(Main effects)" = "scale(ws)",
# #                                 "Scarification:Germination cue\n(Main effects)" = "scale(scarified)",
# #                                 "Main effect:Disturbance\nseverity" = "scale(severity)",
# #                                 "Main effect:Disturbance\nfrequency" = "scale(frequency)",
# #                                 "Main effect:Mowing" = "scale(mowing)",
# #                                 "Main effect:Grazing" = "scale(grazing)",
# #                                 "Main effect:Soil\ndisturbance" = "scale(soil)",
# #                                 "Temperature:Disturbance\nseverity" = "scale(temperature):scale(severity)",
# #                                 "Temperature:Disturbance\nfrequency" = "scale(temperature):scale(frequency)",
# #                                 "Temperature:Mowing" = "scale(temperature):scale(mowing)",
# #                                 "Temperature:Grazing" = "scale(temperature):scale(grazing)",
# #                                 "Temperature:Soil\ndisturbance" = "scale(temperature):scale(soil)",
# #                                 "Alternating temperature:Disturbance\nseverity" = "scale(alternating):scale(severity)",
# #                                 "Alternating temperature:Disturbance\nfrequency" = "scale(alternating):scale(frequency)",
# #                                 "Alternating temperature:Mowing" = "scale(alternating):scale(mowing)",
# #                                 "Alternating temperature:Grazing" = "scale(alternating):scale(grazing)",
# #                                 "Alternating temperature:Soil\ndisturbance" = "scale(alternating):scale(soil)",
# #                                 "Light:Disturbance\nseverity" = "scale(light):scale(severity)",
# #                                 "Light:Disturbance\nfrequency" = "scale(light):scale(frequency)",
# #                                 "Light:Mowing" = "scale(light):scale(mowing)",
# #                                 "Light:Grazing" = "scale(light):scale(grazing)",
# #                                 "Light:Soil\ndisturbance" = "scale(light):scale(soil)",
# #                                 "Cold stratification:Disturbance\nseverity" = "scale(cs):scale(severity)",
# #                                 "Cold stratification:Disturbance\nfrequency" = "scale(cs):scale(frequency)",
# #                                 "Cold stratification:Mowing" = "scale(cs):scale(mowing)",
# #                                 "Cold stratification:Grazing" = "scale(cs):scale(grazing)",
# #                                 "Cold stratification:Soil\ndisturbance" = "scale(cs):scale(soil)",
# #                                 "Warm stratification:Disturbance\nseverity" = "scale(ws):scale(severity)",
# #                                 "Warm stratification:Disturbance\nfrequency" = "scale(ws):scale(frequency)",
# #                                 "Warm stratification:Mowing" = "scale(ws):scale(mowing)",
# #                                 "Warm stratification:Grazing" = "scale(ws):scale(grazing)",
# #                                 "Warm stratification:Soil\ndisturbance" = "scale(ws):scale(soil)",
# #                                 "Scarification:Disturbance\nseverity" = "scale(scarified):scale(severity)",
# #                                 "Scarification:Disturbance\nfrequency" = "scale(scarified):scale(frequency)",
# #                                 "Scarification:Mowing" = "scale(scarified):scale(mowing)",
# #                                 "Scarification:Grazing" = "scale(scarified):scale(grazing)",
# #                                 "Scarification:Soil\ndisturbance" = "scale(scarified):scale(soil)")) %>%
# #   separate(Parameter, into = c("Effect", "Group"), sep = ":") %>%
# #   mutate(Effect = fct_relevel(Effect, c("Light", 
# #                                         "Alternating temperature", 
# #                                         "Temperature", 
# #                                         "Warm stratification", 
# #                                         "Cold stratification", 
# #                                         "Scarification")),
# #          Group = fct_relevel(Group, c("Germination cue\n(Main effects)", 
# #                                       "Disturbance\nfrequency", 
# #                                       "Disturbance\nseverity", 
# #                                       "Soil\ndisturbance",
# #                                       "Mowing",
# #                                       "Grazing"))) %>%
# #   filter(! Group == "Intercept") %>%
# # filter(pMCMC <= 0.01) %>%
# #   ggplot(aes(y = Effect, x = post.mean, 
# #              xmin = l.95..CI, xmax = u.95..CI,
# #              color = Effect)) +
# #   facet_wrap(~ Group, scales = "free_x", nrow = 1) +
# #   geom_point(size = 2) +
# #   labs(x = "Effect size") +
# #   geom_errorbarh(height = .3) +
# #   geom_vline(xintercept = 0, linetype = "dashed") +
# #   scale_color_manual(values = c("#FFA500",  
# #                                 "gold", 
# #                                 "#B3EE3A", 
# #                                 "#40E0D0",
# #                                 "#5CACEE", 
# #                                 "#27408B", 
# #                                 "#A020F0",
# #                                 "#551A8B")) +
# #   ggthemes::theme_tufte() +
# #   theme(text = element_text(family = "sans", size = 12),
# #         strip.background = element_blank(),
# #         legend.position = "none", 
# #         panel.background = element_rect(color = "black", fill = NULL),
# #         axis.title.x = element_text(size = 14), 
# #         axis.title.y = element_blank(),
# #         axis.text.x = element_text(size = 7.5, color = "black"),
# #         axis.text.y = element_text(size = 14,
# #                                    color = c("#FFA500",  
# #                                              "gold", 
# #                                              "#B3EE3A", 
# #                                              "#40E0D0",
# #                                              "#5CACEE", 
# #                                              "#27408B", 
# #                                              "#A020F0",
# #                                              "#551A8B")),
# #         strip.text.x = element_text(size = 14)) -> 
# #   fig; fig
# # 
# # ## Export
# # 
# # ggsave(fig, file = "results/figures/FigQ1.png", bg = "white", 
# #        path = NULL, scale = 1, width = 173, height = 173, units = "mm", dpi = 600)
# # 
# # # Calculate lambda http://www.mpcm-evolution.com/practice/online-practical-material-chapter-11/chapter-11-1-simple-model-mcmcglmm
# # 
# # lambda <- m1$VCV[,"animal"]/(m1$VCV[,"animal"] + m1$VCV[,"units"])
# # 
# # mean(lambda) %>% round(2) 
# # coda::HPDinterval(lambda)[, 1] %>% round(2) 
# # coda::HPDinterval(lambda)[, 2] %>% round(2) 
# # 
# # # Random effects
# # 
# # summary(m1)$Gcovariances
# 
# ### Simplified models tree spp and no gymnosperms
# 
# library(tidyverse); library(phangorn)
# 
# rm(list = ls())
# 
# read.csv("results/phylo-tree/output_splist.csv", fileEncoding = "latin1") %>%
#   filter(output.note == "present in megatree") %>% pull(species) -> treespp
# 
# merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1"), 
#       read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1"), 
#       by = "species") %>%
#   mutate(animal = gsub(" ", "_", species)) %>%
#   filter(species %in% treespp) %>%
#   filter(! family %in% c("Pinaceae", "Cupressaceae", "Taxaceae", "Taxodiaceae")) %>%
#   select(-family) -> germination
# 
# ### Read tree
# 
# phangorn::nnls.tree(cophenetic(ape::read.tree("results/phylo-tree/disturbance.tre")), 
#                     ape::read.tree("results/phylo-tree/disturbance.tre"), method = "ultrametric") -> 
#   nnls_orig
# 
# nnls_orig$node.label <- NULL
# 
# ### Set number of iterations
# nite = 1000000
# nbur = 200000
# nthi = 1000
# 
# # # Less iterations
# # nite = 100000
# # nbur = 20000
# # nthi = 100
# 
# # # # Less iterations
# # nite = 1000
# # nbur = 500
# # nthi = 50
# # 
# # # # Less iterations
# # nite = 100
# # nbur = 50
# # nthi = 5
# 
# ### Set priors for germination models (as many prior as random factors)
# 
# priors <- list(R = list(V = 1, nu = 50), 
#                G = list(G1 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500), 
#                         G2 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
#                         G3 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
#                         G4 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
#                         G5 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
#                         G6 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
#                         G7 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500)))   
# 
# ### Model 1: main effects
# 
# MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
#                      scale(temperature) +
#                      scale(alternating) +
#                      scale(light) +
#                      scale(cs) +
#                      scale(scarified) +
#                      scale(temperature) * scale(severity) +
#                      scale(temperature) * scale(frequency) +
#                      scale(alternating) * scale(severity) +
#                      scale(alternating) * scale(frequency) +
#                      scale(light) * scale(severity) +
#                      scale(light) * scale(frequency) +
#                      scale(cs) * scale(severity) +
#                      scale(cs) * scale(frequency) +
#                      scale(scarified) * scale(severity) +
#                      scale(scarified) * scale(frequency),
#                    random = ~ animal + 
#                      species + 
#                      datasourceGUID +
#                      country + 
#                      seedlotGUID +
#                      stored +
#                      substrate,
#                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
#                    nitt = nite, thin = nthi, burnin = nbur,
#                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# 
# summary(m1)
# save(m1, file = "results/models/simplified/1M/tree-spp-no-gymno.Rdata")
# 
# summary(m1)$solutions %>%
#   data.frame %>%
#   rownames_to_column(var = "Parameter") %>%
#   mutate(Parameter = fct_recode(Parameter, 
#                                 "Intercept:Intercept" = "(Intercept)",
#                                 "Temperature:Germination cue\n(Main effects)" = "scale(temperature)",
#                                 "Alternating temperature:Germination cue\n(Main effects)" = "scale(alternating)",
#                                 "Light:Germination cue\n(Main effects)" = "scale(light)",
#                                 "Cold stratification:Germination cue\n(Main effects)" = "scale(cs)",
#                                 "Warm stratification:Germination cue\n(Main effects)" = "scale(ws)",
#                                 "Scarification:Germination cue\n(Main effects)" = "scale(scarified)",
#                                 "Main effect:Disturbance\nseverity" = "scale(severity)",
#                                 "Main effect:Disturbance\nfrequency" = "scale(frequency)",
#                                 "Main effect:Mowing" = "scale(mowing)",
#                                 "Main effect:Grazing" = "scale(grazing)",
#                                 "Main effect:Soil\ndisturbance" = "scale(soil)",
#                                 "Temperature:Disturbance\nseverity" = "scale(temperature):scale(severity)",
#                                 "Temperature:Disturbance\nfrequency" = "scale(temperature):scale(frequency)",
#                                 "Temperature:Mowing" = "scale(temperature):scale(mowing)",
#                                 "Temperature:Grazing" = "scale(temperature):scale(grazing)",
#                                 "Temperature:Soil\ndisturbance" = "scale(temperature):scale(soil)",
#                                 "Alternating temperature:Disturbance\nseverity" = "scale(alternating):scale(severity)",
#                                 "Alternating temperature:Disturbance\nfrequency" = "scale(alternating):scale(frequency)",
#                                 "Alternating temperature:Mowing" = "scale(alternating):scale(mowing)",
#                                 "Alternating temperature:Grazing" = "scale(alternating):scale(grazing)",
#                                 "Alternating temperature:Soil\ndisturbance" = "scale(alternating):scale(soil)",
#                                 "Light:Disturbance\nseverity" = "scale(light):scale(severity)",
#                                 "Light:Disturbance\nfrequency" = "scale(light):scale(frequency)",
#                                 "Light:Mowing" = "scale(light):scale(mowing)",
#                                 "Light:Grazing" = "scale(light):scale(grazing)",
#                                 "Light:Soil\ndisturbance" = "scale(light):scale(soil)",
#                                 "Cold stratification:Disturbance\nseverity" = "scale(cs):scale(severity)",
#                                 "Cold stratification:Disturbance\nfrequency" = "scale(cs):scale(frequency)",
#                                 "Cold stratification:Mowing" = "scale(cs):scale(mowing)",
#                                 "Cold stratification:Grazing" = "scale(cs):scale(grazing)",
#                                 "Cold stratification:Soil\ndisturbance" = "scale(cs):scale(soil)",
#                                 "Warm stratification:Disturbance\nseverity" = "scale(ws):scale(severity)",
#                                 "Warm stratification:Disturbance\nfrequency" = "scale(ws):scale(frequency)",
#                                 "Warm stratification:Mowing" = "scale(ws):scale(mowing)",
#                                 "Warm stratification:Grazing" = "scale(ws):scale(grazing)",
#                                 "Warm stratification:Soil\ndisturbance" = "scale(ws):scale(soil)",
#                                 "Scarification:Disturbance\nseverity" = "scale(scarified):scale(severity)",
#                                 "Scarification:Disturbance\nfrequency" = "scale(scarified):scale(frequency)",
#                                 "Scarification:Mowing" = "scale(scarified):scale(mowing)",
#                                 "Scarification:Grazing" = "scale(scarified):scale(grazing)",
#                                 "Scarification:Soil\ndisturbance" = "scale(scarified):scale(soil)")) %>%
#   separate(Parameter, into = c("Effect", "Group"), sep = ":") %>%
#   mutate(Effect = fct_relevel(Effect, c("Light", 
#                                         "Alternating temperature", 
#                                         "Temperature", 
#                                         "Warm stratification", 
#                                         "Cold stratification", 
#                                         "Scarification")),
#          Group = fct_relevel(Group, c("Germination cue\n(Main effects)", 
#                                       "Disturbance\nfrequency", 
#                                       "Disturbance\nseverity", 
#                                       "Soil\ndisturbance",
#                                       "Mowing",
#                                       "Grazing"))) %>%
#   filter(! Group == "Intercept") %>%
# filter(pMCMC <= 0.05) %>%
#   ggplot(aes(y = Effect, x = post.mean, 
#              xmin = l.95..CI, xmax = u.95..CI,
#              color = Effect)) +
#   facet_wrap(~ Group, scales = "free_x", nrow = 1) +
#   geom_point(size = 2) +
#   labs(x = "Effect size") +
#   geom_errorbarh(height = .3) +
#   geom_vline(xintercept = 0, linetype = "dashed") +
#   scale_color_manual(values = c("#FFA500",  
#                                 "gold", 
#                                 "#B3EE3A", 
#                                 "#40E0D0",
#                                 "#5CACEE", 
#                                 "#27408B", 
#                                 "#A020F0",
#                                 "#551A8B")) +
#   ggthemes::theme_tufte() +
#   theme(text = element_text(family = "sans", size = 12),
#         strip.background = element_blank(),
#         legend.position = "none", 
#         panel.background = element_rect(color = "black", fill = NULL),
#         axis.title.x = element_text(size = 14), 
#         axis.title.y = element_blank(),
#         axis.text.x = element_text(size = 7.5, color = "black"),
#         axis.text.y = element_text(size = 14,
#                                    color = c("#FFA500",  
#                                              "gold", 
#                                              "#B3EE3A", 
#                                              "#40E0D0",
#                                              "#5CACEE", 
#                                              "#27408B", 
#                                              "#A020F0",
#                                              "#551A8B")),
#         strip.text.x = element_text(size = 14)) -> 
#   fig; fig
# 
# ## Export
# 
# ggsave(fig, file = "results/figures/FigQ21M.png", bg = "white", 
#        path = NULL, scale = 1, width = 173, height = 173, units = "mm", dpi = 600)
# 
# # Calculate lambda http://www.mpcm-evolution.com/practice/online-practical-material-chapter-11/chapter-11-1-simple-model-mcmcglmm
# 
# lambda <- m1$VCV[,"animal"]/(m1$VCV[,"animal"] + m1$VCV[,"units"])
# 
# mean(lambda) %>% round(2) 
# coda::HPDinterval(lambda)[, 1] %>% round(2) 
# coda::HPDinterval(lambda)[, 2] %>% round(2) 
# 
# # Random effects
# 
# summary(m1)$Gcovariances
# 
# 
# 
# 
# 
# ### Single models
# 
# ### Simplified models tree spp and no gymnosperms
# 
# library(tidyverse); library(phangorn)
# 
# rm(list = ls())
# 
# merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1"), 
#       read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1"), 
#       by = "species") %>%
#   mutate(animal = gsub(" ", "_", species)) %>%
#   select(-family) -> germination
# 
# ### Read tree
# 
# phangorn::nnls.tree(cophenetic(ape::read.tree("results/phylo-tree/disturbance.tre")), 
#                     ape::read.tree("results/phylo-tree/disturbance.tre"), method = "ultrametric") -> 
#   nnls_orig
# 
# nnls_orig$node.label <- NULL
# 
# ### Set number of iterations
# nite = 100000
# nbur = 20000
# nthi = 1000
# 
# ### Set priors for germination models (as many prior as random factors)
# 
# priors <- list(R = list(V = 1, nu = 50), 
#                G = list(G1 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500), 
#                         G2 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
#                         G3 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
#                         G4 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
#                         G5 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
#                         G6 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
#                         G7 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500)))   
# 
# ### Model 1: main effects
# 
# MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
#                      scale(severity),
#                    random = ~ animal + 
#                      species + 
#                      datasourceGUID +
#                      country + 
#                      seedlotGUID +
#                      stored +
#                      substrate,
#                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
#                    nitt = nite, thin = nthi, burnin = nbur,
#                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# 
# summary(m1)
# summary(m1)$Gcovariances
# save(m1, file = "results/models/single/severity.Rdata")
# 
# ### Model 1: main effects
# 
# MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
#                      scale(frequency),
#                    random = ~ animal + 
#                      species + 
#                      datasourceGUID +
#                      country + 
#                      seedlotGUID +
#                      stored +
#                      substrate,
#                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
#                    nitt = nite, thin = nthi, burnin = nbur,
#                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# 
# summary(m1)
# summary(m1)$Gcovariances
# save(m1, file = "results/models/single/frequency.Rdata")
# 
# ### Model 1: main effects
# 
# MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
#                      scale(frequency)*scale(temperature),
#                    random = ~ animal + 
#                      species + 
#                      datasourceGUID +
#                      country + 
#                      seedlotGUID +
#                      stored +
#                      substrate,
#                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
#                    nitt = nite, thin = nthi, burnin = nbur,
#                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# 
# summary(m1)
# summary(m1)$Gcovariances
# save(m1, file = "results/models/single/frequency2.Rdata")
# 
# ### Model 1: main effects
# 
# MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
#                      scale(frequency)*scale(alternating),
#                    random = ~ animal + 
#                      species + 
#                      datasourceGUID +
#                      country + 
#                      seedlotGUID +
#                      stored +
#                      substrate,
#                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
#                    nitt = nite, thin = nthi, burnin = nbur,
#                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# 
# summary(m1)
# summary(m1)$Gcovariances
# save(m1, file = "results/models/single/frequency3.Rdata")
# 
# ### Model 1: main effects
# 
# MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
#                      scale(frequency)*scale(light),
#                    random = ~ animal + 
#                      species + 
#                      datasourceGUID +
#                      country + 
#                      seedlotGUID +
#                      stored +
#                      substrate,
#                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
#                    nitt = nite, thin = nthi, burnin = nbur,
#                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# 
# summary(m1)
# summary(m1)$Gcovariances
# save(m1, file = "results/models/single/frequency4.Rdata")
# 
# ### Model 1: main effects
# 
# MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
#                      scale(frequency)*scale(cs),
#                    random = ~ animal + 
#                      species + 
#                      datasourceGUID +
#                      country + 
#                      seedlotGUID +
#                      stored +
#                      substrate,
#                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
#                    nitt = nite, thin = nthi, burnin = nbur,
#                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# 
# summary(m1)
# summary(m1)$Gcovariances
# save(m1, file = "results/models/single/frequency5.Rdata")
# 
# ### Model 1: main effects
# 
# MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
#                      scale(frequency)*scale(scarified),
#                    random = ~ animal + 
#                      species + 
#                      datasourceGUID +
#                      country + 
#                      seedlotGUID +
#                      stored +
#                      substrate,
#                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
#                    nitt = nite, thin = nthi, burnin = nbur,
#                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# 
# summary(m1)
# summary(m1)$Gcovariances
# save(m1, file = "results/models/single/frequency6.Rdata")
# 
# ### Model 1: main effects
# 
# MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
#                      scale(severity)*scale(temperature),
#                    random = ~ animal + 
#                      species + 
#                      datasourceGUID +
#                      country + 
#                      seedlotGUID +
#                      stored +
#                      substrate,
#                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
#                    nitt = nite, thin = nthi, burnin = nbur,
#                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# 
# summary(m1)
# summary(m1)$Gcovariances
# save(m1, file = "results/models/single/severity2.Rdata")
# 
# ### Model 1: main effects
# 
# MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
#                      scale(severity)*scale(alternating),
#                    random = ~ animal + 
#                      species + 
#                      datasourceGUID +
#                      country + 
#                      seedlotGUID +
#                      stored +
#                      substrate,
#                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
#                    nitt = nite, thin = nthi, burnin = nbur,
#                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# 
# summary(m1)
# summary(m1)$Gcovariances
# save(m1, file = "results/models/single/severity3.Rdata")
# 
# ### Model 1: main effects
# 
# MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
#                      scale(severity)*scale(light),
#                    random = ~ animal + 
#                      species + 
#                      datasourceGUID +
#                      country + 
#                      seedlotGUID +
#                      stored +
#                      substrate,
#                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
#                    nitt = nite, thin = nthi, burnin = nbur,
#                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# 
# summary(m1)
# summary(m1)$Gcovariances
# save(m1, file = "results/models/single/severity4.Rdata")
# 
# ### Model 1: main effects
# 
# MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
#                      scale(severity)*scale(cs),
#                    random = ~ animal + 
#                      species + 
#                      datasourceGUID +
#                      country + 
#                      seedlotGUID +
#                      stored +
#                      substrate,
#                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
#                    nitt = nite, thin = nthi, burnin = nbur,
#                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# 
# summary(m1)
# summary(m1)$Gcovariances
# save(m1, file = "results/models/single/severity5.Rdata")
# 
# ### Model 1: main effects
# 
# MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
#                      scale(severity)*scale(scarified),
#                    random = ~ animal + 
#                      species + 
#                      datasourceGUID +
#                      country + 
#                      seedlotGUID +
#                      stored +
#                      substrate,
#                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
#                    nitt = nite, thin = nthi, burnin = nbur,
#                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# 
# summary(m1)
# summary(m1)$Gcovariances
# save(m1, file = "results/models/single/severity6.Rdata")
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# ### Simplified models all spp
# 
# library(tidyverse); library(phangorn)
# 
# rm(list = ls())
# 
# read.csv("results/phylo-tree/output_splist.csv", fileEncoding = "latin1") %>%
#   filter(output.note == "present in megatree") %>% pull(species) -> treespp
# 
# merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1"), 
#       read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1"), 
#       by = "species") %>%
#   mutate(animal = gsub(" ", "_", species)) %>%
#   # filter(species %in% treespp) %>%
#   # filter(! family %in% c("Pinaceae", "Cupressaceae", "Taxaceae", "Taxodiaceae")) %>%
#   select(-family) -> germination
# 
# ### Read tree
# 
# phangorn::nnls.tree(cophenetic(ape::read.tree("results/phylo-tree/disturbance.tre")), 
#                     ape::read.tree("results/phylo-tree/disturbance.tre"), method = "ultrametric") -> 
#   nnls_orig
# 
# nnls_orig$node.label <- NULL
# 
# ### Set number of iterations
# nite = 1000000
# nbur = 200000
# nthi = 1000
# 
# # # Less iterations
# # nite = 100000
# # nbur = 20000
# # nthi = 100
# 
# # # # Less iterations
# # nite = 1000
# # nbur = 500
# # nthi = 50
# # 
# # # Less iterations
# # nite = 100
# # nbur = 50
# # nthi = 5
# 
# 
# ### Set priors for germination models (as many prior as random factors)
# 
# priors <- list(R = list(V = 1, nu = 50), 
#                G = list(G1 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500), 
#                         G2 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
#                         G3 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
#                         G4 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500)))   
# 
# ### Model 1: main effects
# 
# MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
#                      scale(temperature) +
#                      scale(alternating) +
#                      scale(light) +
#                      scale(cs) +
#                      scale(scarified) +
#                      scale(temperature) * scale(severity) +
#                      scale(temperature) * scale(frequency) +
#                      scale(alternating) * scale(severity) +
#                      scale(alternating) * scale(frequency) +
#                      scale(light) * scale(severity) +
#                      scale(light) * scale(frequency) +
#                      scale(cs) * scale(severity) +
#                      scale(cs) * scale(frequency) +
#                      scale(scarified) * scale(severity) +
#                      scale(scarified) * scale(frequency),
#                    random = ~ animal + 
#                      species + 
#                      datasourceGUID +
#                      seedlotGUID,
#                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
#                    nitt = nite, thin = nthi, burnin = nbur,
#                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# 
# summary(m1)
# save(m1, file = "results/models/simplified/1M/all-spp-lessrf.Rdata")
# 
# summary(m1)$solutions %>%
#   data.frame %>%
#   rownames_to_column(var = "Parameter") %>%
#   mutate(Parameter = fct_recode(Parameter, 
#                                 "Intercept:Intercept" = "(Intercept)",
#                                 "Temperature:Germination cue\n(Main effects)" = "scale(temperature)",
#                                 "Alternating temperature:Germination cue\n(Main effects)" = "scale(alternating)",
#                                 "Light:Germination cue\n(Main effects)" = "scale(light)",
#                                 "Cold stratification:Germination cue\n(Main effects)" = "scale(cs)",
#                                 "Warm stratification:Germination cue\n(Main effects)" = "scale(ws)",
#                                 "Scarification:Germination cue\n(Main effects)" = "scale(scarified)",
#                                 "Main effect:Disturbance\nseverity" = "scale(severity)",
#                                 "Main effect:Disturbance\nfrequency" = "scale(frequency)",
#                                 "Main effect:Mowing" = "scale(mowing)",
#                                 "Main effect:Grazing" = "scale(grazing)",
#                                 "Main effect:Soil\ndisturbance" = "scale(soil)",
#                                 "Temperature:Disturbance\nseverity" = "scale(temperature):scale(severity)",
#                                 "Temperature:Disturbance\nfrequency" = "scale(temperature):scale(frequency)",
#                                 "Temperature:Mowing" = "scale(temperature):scale(mowing)",
#                                 "Temperature:Grazing" = "scale(temperature):scale(grazing)",
#                                 "Temperature:Soil\ndisturbance" = "scale(temperature):scale(soil)",
#                                 "Alternating temperature:Disturbance\nseverity" = "scale(alternating):scale(severity)",
#                                 "Alternating temperature:Disturbance\nfrequency" = "scale(alternating):scale(frequency)",
#                                 "Alternating temperature:Mowing" = "scale(alternating):scale(mowing)",
#                                 "Alternating temperature:Grazing" = "scale(alternating):scale(grazing)",
#                                 "Alternating temperature:Soil\ndisturbance" = "scale(alternating):scale(soil)",
#                                 "Light:Disturbance\nseverity" = "scale(light):scale(severity)",
#                                 "Light:Disturbance\nfrequency" = "scale(light):scale(frequency)",
#                                 "Light:Mowing" = "scale(light):scale(mowing)",
#                                 "Light:Grazing" = "scale(light):scale(grazing)",
#                                 "Light:Soil\ndisturbance" = "scale(light):scale(soil)",
#                                 "Cold stratification:Disturbance\nseverity" = "scale(cs):scale(severity)",
#                                 "Cold stratification:Disturbance\nfrequency" = "scale(cs):scale(frequency)",
#                                 "Cold stratification:Mowing" = "scale(cs):scale(mowing)",
#                                 "Cold stratification:Grazing" = "scale(cs):scale(grazing)",
#                                 "Cold stratification:Soil\ndisturbance" = "scale(cs):scale(soil)",
#                                 "Warm stratification:Disturbance\nseverity" = "scale(ws):scale(severity)",
#                                 "Warm stratification:Disturbance\nfrequency" = "scale(ws):scale(frequency)",
#                                 "Warm stratification:Mowing" = "scale(ws):scale(mowing)",
#                                 "Warm stratification:Grazing" = "scale(ws):scale(grazing)",
#                                 "Warm stratification:Soil\ndisturbance" = "scale(ws):scale(soil)",
#                                 "Scarification:Disturbance\nseverity" = "scale(scarified):scale(severity)",
#                                 "Scarification:Disturbance\nfrequency" = "scale(scarified):scale(frequency)",
#                                 "Scarification:Mowing" = "scale(scarified):scale(mowing)",
#                                 "Scarification:Grazing" = "scale(scarified):scale(grazing)",
#                                 "Scarification:Soil\ndisturbance" = "scale(scarified):scale(soil)")) %>%
#   separate(Parameter, into = c("Effect", "Group"), sep = ":") %>%
#   mutate(Effect = fct_relevel(Effect, c("Light", 
#                                         "Alternating temperature", 
#                                         "Temperature", 
#                                         "Warm stratification", 
#                                         "Cold stratification", 
#                                         "Scarification")),
#          Group = fct_relevel(Group, c("Germination cue\n(Main effects)", 
#                                       "Disturbance\nfrequency", 
#                                       "Disturbance\nseverity", 
#                                       "Soil\ndisturbance",
#                                       "Mowing",
#                                       "Grazing"))) %>%
#   filter(! Group == "Intercept") %>%
#   filter(pMCMC <= 0.05) %>%
#   ggplot(aes(y = Effect, x = post.mean, 
#              xmin = l.95..CI, xmax = u.95..CI,
#              color = Effect)) +
#   facet_wrap(~ Group, scales = "free_x", nrow = 1) +
#   geom_point(size = 2) +
#   labs(x = "Effect size") +
#   geom_errorbarh(height = .3) +
#   geom_vline(xintercept = 0, linetype = "dashed") +
#   scale_color_manual(values = c("#FFA500",  
#                                 "gold", 
#                                 "#B3EE3A", 
#                                 "#40E0D0",
#                                 "#5CACEE", 
#                                 "#27408B", 
#                                 "#A020F0",
#                                 "#551A8B")) +
#   ggthemes::theme_tufte() +
#   theme(text = element_text(family = "sans", size = 12),
#         strip.background = element_blank(),
#         legend.position = "none", 
#         panel.background = element_rect(color = "black", fill = NULL),
#         axis.title.x = element_text(size = 14), 
#         axis.title.y = element_blank(),
#         axis.text.x = element_text(size = 7.5, color = "black"),
#         axis.text.y = element_text(size = 14,
#                                    color = c("#FFA500",  
#                                              "gold", 
#                                              "#B3EE3A", 
#                                              "#40E0D0",
#                                              "#5CACEE", 
#                                              "#27408B", 
#                                              "#A020F0",
#                                              "#551A8B")),
#         strip.text.x = element_text(size = 14)) -> 
#   fig; fig
# 
# ## Export
# 
# ggsave(fig, file = "results/figures/FigQ01Mlessrf.png", bg = "white", 
#        path = NULL, scale = 1, width = 173, height = 173, units = "mm", dpi = 600)
# 
# # Calculate lambda http://www.mpcm-evolution.com/practice/online-practical-material-chapter-11/chapter-11-1-simple-model-mcmcglmm
# 
# lambda <- m1$VCV[,"animal"]/(m1$VCV[,"animal"] + m1$VCV[,"units"])
# 
# mean(lambda) %>% round(2) 
# coda::HPDinterval(lambda)[, 1] %>% round(2) 
# coda::HPDinterval(lambda)[, 2] %>% round(2) 
# 
# # Random effects
# 
# summary(m1)$Gcovariances
# 
# 
# 
# ### Simplified models tree spp and no gymnosperms
# 
# library(tidyverse); library(phangorn)
# 
# rm(list = ls())
# 
# read.csv("results/phylo-tree/output_splist.csv", fileEncoding = "latin1") %>%
#   filter(output.note == "present in megatree") %>% pull(species) -> treespp
# 
# merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1"), 
#       read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1"), 
#       by = "species") %>%
#   mutate(animal = gsub(" ", "_", species)) %>%
#   filter(species %in% treespp) %>%
#   filter(! family %in% c("Pinaceae", "Cupressaceae", "Taxaceae", "Taxodiaceae")) %>%
#   select(-family) -> germination
# 
# ### Read tree
# 
# phangorn::nnls.tree(cophenetic(ape::read.tree("results/phylo-tree/disturbance.tre")), 
#                     ape::read.tree("results/phylo-tree/disturbance.tre"), method = "ultrametric") -> 
#   nnls_orig
# 
# nnls_orig$node.label <- NULL
# 
# ### Set number of iterations
# nite = 1000000
# nbur = 200000
# nthi = 1000
# 
# # # Less iterations
# # nite = 100000
# # nbur = 20000
# # nthi = 100
# 
# # # # Less iterations
# # nite = 1000
# # nbur = 500
# # nthi = 50
# # 
# # # Less iterations
# # nite = 100
# # nbur = 50
# # nthi = 5
# 
# ### Set priors for germination models (as many prior as random factors)
# 
# priors <- list(R = list(V = 1, nu = 50), 
#                G = list(G1 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500), 
#                         G2 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
#                         G3 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
#                         G4 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500)))   
# 
# ### Model 1: main effects
# 
# MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ 
#                      scale(temperature) +
#                      scale(alternating) +
#                      scale(light) +
#                      scale(cs) +
#                      scale(scarified) +
#                      scale(temperature) * scale(severity) +
#                      scale(temperature) * scale(frequency) +
#                      scale(alternating) * scale(severity) +
#                      scale(alternating) * scale(frequency) +
#                      scale(light) * scale(severity) +
#                      scale(light) * scale(frequency) +
#                      scale(cs) * scale(severity) +
#                      scale(cs) * scale(frequency) +
#                      scale(scarified) * scale(severity) +
#                      scale(scarified) * scale(frequency),
#                    random = ~ animal + 
#                      species + 
#                      datasourceGUID +
#                      seedlotGUID,
#                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
#                    nitt = nite, thin = nthi, burnin = nbur,
#                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# 
# summary(m1)
# save(m1, file = "results/models/simplified/1M/tree-spp-no-gymno-lessrf.Rdata")
# 
# summary(m1)$solutions %>%
#   data.frame %>%
#   rownames_to_column(var = "Parameter") %>%
#   mutate(Parameter = fct_recode(Parameter, 
#                                 "Intercept:Intercept" = "(Intercept)",
#                                 "Temperature:Germination cue\n(Main effects)" = "scale(temperature)",
#                                 "Alternating temperature:Germination cue\n(Main effects)" = "scale(alternating)",
#                                 "Light:Germination cue\n(Main effects)" = "scale(light)",
#                                 "Cold stratification:Germination cue\n(Main effects)" = "scale(cs)",
#                                 "Warm stratification:Germination cue\n(Main effects)" = "scale(ws)",
#                                 "Scarification:Germination cue\n(Main effects)" = "scale(scarified)",
#                                 "Main effect:Disturbance\nseverity" = "scale(severity)",
#                                 "Main effect:Disturbance\nfrequency" = "scale(frequency)",
#                                 "Main effect:Mowing" = "scale(mowing)",
#                                 "Main effect:Grazing" = "scale(grazing)",
#                                 "Main effect:Soil\ndisturbance" = "scale(soil)",
#                                 "Temperature:Disturbance\nseverity" = "scale(temperature):scale(severity)",
#                                 "Temperature:Disturbance\nfrequency" = "scale(temperature):scale(frequency)",
#                                 "Temperature:Mowing" = "scale(temperature):scale(mowing)",
#                                 "Temperature:Grazing" = "scale(temperature):scale(grazing)",
#                                 "Temperature:Soil\ndisturbance" = "scale(temperature):scale(soil)",
#                                 "Alternating temperature:Disturbance\nseverity" = "scale(alternating):scale(severity)",
#                                 "Alternating temperature:Disturbance\nfrequency" = "scale(alternating):scale(frequency)",
#                                 "Alternating temperature:Mowing" = "scale(alternating):scale(mowing)",
#                                 "Alternating temperature:Grazing" = "scale(alternating):scale(grazing)",
#                                 "Alternating temperature:Soil\ndisturbance" = "scale(alternating):scale(soil)",
#                                 "Light:Disturbance\nseverity" = "scale(light):scale(severity)",
#                                 "Light:Disturbance\nfrequency" = "scale(light):scale(frequency)",
#                                 "Light:Mowing" = "scale(light):scale(mowing)",
#                                 "Light:Grazing" = "scale(light):scale(grazing)",
#                                 "Light:Soil\ndisturbance" = "scale(light):scale(soil)",
#                                 "Cold stratification:Disturbance\nseverity" = "scale(cs):scale(severity)",
#                                 "Cold stratification:Disturbance\nfrequency" = "scale(cs):scale(frequency)",
#                                 "Cold stratification:Mowing" = "scale(cs):scale(mowing)",
#                                 "Cold stratification:Grazing" = "scale(cs):scale(grazing)",
#                                 "Cold stratification:Soil\ndisturbance" = "scale(cs):scale(soil)",
#                                 "Warm stratification:Disturbance\nseverity" = "scale(ws):scale(severity)",
#                                 "Warm stratification:Disturbance\nfrequency" = "scale(ws):scale(frequency)",
#                                 "Warm stratification:Mowing" = "scale(ws):scale(mowing)",
#                                 "Warm stratification:Grazing" = "scale(ws):scale(grazing)",
#                                 "Warm stratification:Soil\ndisturbance" = "scale(ws):scale(soil)",
#                                 "Scarification:Disturbance\nseverity" = "scale(scarified):scale(severity)",
#                                 "Scarification:Disturbance\nfrequency" = "scale(scarified):scale(frequency)",
#                                 "Scarification:Mowing" = "scale(scarified):scale(mowing)",
#                                 "Scarification:Grazing" = "scale(scarified):scale(grazing)",
#                                 "Scarification:Soil\ndisturbance" = "scale(scarified):scale(soil)")) %>%
#   separate(Parameter, into = c("Effect", "Group"), sep = ":") %>%
#   mutate(Effect = fct_relevel(Effect, c("Light", 
#                                         "Alternating temperature", 
#                                         "Temperature", 
#                                         "Warm stratification", 
#                                         "Cold stratification", 
#                                         "Scarification")),
#          Group = fct_relevel(Group, c("Germination cue\n(Main effects)", 
#                                       "Disturbance\nfrequency", 
#                                       "Disturbance\nseverity", 
#                                       "Soil\ndisturbance",
#                                       "Mowing",
#                                       "Grazing"))) %>%
#   filter(! Group == "Intercept") %>%
#   filter(pMCMC <= 0.05) %>%
#   ggplot(aes(y = Effect, x = post.mean, 
#              xmin = l.95..CI, xmax = u.95..CI,
#              color = Effect)) +
#   facet_wrap(~ Group, scales = "free_x", nrow = 1) +
#   geom_point(size = 2) +
#   labs(x = "Effect size") +
#   geom_errorbarh(height = .3) +
#   geom_vline(xintercept = 0, linetype = "dashed") +
#   scale_color_manual(values = c("#FFA500",  
#                                 "gold", 
#                                 "#B3EE3A", 
#                                 "#40E0D0",
#                                 "#5CACEE", 
#                                 "#27408B", 
#                                 "#A020F0",
#                                 "#551A8B")) +
#   ggthemes::theme_tufte() +
#   theme(text = element_text(family = "sans", size = 12),
#         strip.background = element_blank(),
#         legend.position = "none", 
#         panel.background = element_rect(color = "black", fill = NULL),
#         axis.title.x = element_text(size = 14), 
#         axis.title.y = element_blank(),
#         axis.text.x = element_text(size = 7.5, color = "black"),
#         axis.text.y = element_text(size = 14,
#                                    color = c("#FFA500",  
#                                              "gold", 
#                                              "#B3EE3A", 
#                                              "#40E0D0",
#                                              "#5CACEE", 
#                                              "#27408B", 
#                                              "#A020F0",
#                                              "#551A8B")),
#         strip.text.x = element_text(size = 14)) -> 
#   fig; fig
# 
# ## Export
# 
# ggsave(fig, file = "results/figures/FigQ21Mlessrf.png", bg = "white", 
#        path = NULL, scale = 1, width = 173, height = 173, units = "mm", dpi = 600)
# 
# # Calculate lambda http://www.mpcm-evolution.com/practice/online-practical-material-chapter-11/chapter-11-1-simple-model-mcmcglmm
# 
# lambda <- m1$VCV[,"animal"]/(m1$VCV[,"animal"] + m1$VCV[,"units"])
# 
# mean(lambda) %>% round(2) 
# coda::HPDinterval(lambda)[, 1] %>% round(2) 
# coda::HPDinterval(lambda)[, 2] %>% round(2) 
# 
# # Random effects
# 
# summary(m1)$Gcovariances
# 
# quit()
# n

library(tidyverse)

### Frequency single models

load(file = "results/models/trials/single/frequency.RData")
summary(m1)

load(file = "results/models/trials/single/frequency2.RData")
summary(m1)

load(file = "results/models/trials/single/frequency3.RData")
summary(m1)

load(file = "results/models/trials/single/frequency4.RData")
summary(m1)

load(file = "results/models/trials/single/frequency5.RData")
summary(m1)

load(file = "results/models/trials/single/frequency6.RData")
summary(m1)

### Severity single models

load(file = "results/models/trials/single/severity.RData")
summary(m1)

load(file = "results/models/trials/single/severity2.RData")
summary(m1)

load(file = "results/models/trials/single/severity3.RData")
summary(m1)

load(file = "results/models/trials/single/severity4.RData")
summary(m1)

load(file = "results/models/trials/single/severity5.RData")
summary(m1)

load(file = "results/models/trials/single/severity6.RData")
summary(m1)
