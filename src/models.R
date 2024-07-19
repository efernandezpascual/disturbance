library(tidyverse); library(phangorn)

### Germination dataset for models

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
merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1"),
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

nite = 100
nbur = 10
nthi = 5

nite = 1000
nbur = 50
nthi = 10

nite = 500000
nbur = 50000
nthi = 50

### Set priors for germination models (as many prior as random factors)

priors <- list(R = list(V = 1, nu = 50),
               G = list(G1 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
                        G2 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
                        G3 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
                        G4 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500)))


### Objective 1 (compare eight groups) with interaction

germination %>%
  mutate(Stress = fct_relevel(Stress, "Low stress")) %>%
  mutate(Disturbance = fct_relevel(Disturbance, "Low disturbance")) %>%
  select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated, Group, Stress, Disturbance) %>%
  na.omit -> germinationDF

MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ Stress * Disturbance,
                   random = ~ animal +
                     species +
                     datasourceGUID +
                     seedlotGUID,
                   family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germinationDF,
                   nitt = nite, thin = nthi, burnin = nbur,
                   verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1.A

save(m1.A, file = "results/models/obj1/m1.A.Rdata")

### Objective 1 (compare eight groups) without interaction

germination %>%
  mutate(Stress = fct_relevel(Stress, "Low stress")) %>%
  mutate(Disturbance = fct_relevel(Disturbance, "Low disturbance")) %>%
  select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated, Group, Stress, Disturbance) %>%
  na.omit -> germinationDF

MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ Stress + Disturbance,
                   random = ~ animal +
                     species +
                     datasourceGUID +
                     seedlotGUID,
                   family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germinationDF,
                   nitt = nite, thin = nthi, burnin = nbur,
                   verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1.B

save(m1.B, file = "results/models/obj1/m1.B.Rdata")

### Objective 1 (compare eight groups) one factor

germination %>%
  mutate(Group = fct_relevel(Group, "Low stress - Low disturbance")) %>%
  select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated, Group, Stress, Disturbance) %>%
  na.omit -> germinationDF

MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ Group,
                   random = ~ animal +
                     species +
                     datasourceGUID +
                     seedlotGUID,
                   family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germinationDF,
                   nitt = nite, thin = nthi, burnin = nbur,
                   verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1.C

save(m1.C, file = "results/models/obj1/m1.C.Rdata")

### Objective 1 (compare eight groups) one factor no intercept

germination %>%
  mutate(Group = fct_relevel(Group, "Low stress - Low disturbance")) %>%
  select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated, Group, Stress, Disturbance) %>%
  na.omit -> germinationDF

MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ Group - 1,
                   random = ~ animal +
                     species +
                     datasourceGUID +
                     seedlotGUID,
                   family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germinationDF,
                   nitt = nite, thin = nthi, burnin = nbur,
                   verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1.D

save(m1.D, file = "results/models/obj1/m1.D.Rdata")

### Objective 2 model 2.1 (germination drivers in low stress - low disturbance group)

germination %>%
  filter(Group == "Low stress - Low disturbance") %>%
  select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated,
         temperature, alternating, light, cs, scarified) %>%
  na.omit -> germinationDF

MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~
                     scale(temperature) +
                     scale(alternating) +
                     scale(light) +
                     scale(cs) +
                     scale(scarified),
                   random = ~ animal +
                     species +
                     datasourceGUID +
                     seedlotGUID,
                   family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germinationDF,
                   nitt = nite, thin = nthi, burnin = nbur,
                   verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m2.1

save(m2.1, file = "results/models/obj2/m2.1.Rdata")

### Objective 2 model 2.2 (germination drivers in low stress - high disturbance group)

germination %>%
  filter(Group == "Low stress - High disturbance") %>%
  select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated,
         temperature, alternating, light, cs, scarified) %>%
  na.omit -> germinationDF

MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~
                     scale(temperature) +
                     scale(alternating) +
                     scale(light) +
                     scale(cs) +
                     scale(scarified),
                   random = ~ animal +
                     species +
                     datasourceGUID +
                     seedlotGUID,
                   family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germinationDF,
                   nitt = nite, thin = nthi, burnin = nbur,
                   verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m2.2

save(m2.2, file = "results/models/obj2/m2.2.Rdata")

### Objective 2 model 2.3 (germination drivers in water stress - low disturbance group)

germination %>%
  filter(Group == "Water stress - Low disturbance") %>%
  select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated,
         temperature, alternating, light, cs, scarified) %>%
  na.omit -> germinationDF

MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~
                     scale(temperature) +
                     scale(alternating) +
                     scale(light) +
                     scale(cs) +
                     scale(scarified),
                   random = ~ animal +
                     species +
                     datasourceGUID +
                     seedlotGUID,
                   family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germinationDF,
                   nitt = nite, thin = nthi, burnin = nbur,
                   verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m2.3

save(m2.3, file = "results/models/obj2/m2.3.Rdata")

### Objective 2 model 2.4 (germination drivers in water stress - high disturbance group)

germination %>%
  filter(Group == "Water stress - High disturbance") %>%
  select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated,
         temperature, alternating, light, cs, scarified) %>%
  na.omit -> germinationDF

MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~
                     scale(temperature) +
                     scale(alternating) +
                     scale(light) +
                     scale(cs) +
                     scale(scarified),
                   random = ~ animal +
                     species +
                     datasourceGUID +
                     seedlotGUID,
                   family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germinationDF,
                   nitt = nite, thin = nthi, burnin = nbur,
                   verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m2.4

save(m2.4, file = "results/models/obj2/m2.4.Rdata")

### Objective 2 model 2.5 (germination drivers in cold stress - low disturbance group)

germination %>%
  filter(Group == "Cold stress - Low disturbance") %>%
  select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated,
         temperature, alternating, light, cs, scarified) %>%
  na.omit -> germinationDF

MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~
                     scale(temperature) +
                     scale(alternating) +
                     scale(light) +
                     scale(cs) +
                     scale(scarified),
                   random = ~ animal +
                     species +
                     datasourceGUID +
                     seedlotGUID,
                   family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germinationDF,
                   nitt = nite, thin = nthi, burnin = nbur,
                   verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m2.5

save(m2.5, file = "results/models/obj2/m2.5.Rdata")

### Objective 2 model 2.6 (germination drivers in cold stress - high disturbance group)

germination %>%
  filter(Group == "Cold stress - High disturbance") %>%
  select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated,
         temperature, alternating, light, cs, scarified) %>%
  na.omit -> germinationDF

MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~
                     scale(temperature) +
                     scale(alternating) +
                     scale(light) +
                     scale(cs) +
                     scale(scarified),
                   random = ~ animal +
                     species +
                     datasourceGUID +
                     seedlotGUID,
                   family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germinationDF,
                   nitt = nite, thin = nthi, burnin = nbur,
                   verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m2.6

save(m2.6, file = "results/models/obj2/m2.6.Rdata")

### Objective 2 model 2.7 (germination drivers in Wetlands stress - low disturbance group)

germination %>%
  filter(Group == "Wetlands - Low disturbance") %>%
  select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated,
         temperature, alternating, light, cs, scarified) %>%
  na.omit -> germinationDF

MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~
                     scale(temperature) +
                     scale(alternating) +
                     scale(light) +
                     scale(cs) +
                     scale(scarified),
                   random = ~ animal +
                     species +
                     datasourceGUID +
                     seedlotGUID,
                   family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germinationDF,
                   nitt = nite, thin = nthi, burnin = nbur,
                   verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m2.7

save(m2.7, file = "results/models/obj2/m2.7.Rdata")

### Objective 2 model 2.8 (germination drivers in Wetlands - high disturbance group)

