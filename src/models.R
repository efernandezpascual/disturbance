library(tidyverse); library(phangorn)

### Germination dataset for models

merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1"),
      read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1"),
      by = "species") %>%
  mutate(animal = gsub(" ", "_", species)) -> germination

### Read tree

phangorn::nnls.tree(cophenetic(ape::read.tree("results/phylo-tree/disturbance.tre")),
                    ape::read.tree("results/phylo-tree/disturbance.tre"), method = "ultrametric") ->
  nnls_orig

nnls_orig$node.label <- NULL

### Set number of iterations

nite = 1000000
nbur = 200000
nthi = 1000

# nite = 100
# nbur = 10
# nthi = 5

### Set priors for germination models (as many prior as random factors)

priors <- list(R = list(V = 1, nu = 50),
               G = list(G1 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
                        G2 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
                        G3 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
                        G4 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500)))

# ### Objective 1 (compare four groups)
# 
# germination %>%
#   separate(Group, into = c("Stress", "Disturbance"), sep = " - ") %>%
#   mutate(Stress = fct_relevel(Stress, "Low stress", "High stress")) %>%
#   mutate(Disturbance = fct_relevel(Disturbance, "Low disturbance", "High disturbance")) %>%
#   select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated, Stress, Disturbance) %>%
#   na.omit -> germinationDF
# 
# MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ Stress + Disturbance,
#                    random = ~ animal +
#                      species +
#                      datasourceGUID +
#                      seedlotGUID,
#                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germinationDF,
#                    nitt = nite, thin = nthi, burnin = nbur,
#                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# 
# save(m1, file = "results/models/obj1/m1.Rdata")
# 
# ### Objective 2 model LL (germination drivers in low stress - low disturbance group)
# 
# germination %>%
#   filter(Group == "Low stress - Low disturbance") %>%
#   select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated,
#          temperature, alternating, light, cs, scarified) %>%
#   na.omit -> germinationDF
# 
# MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~  
#                      scale(temperature) +
#                      scale(alternating) +
#                      scale(light) +
#                      scale(cs) +
#                      scale(scarified),
#                    random = ~ animal +
#                      species +
#                      datasourceGUID +
#                      seedlotGUID,
#                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germinationDF,
#                    nitt = nite, thin = nthi, burnin = nbur,
#                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m2.LL
# 
# save(m2.LL, file = "results/models/obj2/m2.LL.Rdata")
# 
# ### Objective 2 model LH (germination drivers in low stress - high disturbance group)
# 
# germination %>%
#   filter(Group == "Low stress - High disturbance") %>%
#   select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated,
#          temperature, alternating, light, cs, scarified) %>%
#   na.omit -> germinationDF
# 
# MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~  
#                      scale(temperature) +
#                      scale(alternating) +
#                      scale(light) +
#                      scale(cs) +
#                      scale(scarified),
#                    random = ~ animal +
#                      species +
#                      datasourceGUID +
#                      seedlotGUID,
#                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germinationDF,
#                    nitt = nite, thin = nthi, burnin = nbur,
#                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m2.LH
# 
# save(m2.LH, file = "results/models/obj2/m2.LH.Rdata")
# 
# ### Objective 2 model HL (germination drivers in high stress - low disturbance group)
# 
# germination %>%
#   filter(Group == "High stress - Low disturbance") %>%
#   select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated,
#          temperature, alternating, light, cs, scarified) %>%
#   na.omit -> germinationDF
# 
# MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~  
#                      scale(temperature) +
#                      scale(alternating) +
#                      scale(light) +
#                      scale(cs) +
#                      scale(scarified),
#                    random = ~ animal +
#                      species +
#                      datasourceGUID +
#                      seedlotGUID,
#                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germinationDF,
#                    nitt = nite, thin = nthi, burnin = nbur,
#                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m2.HL
# 
# save(m2.HL, file = "results/models/obj2/m2.HL.Rdata")
# 
# ### Objective 2 model HH (germination drivers in high stress - high disturbance group)
# 
# germination %>%
#   filter(Group == "High stress - High disturbance") %>%
#   select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated,
#          temperature, alternating, light, cs, scarified) %>%
#   na.omit -> germinationDF
# 
# MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~  
#                      scale(temperature) +
#                      scale(alternating) +
#                      scale(light) +
#                      scale(cs) +
#                      scale(scarified),
#                    random = ~ animal +
#                      species +
#                      datasourceGUID +
#                      seedlotGUID,
#                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germinationDF,
#                    nitt = nite, thin = nthi, burnin = nbur,
#                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m2.HH
# 
# save(m2.HH, file = "results/models/obj2/m2.HH.Rdata")

