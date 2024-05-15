library(tidyverse)

# Frequency ALL

read.csv("data/disturbance-germination.csv", fileEncoding = "latin1") %>%
  merge(read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1")) %>%
  mutate(F = ifelse(frequency >= median(frequency), "High", "Low")) %>%
  mutate(Sv = ifelse(severity >= median(frequency), "High", "Low")) %>%
  group_by(F) %>%
  summarise(N = sum(nseeds), G = sum(ngerminated)) %>%
  group_by(F)  %>%
  summarise(p = G / N)

# Frequency HERB LAYER

read.csv("data/disturbance-germination-herb.csv", fileEncoding = "latin1") %>%
  merge(read.csv("data/disturbance-indicators-herb.csv", fileEncoding = "latin1")) %>%
  mutate(F = ifelse(frequency >= median(frequency), "High", "Low")) %>%
  mutate(Sv = ifelse(severity >= median(frequency), "High", "Low")) %>%
  group_by(F) %>%
  summarise(N = sum(nseeds), G = sum(ngerminated)) %>%
  group_by(F)  %>%
  summarise(p = G / N)

# Severity ALL

read.csv("data/disturbance-germination.csv", fileEncoding = "latin1") %>%
  merge(read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1")) %>%
  mutate(F = ifelse(frequency >= median(frequency), "High", "Low")) %>%
  mutate(Sv = ifelse(severity >= median(severity), "High", "Low")) %>%
  group_by(Sv) %>%
  summarise(N = sum(nseeds), G = sum(ngerminated)) %>%
  group_by(Sv)  %>%
  summarise(p = G / N)

# Severity HERB LAYER

read.csv("data/disturbance-germination-herb.csv", fileEncoding = "latin1") %>%
  merge(read.csv("data/disturbance-indicators-herb.csv", fileEncoding = "latin1")) %>%
  mutate(F = ifelse(frequency >= median(frequency), "High", "Low")) %>%
  mutate(Sv = ifelse(severity >= median(severity), "High", "Low")) %>%
  group_by(Sv) %>%
  summarise(N = sum(nseeds), G = sum(ngerminated)) %>%
  group_by(Sv)  %>%
  summarise(p = G / N)

# Temperature Tichy

openxlsx::read.xlsx("data/indicators/Ellenberg_disturbance.xlsx") %>%
  select(`Species-levelName`, Temperature, Moisture) %>%
  rename(species = `Species-levelName`) %>%
  merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1")) %>%
  mutate(Temperature = as.numeric(Temperature)) %>%
  filter(! is.na(Temperature)) %>%
  mutate(F = ifelse(Temperature >= median(Temperature), "Low", "High")) %>%
  group_by(F) %>%
  summarise(N = sum(nseeds), G = sum(ngerminated)) %>%
  group_by(F)  %>%
  summarise(p = G / N)

# Moisture Tichy

openxlsx::read.xlsx("data/indicators/Ellenberg_disturbance.xlsx") %>%
  select(`Species-levelName`, Temperature, Moisture) %>%
  rename(species = `Species-levelName`) %>%
  merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1")) %>%
  mutate(Moisture = as.numeric(Moisture)) %>%
  filter(! is.na(Moisture)) %>%
  mutate(F = ifelse(Moisture >= median(Moisture), "Low", "High")) %>%
  group_by(F) %>%
  summarise(N = sum(nseeds), G = sum(ngerminated)) %>%
  group_by(F)  %>%
  summarise(p = G / N)

# Temperature Dengler

openxlsx::read.xlsx("data/indicators/vegetation_classification_and_survey-004-007-g008.xlsx", sheet = 2) %>%
  select(`TaxonConcept`, `EIVEres-T`, `EIVEres-M`) %>%
  rename(species = `TaxonConcept`, Temperature = `EIVEres-T`, Moisture = `EIVEres-M`) %>%
  merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1")) %>%
  mutate(Temperature = as.numeric(Temperature)) %>%
  filter(! is.na(Temperature)) %>%
  mutate(F = ifelse(Temperature >= median(Temperature), "Low", "High")) %>%
  group_by(F) %>%
  summarise(N = sum(nseeds), G = sum(ngerminated)) %>%
  group_by(F)  %>%
  summarise(p = G / N)

# Moisture Dengler

openxlsx::read.xlsx("data/indicators/vegetation_classification_and_survey-004-007-g008.xlsx", sheet = 2) %>%
  select(`TaxonConcept`, `EIVEres-T`, `EIVEres-M`) %>%
  rename(species = `TaxonConcept`, Temperature = `EIVEres-T`, Moisture = `EIVEres-M`) %>%
  merge(read.csv("data/disturbance-germination.csv", fileEncoding = "latin1")) %>%
  mutate(Moisture = as.numeric(Moisture)) %>%
  filter(! is.na(Moisture)) %>%
  mutate(F = ifelse(Moisture >= median(Moisture), "Low", "High")) %>%
  group_by(F) %>%
  summarise(N = sum(nseeds), G = sum(ngerminated)) %>%
  group_by(F)  %>%
  summarise(p = G / N)


# PCA

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
  na.omit %>%
  select(species, Temperature, Moisture, Frequency, Severity) -> indicators

indicators %>%
  group_by %>%
  select(-species) %>%
  FactoMineR::PCA() -> pca

pca$var$contrib
