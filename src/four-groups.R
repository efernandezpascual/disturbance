library(tidyverse); library(phangorn)

### Prepare indicators

read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1") %>%
  select(species, Temperature, Moisture, Frequency, Severity) %>%
  mutate(T = ifelse(Temperature >= median(Temperature, na.rm = TRUE), 0, 1)) %>%
  mutate(W = ifelse(Moisture >= median(Moisture, na.rm = TRUE), 0, 1)) %>%
  mutate(F = ifelse(Frequency >= median(Frequency, na.rm = TRUE), 1, 0)) %>%
  mutate(S = ifelse(Severity >= median(Severity, na.rm = TRUE), 1, 0)) %>%
  mutate(Stress = T + W, Disturbance = F + S) %>%
  mutate(Group = ifelse(Stress == 0 & Disturbance == 0, "Low stress - Low disturbance", NA)) %>%
  mutate(Group = ifelse(Stress == 0 & Disturbance != 0, "Low stress - High disturbance", Group)) %>%
  mutate(Group = ifelse(Stress != 0 & Disturbance == 0, "High stress - Low disturbance", Group)) %>%
  mutate(Group = ifelse(Stress != 0 & Disturbance != 0, "High stress - High disturbance", Group)) -> indicators

indicators %>%
  group_by(Group) %>%
  tally()

### PCA of the indicators

indicators %>%
  # merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1")) %>%
  select(Temperature:Severity) %>%
  FactoMineR::PCA() -> pca1

indicators %>%
  # merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1")) %>%
  select(Group) %>%
  cbind(pca1$ind$coord %>%
          data.frame) %>%
  mutate(Group = fct_relevel(Group, "Low stress - Low disturbance", "High stress - Low disturbance",
                             "Low stress - High disturbance", "High stress - High disturbance")) ->
  inds

pca1$var$coord %>%
  data.frame %>%
  rownames_to_column(var = "Variable") -> 
  vars

### Plot

ggplot(inds, aes(Dim.1, Dim.2)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey60") +
  scale_color_manual(name = NULL,
                     values = c(
                       "limegreen",
                       "skyblue",
                       "darkmagenta",
                       "gold")) +
  #coord_fixed() +
  geom_segment(data = vars, aes(x = 0, y = 0, xend = Dim.1*3.8, yend = Dim.2*3.8), arrow = arrow(length = unit(1/2, "picas")), color = "black") +
  geom_point(aes(color = Group), 
             show.legend = TRUE, size = 1, alpha = .6) +
  geom_label(data = vars, aes(x = Dim.1*3.8, y = Dim.2*3.8, label = Variable),  show.legend = FALSE, size = 3) +
  ggthemes::theme_tufte() +
  xlab("PCA1") + ylab("PCA2") +
  scale_y_continuous(labels = scales::label_number(accuracy = 0.1)) +
  theme(text = element_text(family = "sans"),
        strip.background = element_blank(),
        legend.position = "right", 
        #legend.direction = "vertical",
        legend.title = element_text(size = 10),
        legend.margin = margin(0, 0, 0, 0),
        legend.spacing.x = unit(0, "mm"),
        legend.spacing.y = unit(0, "mm"),
        legend.text = element_text(size = 10), 
        panel.background = element_rect(color = "black", fill = NULL),
        # strip.text = element_text(size = 12, hjust = 0, margin = margin(l = 0, b = 4)),
        strip.text = element_blank(),
        panel.spacing = unit(0.05, "lines"),
        plot.title = element_text(size = 12),
        axis.title = element_text(size = 10),
        axis.text.x = element_text(size = 10, color = "black"),
        axis.text.y = element_text(size = 10, color = "black"),
        plot.margin = unit(c(0,0,0,0), "cm")) +
  guides(colour = guide_legend(override.aes = list(alpha = 1, size = 4))) -> 
  Fig3A; Fig3A

### Merge

ggsave(Fig3A, file = "results/figures/F7 - pca.png", bg = "white", 
       path = NULL, scale = 1, width = 179, height = 95, units = "mm", dpi = 600)

### Calculate binomial CIs

bi <- function(x)
{
  bci <- binom::binom.confint(x$ngerminated, x$nseeds, method = "wilson")
  cbind(x, germination = bci[4:6])
}

indicators %>%
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

indicators %>%
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
  geom_jitter(data = pts, width = .1, aes(color = Group), size = 1, alpha = .3) +
  geom_bar(stat = "identity", position = "dodge", color = "black", alpha = .5) +
  geom_errorbar(aes(ymin = germination.lower, ymax = germination.upper), width = .1,
                position = position_dodge(.9)) +
  scale_fill_manual(name = "Vegetation class",
                    values = c(
                      "limegreen",
                      "skyblue",
                      "darkmagenta",
                      "gold")) +
  scale_color_manual(name = "Vegetation class",
                    values = c(
                      "limegreen",
                      "skyblue",
                      "darkmagenta",
                      "gold")) +
  ggthemes::theme_tufte() +
  xlab("Stress/disturbance level") + ylab("Final germination proportion") +
  coord_cartesian(ylim = c(0, 1)) +
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
        axis.title.x = element_blank(),
        axis.text = element_text(size = 10, color = "black"),
        plot.margin = unit(c(0,0,0,0), "cm")) +
  geom_hline(yintercept = 0) -> f1; f1

