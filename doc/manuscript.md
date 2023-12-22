Disturbance and seed germination
================

# Methods

We performed all data analyses with R version 4.3.1 ([R Core Team
2023](#ref-RN5387)), using the R package ‘tidyverse’ ([Wickham et al.
2019](#ref-RN4662)) for data processing and visualization. The original
datasets, as well as R code for analysis and creation of the manuscript
can be accessed at the GitHub repository
<https://github.com/efernandezpascual/disturbance>.

## Disturbance indicators and species names

We retrieved the species disturbance indicator values of Midolo *et al.*
([2023](#ref-RN5101)). For the purposes of this study, we kept only (1)
disturbance frequency (the mean value of the disturbance return time, in
year) and (2) disturbance severity (a proportional value, 0/1). We used
the versions for whole community. To merge and homogenise this dataset
with the germination dataset (see below), we standardized all species
names in this article using the World Checklist of Vascular Plants
(Govaerts et al. ([2021](#ref-RN5389))).

## Seed germination dataset

We obtained a seed germination dataset for European species by
retrieving records from *SeedArc*, the global archive of primary seed
germination data ([Fernández-Pascual et al. 2023](#ref-RN5388)). We
define a record as a germination proportion of a given seed lot of a
species, recorded in response to a given set of germination cues
recreated in laboratory experimental conditions.

To ensure data quality, we only retrieved records belonging to (1)
angiosperms, to avoid the effect of gymnosperm branch lengths on
subsequent phylogenetic analysis; (2) species present in the megatree of
the seed plans by Smith & Brown ([2018](#ref-RN4754)), a tree that would
be used in subsequent analysis; (3) experiments conducted with seeds
collected from wild populations in Europe, defined as the land between
30º W and 70º E and north of 30º N; (4) experiments conducted with
either agar or filter paper as substrate; (5) experiments not using
specialized treatments (e.g. sterilization, nitrates, plant hormones, UV
light); (6) experiments not using complex dormancy breaking cycles
including warm cycles, which could be not comparable with simpler
experiments; (7) experiments conducted with at least 5 but no more than
a 1,000 seeds per experimental replicate; (8) species with data
available for the disturbance indicator values.

Furthermore, to merge disparate original datasets, we simplified the
germination cues by merging the originally-recorded treatment levels
into simpler treatment levels that are routinely recorded in germination
tests: (1) scarified vs. unscarified seeds (binary, 1/0); (2)
cold-stratification vs. non-stratified seeds (binary, 1/0); average
germination temperature (numerical, in degrees); alternating
vs. constant temperatures (binary, 1/0); and presence/absence of light
during the experiment (binary, 1/0) (**Table 1**). These drivers are
proxies of underlying quantitative variables that drive the
physiological responses of seeds: the cardinal germination temperatures,
the red:far red ratio, the length of the photoperiod, the amplitude of
the diurnal thermal oscillations, the length and temperature of cold
stratification, etc. The seed germination dataset is available in the
data folder of the GitHub repository (see Data Availability Statement).

## Statistical analysis

We tested the relationship between species dirturbance preferences and
germination cues by fitting a generalized mixed model with Bayesian
estimation (Markov Chain Monte Carlo generalized linear mixed models,
MCMCglmms) as implemented in the R package *MCMCglmm* ([Hadfield
2010](#ref-RN4755)).

In the model, the response variable was the germination proportion, and
the fixed predictors were the germination drivers (scarification, cold
stratification, temperature, alternating temperature and light), the
disturbance indicators (frequency and severity), plus the interactions
between germination drivers and disturbance indicators. Random effects
included the source of germination data (lab or publication), the seed
lot ID, species identity and a reconstructed phylogenetic tree for the
study species to account for the effect of a shared phylogeny. To create
the phylogeny we used the R package *U.PhyloMaker* ([Jin & Qian
2023](#ref-RN5390)) which contains an updated mega-tree of the seed
plants based on Smith & Brown ([2018](#ref-RN4754)). As mentioned above,
we only used species which were present in the tree. The phylogenetic
tree is available in the data folder of the GitHub repository (see Data
Availability Statement). Response variables were centered and scaled so
their contribution to the effect sizes could be compared.

We used weakly informative priors, with parameter-expanded priors for
the random effects, as suggested by the package’s author ([Hadfield
2010](#ref-RN4755)). Each model was run for 1,000,000 MCMC steps, with
an initial burn-in phase of 200,000 and a thinning interval of 1,000
([De Villemereuil & Nakagawa 2014](#ref-RN4756)), resulting, on average,
in 9,000 posterior distributions. From the resulting posterior
distributions, we calculated mean parameter estimates and 95% highest
posterior density and credible intervals (CI). We interpreted the
significance of model parameters by examining CIs, considering
parameters with CIs overlapping with zero as non-significant. The R
script to fit the model, and the fitted model object, are available at
the GitHub repository (see Data Availability Statement).

# Results

The combined germination dataset contained 17,833 records of 1,386
species. The total number of seeds used in the experiments was 812,380.
Experiments had used scarified seeds in 3,450 records (19%) and
cold-stratified seeds in 2,707 records (15%). The average temperatures
of the experiments ranged from 0 to 40 ºC, with an average of 18 ºC.
Alternating temperatures had been used in 7,444 records (42%) and light
in 16,303 records (91%). According to the MCMCglmms (**Fig. 1A**), all
the germination cues had a positive main effect, i.e. overall,
germination proportions across species were significantly improved by
scarification, cold-stratification, warmer temperatures, alternating
temperatures and light.

According to the MCMC model (**Fig. 1B**), disturbance frequency did not
have a main effect on germination proportion, i.e. seeds germinated
similarly independently of their disturbance frequency incubator.
However, frequency had a significant positive interaction with
scarification and significant negative interactions with cold
stratification, temperature and light. This indicates that species
adapted to more frequent disturbances have a stronger need for
scarification, germinate better at lower temperatures and have a lesser
need for light during germination (**Fig. 2C**).

The same MCMC model (**Fig. 1C**) indicated a significant main effect of
disturbance severity, i.e. species adapted to more severe disturbances
also have an overall higher germination proportion. In addition,
severity had significant negative interactions with temperature and
light, so species adapted to more severe disturbances germinate better
at lower temperatures and have a lesser need for light during
germination (**Fig. 2B**).

Phylogenetic signal was high in the model (lambda = 0.78, CI = 0.72 to
0.83). Of the random factors, the one with the largest effect was
phylogeny (mean = 12.37, CI = 8.43 to 16.27), followed by data source
(mean = 2.78, CI = 1.88 to 3.73), seed lot (mean = 2.23, CI = 2.02 to
2.45) and species identity (mean = 1.45, CI = 1.08 to 1.79).

# Data availability

The original datasets, as well as R code for analysis and creation of
the manuscript can be accessed at the GitHub repository
<https://github.com/efernandezpascual/disturbance>. Upon publication, a
version of record of the repository will be deposited in Zenodo.

# References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-RN4756" class="csl-entry">

De Villemereuil, P., & Nakagawa, S. 2014. General quantitative genetic
methods for comparative biology. In *Modern phylogenetic comparative
methods and their application in evolutionary biology*, pp. 287–303.
Springer.

</div>

<div id="ref-RN5388" class="csl-entry">

Fernández-Pascual, E., Carta, A., Rosbakh, S., Guja, L., Phartyal, S.S.,
Silveira, F.A.O., Chen, S.-C., Larson, J.E., & Jiménez-Alfaro, B. 2023.
[SeedArc, a global archive of primary seed germination
data](https://doi.org/10.1111/nph.19143). *New Phytologist* 240:
466–470.

</div>

<div id="ref-RN5389" class="csl-entry">

Govaerts, R., Nic Lughadha, E., Black, N., Turner, R., & Paton, A. 2021.
[The world checklist of vascular plants, a continuously updated resource
for exploring global plant
diversity](https://doi.org/10.1038/s41597-021-00997-6). *Scientific
Data* 8: 215.

</div>

<div id="ref-RN4755" class="csl-entry">

Hadfield, J.D. 2010. [MCMC methods for multi-response generalized linear
mixed models: The MCMCglmm r
package](https://doi.org/10.18637/jss.v033.i02). *Journal of Statistical
Software* 33: 1–22.

</div>

<div id="ref-RN5390" class="csl-entry">

Jin, Y., & Qian, H. 2023. [U.PhyloMaker: An r package that can generate
large phylogenetic trees for plants and
animals](https://doi.org/10.1016/j.pld.2022.12.007). *Plant Diversity*
45: 347–352.

</div>

<div id="ref-RN5101" class="csl-entry">

Midolo, G., Herben, T., Axmanová, I., Marcenò, C., Pätsch, R.,
Bruelheide, H., Karger, D.N., Aćić, S., Bergamini, A., Bergmeier, E.,
Biurrun, I., Bonari, G., Čarni, A., Chiarucci, A., De Sanctis, M.,
Demina, O., Dengler, J., Dziuba, T., Fanelli, G., Garbolino, E., Giusso
del Galdo, G., Goral, F., Güler, B., Hinojos-Mendoza, G., Jansen, F.,
Jiménez-Alfaro, B., Lengyel, A., Lenoir, J., Pérez-Haase, A., Pielech,
R., Prokhorov, V., Rašomavičius, V., Ruprecht, E., Rūsiņa, S., Šilc, U.,
Škvorc, Ž., Stančić, Z., Tatarenko, I., & Chytrý, M. 2023. [Disturbance
indicator values for european
plants](https://doi.org/10.1111/geb.13603). *Global Ecology and
Biogeography* 32: 24–34.

</div>

<div id="ref-RN5387" class="csl-entry">

R Core Team. 2023. [R: A language and environment for statistical
computing. Version 4.3.1](https://www.r-project.org/).

</div>

<div id="ref-RN4754" class="csl-entry">

Smith, S.A., & Brown, J.W. 2018. [Constructing a broadly inclusive seed
plant phylogeny](https://doi.org/10.1002/ajb2.1019). *American Journal
of Botany* 105: 302–314.

</div>

<div id="ref-RN4662" class="csl-entry">

Wickham, H., Averick, M., Bryan, J., Chang, W., McGowan, L., François,
R., Grolemund, G., Hayes, A., Henry, L., & Hester, J. 2019. Welcome to
the tidyverse. *Journal of Open Source Software* 4: 1686.

</div>

</div>

# Figures

<div class="figure">

<img src="../results/figures/mcmc.png" alt="Figure 1" width="4251" />
<p class="caption">
Figure 1
</p>

</div>

<div class="figure">

<img src="../results/figures/loess.png" alt="Figure 2" width="4251" />
<p class="caption">
Figure 2
</p>

</div>