### Model diagnostics

load(file = "results/models/obj1/m1.Rdata")
plot(m1) # Model diagnostics
summary(m1) # Model summary

load(file = "results/models/obj2/m2.LL.Rdata")
plot(m2.LL) # Model diagnostics
summary(m2.LL) # Model summary

load(file = "results/models/obj2/m2.LH.Rdata")
plot(m2.LH) # Model diagnostics
summary(m2.LH) # Model summary

load(file = "results/models/obj2/m2.HL.Rdata")
plot(m2.HL) # Model diagnostics
summary(m2.HL) # Model summary

load(file = "results/models/obj2/m2.HH.Rdata")
plot(m2.HH) # Model diagnostics
summary(m2.HH) # Model summary

### Model summary

write.csv(summary(m1)$solutions, "results/models/obj1/summary-m1.csv", row.names = FALSE, fileEncoding = "latin1")
write.csv(summary(m2.LL)$solutions, "results/models/obj2/summary-m2.LL.csv", row.names = FALSE, fileEncoding = "latin1")
write.csv(summary(m2.LH)$solutions, "results/models/obj2/summary-m2.LH.csv", row.names = FALSE, fileEncoding = "latin1")
write.csv(summary(m2.HL)$solutions, "results/models/obj2/summary-m2.HL.csv", row.names = FALSE, fileEncoding = "latin1")
write.csv(summary(m2.HH)$solutions, "results/models/obj2/summary-m2.HH.csv", row.names = FALSE, fileEncoding = "latin1")

### Phylo signal http://www.mpcm-evolution.com/practice/online-practical-material-chapter-11/chapter-11-1-simple-model-mcmcglmm

lambda <- m1$VCV[,"animal"]/(m1$VCV[,"animal"] + m1$VCV[,"units"])
data.frame(
  lambda = mean(lambda) %>% round(2),
  min = coda::HPDinterval(lambda)[, 1] %>% round(2),
  max = coda::HPDinterval(lambda)[, 2] %>% round(2))

lambda <- m2.LL$VCV[,"animal"]/(m2.LL$VCV[,"animal"] + m2.LL$VCV[,"units"])
data.frame(
  lambda = mean(lambda) %>% round(2),
  min = coda::HPDinterval(lambda)[, 1] %>% round(2),
  max = coda::HPDinterval(lambda)[, 2] %>% round(2))

lambda <- m2.LH$VCV[,"animal"]/(m2.LH$VCV[,"animal"] + m2.LH$VCV[,"units"])
data.frame(
  lambda = mean(lambda) %>% round(2),
  min = coda::HPDinterval(lambda)[, 1] %>% round(2),
  max = coda::HPDinterval(lambda)[, 2] %>% round(2))

lambda <- m2.HL$VCV[,"animal"]/(m2.HL$VCV[,"animal"] + m2.HL$VCV[,"units"])
data.frame(
  lambda = mean(lambda) %>% round(2),
  min = coda::HPDinterval(lambda)[, 1] %>% round(2),
  max = coda::HPDinterval(lambda)[, 2] %>% round(2))

lambda <- m2.HH$VCV[,"animal"]/(m2.HH$VCV[,"animal"] + m2.HH$VCV[,"units"])
data.frame(
  lambda = mean(lambda) %>% round(2),
  min = coda::HPDinterval(lambda)[, 1] %>% round(2),
  max = coda::HPDinterval(lambda)[, 2] %>% round(2))

### Random effects

summary(m1)$Gcovariances
summary(m2.LL)$Gcovariances
summary(m2.LH)$Gcovariances
summary(m2.HL)$Gcovariances
summary(m2.HH)$Gcovariances
