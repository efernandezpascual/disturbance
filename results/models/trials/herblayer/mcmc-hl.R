library(tidyverse); library(phangorn)

rm(list = ls())

merge(read.csv("data/disturbance-germination-herb.csv", fileEncoding = "latin1"),
      read.csv("data/disturbance-indicators-herb.csv", fileEncoding = "latin1"),
      by = "species") %>%
  mutate(animal = gsub(" ", "_", species)) %>%
  select(-family) -> germination

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
# nbur = 50
# nthi = 5

### Set priors for germination models (as many prior as random factors)

priors <- list(R = list(V = 1, nu = 50),
               G = list(G1 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
                        G2 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
                        G3 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500),
                        G4 = list(V = 1, nu = 1, alpha.mu = 0, alpha.V = 500)))

### Model

MCMCglmm::MCMCglmm(cbind(ngerminated, nseeds - ngerminated) ~
                     scale(temperature) +
                     scale(alternating) +
                     scale(light) +
                     scale(cs) +
                     scale(scarified) +
                     scale(temperature) * scale(severity) +
                     scale(temperature) * scale(frequency) +
                     scale(alternating) * scale(severity) +
                     scale(alternating) * scale(frequency) +
                     scale(light) * scale(severity) +
                     scale(light) * scale(frequency) +
                     scale(cs) * scale(severity) +
                     scale(cs) * scale(frequency) +
                     scale(scarified) * scale(severity) +
                     scale(scarified) * scale(frequency),
                   random = ~ animal +
                     species +
                     datasourceGUID +
                     seedlotGUID,
                   family = "multinomial2", pedigree = nnls_orig, prior = priors, data = germination,
                   nitt = nite, thin = nthi, burnin = nbur,
                   verbose = FALSE, saveX = FALSE, saveZ = FALSE, saveXL = FALSE, pr = FALSE, pl = FALSE) -> m1

save(m1, file = "results/models/mcmc-herb.Rdata")

load(file = "results/models/mcmc-herb.Rdata")

### Model diagnostics

# plot(m1)

### Model summary

summary(m1)

summary(m1)$solutions %>%
  write.csv("results/models/summary-herb.csv", row.names = FALSE, fileEncoding = "latin1")

### Phylo signal http://www.mpcm-evolution.com/practice/online-practical-material-chapter-11/chapter-11-1-simple-model-mcmcglmm

lambda <- m1$VCV[,"animal"]/(m1$VCV[,"animal"] + m1$VCV[,"units"])

data.frame(
  lambda = mean(lambda) %>% round(2),
  min = coda::HPDinterval(lambda)[, 1] %>% round(2),
  max = coda::HPDinterval(lambda)[, 2] %>% round(2))

data.frame(
  lambda = mean(lambda) %>% round(2),
  min = coda::HPDinterval(lambda)[, 1] %>% round(2),
  max = coda::HPDinterval(lambda)[, 2] %>% round(2)) %>%
  write.csv("results/models/phylo-signal-herb.csv", row.names = FALSE, fileEncoding = "latin1")

### Random effects

summary(m1)$Gcovariances

summary(m1)$Gcovariances %>%
  write.csv("results/models/random-effects-herb.csv", row.names = FALSE, fileEncoding = "latin1")

### Model figure

summary(m1)$solutions %>%
  data.frame %>%
  rownames_to_column(var = "Parameter") %>%
  mutate(Parameter = fct_recode(Parameter,
                                "Intercept:Intercept" = "(Intercept)",
                                "Temperature:(A) Germination cues,\nmain effects" = "scale(temperature)",
                                "Alternating temp.:(A) Germination cues,\nmain effects" = "scale(alternating)",
                                "Light:(A) Germination cues,\nmain effects" = "scale(light)",
                                "Cold stratification:(A) Germination cues,\nmain effects" = "scale(cs)",
                                "Scarification:(A) Germination cues,\nmain effects" = "scale(scarified)",
                                "Main effect:(C) Disturbance severity,\nmain effect & interactions" = "scale(severity)",
                                "Main effect:(B) Disturbance frequency,\nmain effect & interactions" = "scale(frequency)",
                                "Temperature:(C) Disturbance severity,\nmain effect & interactions" = "scale(temperature):scale(severity)",
                                "Temperature:(B) Disturbance frequency,\nmain effect & interactions" = "scale(temperature):scale(frequency)",
                                "Alternating temp.:(C) Disturbance severity,\nmain effect & interactions" = "scale(alternating):scale(severity)",
                                "Alternating temp.:(B) Disturbance frequency,\nmain effect & interactions" = "scale(alternating):scale(frequency)",
                                "Light:(C) Disturbance severity,\nmain effect & interactions" = "scale(light):scale(severity)",
                                "Light:(B) Disturbance frequency,\nmain effect & interactions" = "scale(light):scale(frequency)",
                                "Cold stratification:(C) Disturbance severity,\nmain effect & interactions" = "scale(cs):scale(severity)",
                                "Cold stratification:(B) Disturbance frequency,\nmain effect & interactions" = "scale(cs):scale(frequency)",
                                "Scarification:(C) Disturbance severity,\nmain effect & interactions" = "scale(scarified):scale(severity)",
                                "Scarification:(B) Disturbance frequency,\nmain effect & interactions" = "scale(scarified):scale(frequency)")) %>%
  separate(Parameter, into = c("Effect", "Group"), sep = ":") %>%
  mutate(Effect = fct_relevel(Effect, c("Light",
                                        "Alternating temp.",
                                        "Temperature",
                                        "Cold stratification",
                                        "Scarification")),
         Group = fct_relevel(Group, c("(A) Germination cues,\nmain effects",
                                      "(B) Disturbance frequency,\nmain effect & interactions",
                                      "(C) Disturbance severity,\nmain effect & interactions"))) %>%
  filter(! Group == "Intercept") %>%
  #filter(pMCMC <= 0.05) %>%
  ggplot(aes(y = Effect, x = post.mean,
             xmin = l.95..CI, xmax = u.95..CI,
             color = Effect)) +
  facet_wrap(~ Group, scales = "free_x", nrow = 1) +
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

ggsave(fig, file = "results/figures/mcmc-herb.png", bg = "white",
       path = NULL, scale = 1, width = 180, height = 70, units = "mm", dpi = 600)

quit()
n