ggsave(f1, file = "results/figures/2-groups.png", bg = "white", 
       path = NULL, scale = 1, width = 180, height = 70, units = "mm", dpi = 600)

### Germination dataset for models

merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1"),
      indicators,
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

### Objective 1

germination %>%
  separate(Group, into = c("Stress", "Disturbance"), sep = " - ") %>%
  mutate(Stress = fct_relevel(Stress, "Low stress", "High stress")) %>%
  mutate(Disturbance = fct_relevel(Disturbance, "Low disturbance", "High disturbance")) %>%
  select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated, Stress, Disturbance) %>%
  na.omit -> germinationDF

# germination %>%
#   mutate(Group = fct_relevel(Group, "Low stress - Low disturbance", "High stress - Low disturbance",
#                              "Low stress - High disturbance", "High stress - High disturbance")) %>%
#   select(animal, species, datasourceGUID, seedlotGUID, nseeds, ngerminated, Group) %>%
#   na.omit -> germinationDF

MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~ Stress + Disturbance,
                   random = ~ animal +
                     species +
                     datasourceGUID +
                     seedlotGUID,
                   family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germinationDF,
                   nitt = nite, thin = nthi, burnin = nbur,
                   verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1

save(m1, file = "results/models/obj1/m1.Rdata")
load(file = "results/models/obj1/m1.Rdata")
# plot(m1) # Model diagnostics
summary(m1) # Model summary

### Objective 2 model LL

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
                   verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m2.LL

save(m2.LL, file = "results/models/obj2/m2.LL.Rdata")
load(file = "results/models/obj2/m2.LL.Rdata")
# plot(m2.LL) # Model diagnostics
summary(m2.LL) # Model summary

### Objective 2 model LH

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
                   verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m2.LH

save(m2.LH, file = "results/models/obj2/m2.LH.Rdata")
load(file = "results/models/obj2/m2.LH.Rdata")
# plot(m2.LH) # Model diagnostics
summary(m2.LH) # Model summary

### Objective 2 model HL

germination %>%
  filter(Group == "High stress - Low disturbance") %>%
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
                   verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m2.HL

save(m2.HL, file = "results/models/obj2/m2.HL.Rdata")
load(file = "results/models/obj2/m2.HL.Rdata")
# plot(m2.HL) # Model diagnostics
summary(m2.HL) # Model summary

### Objective 2 model HH

germination %>%
  filter(Group == "High stress - High disturbance") %>%
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
                   verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m2.HH

save(m2.HH, file = "results/models/obj2/m2.HH.Rdata")
load(file = "results/models/obj2/m2.HH.Rdata")
# plot(m2.HH) # Model diagnostics
summary(m2.HH) # Model summary

### Summary table

rbind(
  summary(m2.LL)$solutions %>%
    data.frame %>%
    rownames_to_column(var = "Effect") %>%
    mutate(Model = "m2.LL"),
  
  summary(m2.LH)$solutions %>%
    data.frame %>%
    rownames_to_column(var = "Effect") %>%
    mutate(Model = "m2.LH"),
  
  summary(m2.HL)$solutions %>%
    data.frame %>%
    rownames_to_column(var = "Effect") %>%
    mutate(Model = "m2.HL"),
  
  summary(m2.HH)$solutions %>%
    data.frame %>%
    rownames_to_column(var = "Effect") %>%
    mutate(Model = "m2.HH")) %>%
  group_by %>%
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
    Model = fct_relevel(Model, c("m2.LL",
                                 "m2.HL",
                                 "m2.LH",
                                 "m2.HH")),
    Model = fct_recode(Model,
                       "Low stress\nLow disturbance" = "m2.LL",
                       "High stress\nLow disturbance" = "m2.HL",
                       "Low stress\nHigh disturbance" = "m2.LH",
                       "High stress\nHigh disturbance" = "m2.HH")) %>%
  filter(! Effect == "Intercept") %>%
  #filter(pMCMC <= 0.05) %>%
  ggplot(aes(y = Effect, x = post.mean,
             xmin = l.95..CI, xmax = u.95..CI,
             color = Effect)) +
  facet_wrap(~ Model, nrow = 1) +
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
       path = NULL, scale = 1, width = 180, height = 80, units = "mm", dpi = 600)
