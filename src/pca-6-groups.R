library(tidyverse)

### Violin plot

read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1") %>%
  select(Temperature, Moisture, Frequency, Severity) %>%
  FactoMineR::PCA() -> pca1

pca1$ind$coord %>%
  data.frame() %>%
  select(Dim.1, Dim.2) %>%
  cbind(read.csv("data/disturbance-indicators.csv", fileEncoding = "latin1")) %>%
  ggplot(aes(Dim.1, Dim.2, color = Group)) +
  geom_point(size = 5)