germination %>%
  filter(Group == "Wetlands - High disturbance") %>%
  select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated,
         temperature, alternating, light, cs, scarified) %>%
  na.omit -> germinationDF

MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~
                     scale(temperature) +
                     scale(alternating) +
                     scale(light) +
                     scale(cs) +
                     scale(scarified),
                   random = ~ animal +
                     species +
                     datasourceGUID +
                     seedlotGUID,
                   family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germinationDF,
                   nitt = nite, thin = nthi, burnin = nbur,
                   verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m2.8

save(m2.8, file = "results/models/obj2/m2.8.Rdata")

##Model diagnostics

load(file = "results/models/obj1/m1.A.Rdata")
plot(m1.A) # Model diagnostics
summary(m1.A) # Model summary

load(file = "results/models/obj1/m1.B.Rdata")
plot(m1.B) # Model diagnostics
summary(m1.B) # Model summary

load(file = "results/models/obj1/m1.C.Rdata")
plot(m1.C) # Model diagnostics
summary(m1.C) # Model summary

load(file = "results/models/obj1/m1.D.Rdata")
plot(m1.D) # Model diagnostics
summary(m1.D) # Model summary

load(file = "results/models/obj2/m2.1.Rdata")
plot(m2.1) # Model diagnostics
summary(m2.1) # Model summary

load(file = "results/models/obj2/m2.2.Rdata")
plot(m2.2) # Model diagnostics
summary(m2.2) # Model summary

load(file = "results/models/obj2/m2.3.Rdata")
plot(m2.3) # Model diagnostics
summary(m2.3) # Model summary

load(file = "results/models/obj2/m2.4.Rdata")
plot(m2.4) # Model diagnostics
summary(m2.4) # Model summary

load(file = "results/models/obj2/m2.5.Rdata")
plot(m2.5) # Model diagnostics
summary(m2.5) # Model summary

load(file = "results/models/obj2/m2.6.Rdata")
plot(m2.6) # Model diagnostics
summary(m2.6) # Model summary

load(file = "results/models/obj2/m2.7.Rdata")
plot(m2.7) # Model diagnostics
summary(m2.7) # Model summary

load(file = "results/models/obj2/m2.8.Rdata")
plot(m2.8) # Model diagnostics
summary(m2.8) # Model summary

### Model summary

write.csv(summary(m1.A)$solutions, "results/models/obj1/summary-m1.A.csv", row.names = FALSE, fileEncoding = "latin1")
write.csv(summary(m1.B)$solutions, "results/models/obj1/summary-m1.B.csv", row.names = FALSE, fileEncoding = "latin1")
write.csv(summary(m2.1)$solutions, "results/models/obj2/summary-m2.1.csv", row.names = FALSE, fileEncoding = "latin1")
write.csv(summary(m2.2)$solutions, "results/models/obj2/summary-m2.2.csv", row.names = FALSE, fileEncoding = "latin1")
write.csv(summary(m2.3)$solutions, "results/models/obj2/summary-m2.3.csv", row.names = FALSE, fileEncoding = "latin1")
write.csv(summary(m2.4)$solutions, "results/models/obj2/summary-m2.4.csv", row.names = FALSE, fileEncoding = "latin1")
write.csv(summary(m2.5)$solutions, "results/models/obj2/summary-m2.5.csv", row.names = FALSE, fileEncoding = "latin1")
write.csv(summary(m2.6)$solutions, "results/models/obj2/summary-m2.6.csv", row.names = FALSE, fileEncoding = "latin1")
write.csv(summary(m2.7)$solutions, "results/models/obj2/summary-m2.7.csv", row.names = FALSE, fileEncoding = "latin1")
write.csv(summary(m2.8)$solutions, "results/models/obj2/summary-m2.8.csv", row.names = FALSE, fileEncoding = "latin1")

### Phylo signal http://www.mpcm-evolution.com/practice/online-practical-material-chapter-11/chapter-11-1-simple-model-mcmcglmm

