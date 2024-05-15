library(tidyverse); library(phangorn)

### Prepare indicators

openxlsx::read.xlsx("data/indicators/Ellenberg_disturbance.xlsx") %>%
  select(`Species-levelName`, 
         Temperature, Moisture, 
         Disturbance.Frequency.herblayer, 
         Disturbance.Severity.herblayer) %>%
  rename(species = `Species-levelName`,
         Severity = Disturbance.Severity.herblayer,
         Frequency = Disturbance.Frequency.herblayer) %>%
  gather(Trait, Value, Temperature:Severity) %>%
  mutate(Value = as.numeric(Value)) %>%
  na.omit %>%
  group_by(species, Trait) %>%
  summarise(Value = mean(Value)) %>%
  spread(Trait, Value) %>%
  #na.omit %>%
  select(species, Temperature, Moisture, Frequency, Severity) %>%
  group_by() %>%
  mutate(T = ifelse(Temperature >= median(Temperature, na.rm = TRUE), "Low", "High")) %>%
  mutate(W = ifelse(Moisture >= median(Moisture, na.rm = TRUE), "Low", "High")) %>%
  mutate(F = ifelse(Frequency >= median(Frequency, na.rm = TRUE), "High", "Low")) %>%
  mutate(S = ifelse(Severity >= median(Severity, na.rm = TRUE), "High", "Low")) -> indicators

### Calculate binomial CIs

bi <- function(x)
{
  bci <- binom::binom.confint(x$ngerminated, x$nseeds, method = "wilson")
  cbind(x, germination = bci[4:6])
}

indicators %>%
  merge(read.csv("data/disturbance-germination-herb.csv", fileEncoding = "latin1")) %>%
  group_by(species) %>%
  select(nseeds, ngerminated, T:S) %>%
  gather(Trait, Value, T:S) %>%
  na.omit %>%
  group_by(Trait, Value) %>%
  summarise(ngerminated = sum(ngerminated), nseeds = sum(nseeds)) %>%
  do(bi(.)) -> cis

### Binomial indicator figure

cis %>%
  group_by() %>%
  mutate(Value = fct_relevel(Value, "Low", "High")) %>%
  mutate(Trait = fct_relevel(Trait, "T", "W", "F", "S")) %>%
  mutate(Trait = fct_recode(Trait, 
                            "(A) Temperature stress" = "T",
                            "(B) Water stress" = "W",
                            "(C) Disturbance frequency" = "F",
                            "(D) Disturbance severity" = "S")) %>%
  ggplot(aes(Value, germination.mean, fill = Trait, alpha = Value)) +
  geom_bar(stat = "identity", position = "dodge", color = "black") +
  facet_wrap(~ Trait, ncol = 4) +
  scale_alpha_manual(name = "Stress/disturbance level",values = c(.5, 1), guide = "none") +
  geom_errorbar(aes(ymin = germination.lower, ymax = germination.upper), width = .2,
                position = position_dodge(.9)) +
  scale_fill_manual(name = "Vegetation class",
                    values = c(
                               "limegreen",
                               "skyblue",
                               "darkmagenta",
                               "gold")) +
  ggthemes::theme_tufte() +
  xlab("Stress/disturbance level") + ylab("Final germination proportion") +
  coord_cartesian(ylim = c(0, .8)) +
  theme(text = element_text(family = "sans"),
        strip.background = element_blank(),
        legend.position = "none", 
        #legend.direction = "vertical",
        legend.title = element_text(size = 10),
        legend.spacing.x = unit(0, "mm"),
        legend.spacing.y = unit(0, "mm"),
        legend.text = element_text(size = 10, face = "italic"), 
        panel.background = element_rect(color = "black", fill = NULL),
        strip.text = element_text(size = 9.8, hjust = 0, margin = margin(l = 0, b = 4)),
        #strip.text = element_blank(),
        plot.title = element_text(size = 10),
        axis.title = element_text(size = 10),
        axis.text.x = element_text(size = 10, color = "black"),
        axis.text.y = element_text(size = 10, color = "black", face = "italic"),
        plot.margin = unit(c(0,0,0,0), "cm")) +
  geom_hline(yintercept = 0) -> f1; f1

ggsave(f1, file = "results/figures/2-groups.png", bg = "white", 
       path = NULL, scale = 1, width = 180, height = 70, units = "mm", dpi = 600)

### Germination dataset for models

merge(read.csv("data/disturbance-germination-herb.csv", fileEncoding = "latin1"),
     indicators,
      by = "species") %>%
  mutate(animal = gsub(" ", "_", species)) -> germination

### Read tree

phangorn::nnls.tree(cophenetic(ape::read.tree("results/phylo-tree/disturbance.tre")),
                    ape::read.tree("results/phylo-tree/disturbance.tre"), method = "ultrametric") ->
  nnls_orig

nnls_orig$node.label <- NULL

### Set number of iterations

