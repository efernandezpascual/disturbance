library(tidyverse); library(phangorn)

# ### Germination dataset for models
# 
# read.csv("data/disturbance-indicators_with_seed.mass.csv", fileEncoding = "latin1") %>%
#   select(species, mass) -> mass
# 
# merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1"),
#       read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1"),
#       by = "species") %>%
#   merge(mass) %>%
#   mutate(animal = gsub(" ", "_", species)) -> germination
# 
# library(tidyverse)
# 
# ### Violin plot
# 
# read.csv("data/disturbance-indicators_with_seed.mass.csv", fileEncoding = "latin1") %>%
#   gather(Trait, Value, mass) %>%
#   na.omit %>%
#   mutate(Trait = fct_relevel(Trait, c("Temperature", "Moisture", "Frequency", "Severity"))) %>%
#   mutate(Trait = fct_recode(Trait, 
#                             "Disturbance frequency" = "Frequency",
#                             "Disturbance severity" = "Severity")) %>%
#   mutate(Group = fct_relevel(Group, "Low stress - Low disturbance", "High stress - Low disturbance",
#                              "Low stress - High disturbance", "High stress - High disturbance")) %>%
#   mutate(Group = fct_recode(Group, 
#                             "Low stress\nLow disturbance" = "Low stress - Low disturbance",
#                             "High stress\nLow disturbance" = "High stress - Low disturbance",
#                             "Low stress\nHigh disturbance" = "Low stress - High disturbance",
#                             "High stress\nHigh disturbance" = "High stress - High disturbance")) %>%
#   ggplot(aes(Trait, log(Value), color = Group, fill = Group)) + 
#   geom_violin(alpha = .5, draw_quantiles = c(0.25, 0.5, 0.75)) +
#   facet_wrap(~ Trait, scale = "free", nrow = 1) +
#   scale_y_continuous(labels = scales::number_format(accuracy = .1)) +
#   ylab("Indicator value") +
#   ggthemes::theme_tufte() +
#   theme(text = element_text(family = "sans"),
#         strip.background = element_blank(),
#         legend.position = "top", 
#         #legend.direction = "vertical",
#         legend.title = element_blank(),
#         legend.margin=margin(0,0,0,0),
#         legend.box.margin=margin(-1,-1,-4,-1),
#         legend.text = element_text(size = 10), 
#         panel.background = element_rect(color = "black", fill = NULL),
#         #strip.text = element_text(size = 9.8, hjust = 0, margin = margin(l = 0, b = 4)),
#         strip.text = element_blank(),
#         plot.title = element_text(size = 10),
#         axis.title = element_text(size = 10),
#         axis.title.x = element_blank(),
#         axis.text = element_text(size = 10, color = "black"),
#         plot.margin = unit(c(0.1,0.1,0.1,0.1), "cm")) +
#   scale_color_manual(values = c( "limegreen",
#                                  "skyblue",
#                                  "darkmagenta",
#                                  "gold")) +
#   scale_fill_manual(values = c( "limegreen",
#                                 "skyblue",
#                                 "darkmagenta",
#                                 "gold")) -> f1;f1
# 
# ggsave(f1, file = "results/supplementary/figS2.png", bg = "white",
#        path = NULL, scale = 1, width = 180, height = 150, units = "mm", dpi = 600)
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
# 
# nite = 1000000
# nbur = 200000
# nthi = 1000
# 
# nite = 500000
# nbur = 50000
# nthi = 50
# 
# # nite = 100
# # nbur = 10
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
# ### Objective 1 (compare four groups)
# 
# germination %>%
#   separate(Group, into = c("Stress", "Disturbance"), sep = " - ") %>%
#   mutate(Stress = fct_relevel(Stress, "Low stress", "High stress")) %>%
#   mutate(Disturbance = fct_relevel(Disturbance, "Low disturbance", "High disturbance")) %>%
#   select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated, Stress, Disturbance, mass) %>%
#   na.omit -> germinationDF
# 
# MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ Stress + Disturbance + scale(mass),
#                    random = ~ animal +
#                      species +
#                      datasourceGUID +
#                      seedlotGUID,
#                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germinationDF,
#                    nitt = nite, thin = nthi, burnin = nbur,
#                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1
# 
# save(m1, file = "results/models/seedmass/m1.Rdata")
# 
# ### Objective 1 (compare four groups)
# 
# germination %>%
#   mutate(Group = fct_relevel(Group, "Low stress - Low disturbance")) %>%
#   select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated, Group, mass) %>%
#   na.omit -> germinationDF
# 
# MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ Group + scale(mass),
#                    random = ~ animal +
#                      species +
#                      datasourceGUID +
#                      seedlotGUID,
#                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germinationDF,
#                    nitt = nite, thin = nthi, burnin = nbur,
#                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1B
# 
# save(m1B, file = "results/models/seedmass/m1B.Rdata")
# 
# ### Objective 2 model LL (germination drivers in low stress - low disturbance group)
# 
# germination %>%
#   filter(Group == "Low stress - Low disturbance") %>%
#   select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated,
#          temperature, alternating, light, cs, scarified, mass) %>%
#   na.omit -> germinationDF
# 
# MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~
#                      scale(temperature) +
#                      scale(alternating) +
#                      scale(light) +
#                      scale(cs) +
#                      scale(scarified) +
#                      scale(mass),
#                    random = ~ animal +
#                      species +
#                      datasourceGUID +
#                      seedlotGUID,
#                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germinationDF,
#                    nitt = nite, thin = nthi, burnin = nbur,
#                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m2.LL
# 
# save(m2.LL, file = "results/models/seedmass/m2.LL.Rdata")
# 
# ### Objective 2 model LH (germination drivers in low stress - high disturbance group)
# 
# germination %>%
#   filter(Group == "Low stress - High disturbance") %>%
#   select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated,
#          temperature, alternating, light, cs, scarified, mass) %>%
#   na.omit -> germinationDF
# 
# MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~
#                      scale(temperature) +
#                      scale(alternating) +
#                      scale(light) +
#                      scale(cs) +
#                      scale(scarified) +
#                      scale(mass),
#                    random = ~ animal +
#                      species +
#                      datasourceGUID +
#                      seedlotGUID,
#                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germinationDF,
#                    nitt = nite, thin = nthi, burnin = nbur,
#                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m2.LH
# 
# save(m2.LH, file = "results/models/seedmass/m2.LH.Rdata")
# 
# ### Objective 2 model HL (germination drivers in high stress - low disturbance group)
# 
# germination %>%
#   filter(Group == "High stress - Low disturbance") %>%
#   select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated,
#          temperature, alternating, light, cs, scarified, mass) %>%
#   na.omit -> germinationDF
# 
# MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~
#                      scale(temperature) +
#                      scale(alternating) +
#                      scale(light) +
#                      scale(cs) +
#                      scale(scarified) +
#                      scale(mass),
#                    random = ~ animal +
#                      species +
#                      datasourceGUID +
#                      seedlotGUID,
#                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germinationDF,
#                    nitt = nite, thin = nthi, burnin = nbur,
#                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m2.HL
# 
# save(m2.HL, file = "results/models/seedmass/m2.HL.Rdata")
# 
# ### Objective 2 model HH (germination drivers in high stress - high disturbance group)
# 
# germination %>%
#   filter(Group == "High stress - High disturbance") %>%
#   select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated,
#          temperature, alternating, light, cs, scarified, mass) %>%
#   na.omit -> germinationDF
# 
# MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~
#                      scale(temperature) +
#                      scale(alternating) +
#                      scale(light) +
#                      scale(cs) +
#                      scale(scarified) +
#                      scale(mass),
#                    random = ~ animal +
#                      species +
#                      datasourceGUID +
#                      seedlotGUID,
#                    family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germinationDF,
#                    nitt = nite, thin = nthi, burnin = nbur,
#                    verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m2.HH
# 
# save(m2.HH, file = "results/models/seedmass/m2.HH.Rdata")


load(file = "results/models/seedmass/m1B.Rdata")
load(file = "results/models/seedmass/m1.Rdata")
load(file = "results/models/seedmass/m2.LL.Rdata")
load(file = "results/models/seedmass/m2.LH.Rdata")
load(file = "results/models/seedmass/m2.HL.Rdata")
load(file = "results/models/seedmass/m2.HH.Rdata")


summary(m1)
summary(m1B)
summary(m2.LL)
summary(m2.LH)
summary(m2.HL)
summary(m2.HH)

q(save="no")