lambda <- m1.A$VCV[,"animal"]/(m1.A$VCV[,"animal"] + m1.A$VCV[,"units"])
data.frame(
  lambda = mean(lambda) %>% round(2),
  min = coda::HPDinterval(lambda)[, 1] %>% round(2),
  max = coda::HPDinterval(lambda)[, 2] %>% round(2))

lambda <- m1.B$VCV[,"animal"]/(m1.B$VCV[,"animal"] + m1.B$VCV[,"units"])
data.frame(
  lambda = mean(lambda) %>% round(2),
  min = coda::HPDinterval(lambda)[, 1] %>% round(2),
  max = coda::HPDinterval(lambda)[, 2] %>% round(2))

lambda <- m2.1$VCV[,"animal"]/(m2.1$VCV[,"animal"] + m2.1$VCV[,"units"])
data.frame(
  lambda = mean(lambda) %>% round(2),
  min = coda::HPDinterval(lambda)[, 1] %>% round(2),
  max = coda::HPDinterval(lambda)[, 2] %>% round(2))

lambda <- m2.2$VCV[,"animal"]/(m2.2$VCV[,"animal"] + m2.2$VCV[,"units"])
data.frame(
  lambda = mean(lambda) %>% round(2),
  min = coda::HPDinterval(lambda)[, 1] %>% round(2),
  max = coda::HPDinterval(lambda)[, 2] %>% round(2))

lambda <- m2.3$VCV[,"animal"]/(m2.3$VCV[,"animal"] + m2.3$VCV[,"units"])
data.frame(
  lambda = mean(lambda) %>% round(2),
  min = coda::HPDinterval(lambda)[, 1] %>% round(2),
  max = coda::HPDinterval(lambda)[, 2] %>% round(2))

lambda <- m2.4$VCV[,"animal"]/(m2.4$VCV[,"animal"] + m2.4$VCV[,"units"])
data.frame(
  lambda = mean(lambda) %>% round(2),
  min = coda::HPDinterval(lambda)[, 1] %>% round(2),
  max = coda::HPDinterval(lambda)[, 2] %>% round(2))

lambda <- m2.5$VCV[,"animal"]/(m2.5$VCV[,"animal"] + m2.5$VCV[,"units"])
data.frame(
  lambda = mean(lambda) %>% round(2),
  min = coda::HPDinterval(lambda)[, 1] %>% round(2),
  max = coda::HPDinterval(lambda)[, 2] %>% round(2))

lambda <- m2.6$VCV[,"animal"]/(m2.6$VCV[,"animal"] + m2.6$VCV[,"units"])
data.frame(
  lambda = mean(lambda) %>% round(2),
  min = coda::HPDinterval(lambda)[, 1] %>% round(2),
  max = coda::HPDinterval(lambda)[, 2] %>% round(2))

lambda <- m2.7$VCV[,"animal"]/(m2.7$VCV[,"animal"] + m2.7$VCV[,"units"])
data.frame(
  lambda = mean(lambda) %>% round(2),
  min = coda::HPDinterval(lambda)[, 1] %>% round(2),
  max = coda::HPDinterval(lambda)[, 2] %>% round(2))

lambda <- m2.8$VCV[,"animal"]/(m2.8$VCV[,"animal"] + m2.8 $VCV[,"units"])
data.frame(
  lambda = mean(lambda) %>% round(2),
  min = coda::HPDinterval(lambda)[, 1] %>% round(2),
  max = coda::HPDinterval(lambda)[, 2] %>% round(2))

### Random effects

summary(m1.A)$Gcovariances
summary(m1.B)$Gcovariances
summary(m1.C)$Gcovariances
summary(m1.D)$Gcovariances
summary(m2.1)$Gcovariances
summary(m2.2)$Gcovariances
summary(m2.3)$Gcovariances
summary(m2.4)$Gcovariances
summary(m2.5)$Gcovariances
summary(m2.6)$Gcovariances
summary(m2.7)$Gcovariances
summary(m2.8)$Gcovariances