nite = 100000
nbur = 20000
nthi = 100

# nite = 100
# nbur = 50
# nthi = 5

### Set priors for germination models (as many prior as random factors)

priors <- list(R = list(V = 1, nu = 50),
               G = list(G1 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
                        G2 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
                        G3 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
                        G4 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500)))

### Objective 1 model T

germination %>%
  mutate(level = T) %>%
  select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated, level) %>%
  na.omit -> germinationDF

MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ level,
                   random = ~ animal +
                     species +
                     datasourceGUID +
                     seedlotGUID,
                   family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germinationDF,
                   nitt = nite, thin = nthi, burnin = nbur,
                   verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1.T

save(m1.T, file = "results/models/obj1/m1.T.Rdata")
load(file = "results/models/obj1/m1.T.Rdata")
# plot(m1.T) # Model diagnostics
summary(m1.T) # Model summary

### Objective 1 model W

germination %>%
  mutate(level = W) %>%
  select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated, level) %>%
  na.omit -> germinationDF

MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ level,
                   random = ~ animal +
                     species +
                     datasourceGUID +
                     seedlotGUID,
                   family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germinationDF,
                   nitt = nite, thin = nthi, burnin = nbur,
                   verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1.W

save(m1.W, file = "results/models/obj1/m1.W.Rdata")
load(file = "results/models/obj1/m1.W.Rdata")
# plot(m1.W) # Model diagnostics
summary(m1.W) # Model summary

### Objective 1 model F

germination %>%
  mutate(level = F) %>%
  select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated, level) %>%
  na.omit -> germinationDF

MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ level,
                   random = ~ animal +
                     species +
                     datasourceGUID +
                     seedlotGUID,
                   family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germinationDF,
                   nitt = nite, thin = nthi, burnin = nbur,
                   verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1.F

save(m1.F, file = "results/models/obj1/m1.F.Rdata")
load(file = "results/models/obj1/m1.F.Rdata")
# plot(m1.F) # Model diagnostics
summary(m1.F) # Model summary

### Objective 1 model S

germination %>%
  mutate(level = S) %>%
  select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated, level) %>%
  na.omit -> germinationDF

MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ level,
                   random = ~ animal +
                     species +
                     datasourceGUID +
                     seedlotGUID,
                   family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germinationDF,
                   nitt = nite, thin = nthi, burnin = nbur,
                   verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1.S

save(m1.S, file = "results/models/obj1/m1.S.Rdata")
load(file = "results/models/obj1/m1.S.Rdata")
# plot(m1.S) # Model diagnostics
summary(m1.S) # Model summary

#################################

### Objective 2 model T low

germination %>%
  mutate(level = T) %>%
  filter(level == "Low") %>%
  select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated, level,
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
                   verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m2.TL

save(m2.TL, file = "results/models/obj2/m2.TL.Rdata")
load(file = "results/models/obj2/m2.TL.Rdata")
# plot(m2.TL) # Model diagnostics
summary(m2.TL) # Model summary

### Objective 2 model T high

germination %>%
  mutate(level = T) %>%
  filter(level == "High") %>%
  select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated, level,
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
                   verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m2.TH

save(m2.TH, file = "results/models/obj2/m2.TH.Rdata")
load(file = "results/models/obj2/m2.TH.Rdata")
# plot(m2.TH) # Model diagnostics
summary(m2.TH) # Model summary

### Objective 2 model W low

germination %>%
  mutate(level = W) %>%
  filter(level == "Low") %>%
  select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated, level,
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
                   verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m2.WL

save(m2.WL, file = "results/models/obj2/m2.WL.Rdata")
load(file = "results/models/obj2/m2.WL.Rdata")
# plot(m2.WL) # Model diagnostics
summary(m2.WL) # Model summary

### Objective 2 model W high

germination %>%
  mutate(level = W) %>%
  filter(level == "High") %>%
  select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated, level,
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
                   verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m2.WH

save(m2.WH, file = "results/models/obj2/m2.WH.Rdata")
load(file = "results/models/obj2/m2.WH.Rdata")
# plot(m2.WH) # Model diagnostics
summary(m2.WH) # Model summary

### Objective 2 model F low

germination %>%
  mutate(level = F) %>%
  filter(level == "Low") %>%
  select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated, level,
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
                   verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m2.FL

save(m2.FL, file = "results/models/obj2/m2.FL.Rdata")
load(file = "results/models/obj2/m2.FL.Rdata")
# plot(m2.FL) # Model diagnostics
summary(m2.FL) # Model summary

### Objective 2 model F high

germination %>%
  mutate(level = F) %>%
  filter(level == "High") %>%
  select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated, level,
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
                   verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m2.FH

save(m2.FH, file = "results/models/obj2/m2.FH.Rdata")
load(file = "results/models/obj2/m2.FH.Rdata")
# plot(m2.FH) # Model diagnostics
summary(m2.FH) # Model summary

### Objective 2 model S low

germination %>%
  mutate(level = S) %>%
  filter(level == "Low") %>%
  select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated, level,
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
                   verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m2.SL

save(m2.SL, file = "results/models/obj2/m2.SL.Rdata")
load(file = "results/models/obj2/m2.SL.Rdata")
# plot(m2.SL) # Model diagnostics
summary(m2.SL) # Model summary

### Objective 2 model S high

germination %>%
  mutate(level = S) %>%
  filter(level == "High") %>%
  select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated, level,
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
                   verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m2.SH

save(m2.SH, file = "results/models/obj2/m2.SH.Rdata")
load(file = "results/models/obj2/m2.SH.Rdata")
# plot(m2.SH) # Model diagnostics
summary(m2.SH) # Model summary

### Summary table

rbind(
summary(m2.TL)$solutions %>%
  data.frame %>%
  rownames_to_column(var = "Effect") %>%
  mutate(Model = "m2.TL"),

summary(m2.TH)$solutions %>%
  data.frame %>%
  rownames_to_column(var = "Effect") %>%
  mutate(Model = "m2.TH"),

summary(m2.WL)$solutions %>%
  data.frame %>%
  rownames_to_column(var = "Effect") %>%
  mutate(Model = "m2.WL"),

summary(m2.WH)$solutions %>%
  data.frame %>%
  rownames_to_column(var = "Effect") %>%
  mutate(Model = "m2.WH"),

summary(m2.FL)$solutions %>%
  data.frame %>%
  rownames_to_column(var = "Effect") %>%
  mutate(Model = "m2.FL"),

summary(m2.FH)$solutions %>%
  data.frame %>%
  rownames_to_column(var = "Effect") %>%
  mutate(Model = "m2.FH"),

summary(m2.SL)$solutions %>%
  data.frame %>%
  rownames_to_column(var = "Effect") %>%
  mutate(Model = "m2.SL"),

summary(m2.SH)$solutions %>%
  data.frame %>%
  rownames_to_column(var = "Effect") %>%
  mutate(Model = "m2.SH")) %>%
  mutate(Effect = fct_recode(Effect,
                             "Intercept" = "(Intercept)",
                             "Germination temperature" = "scale(temperature)",
                             "Alternating temperature" = "scale(alternating)",
                             "Light" = "scale(light)",
                             "Cold stratification" = "scale(cs)",
                             "Scarification" = "scale(scarified)"),
         Effect = fct_relevel(Effect, c("Light",
                                        "Germination temperature",
                                        "Alternating temperature",
                                        "Cold stratification",
                                        "Scarification"))) %>%
  mutate(
         Model = fct_relevel(Model, c("m2.TL",
                                        "m2.TH",
                                        "m2.WL",
                                        "m2.WH",
                                      "m2.FL",
                                        "m2.FH",
                                      "m2.SL",
                                      "m2.SH")),
         Model = fct_recode(Model,
                             "Low temperature\nstress" = "m2.TL",
                            "High temperature\nstress" = "m2.TH",
                            "Low water\nstress" = "m2.WL",
                            "High water\nstress" = "m2.WH",
                            "Low frequency\ndisturbance" = "m2.FL",
                            "High frequency\ndisturbance" = "m2.FH",
                            "Low severity\ndisturbance" = "m2.SL",
                            "High severity\ndisturbance" = "m2.SH")) %>%
  filter(! Effect == "Intercept") %>%
  #filter(pMCMC <= 0.05) %>%
  ggplot(aes(y = Effect, x = post.mean,
             xmin = l.95..CI, xmax = u.95..CI,
             color = Effect)) +
  facet_wrap(~ Model, scales = "free_x", nrow = 2) +
  geom_point(size = 2) +
  labs(x = "Effect size") +
  geom_errorbarh(height = .3) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  scale_color_manual(values = c("gold",
                                "#B3EE3A",
                                "#FFA500",
                                "#5CACEE",
                                "#40E0D0",
                                "#551A8B")) +
  ggthemes::theme_tufte() +
  theme(text = element_text(family = "sans", size = 12),
        strip.background = element_blank(),
        legend.position = "none",
        panel.background = element_rect(color = "black", fill = NULL),
        axis.title.x = element_text(size = 12),
        axis.title.y = element_blank(),
        axis.text.x = element_text(size = 7.5, color = "black"),
        axis.text.y = element_text(size = 12,
                                   color = c("gold",
                                             "#B3EE3A",
                                             "#FFA500",
                                             "#5CACEE",
                                             "#40E0D0",
                                             "#551A8B")),
        strip.text.x = element_text(size = 10, hjust = 0, vjust = 1, margin = margin(l = 0, b = 4))) ->
  fig; fig

## Export

ggsave(fig, file = "results/figures/mcmc-2group.png", bg = "white",
       path = NULL, scale = 1, width = 180, height = 120, units = "mm", dpi = 600)

