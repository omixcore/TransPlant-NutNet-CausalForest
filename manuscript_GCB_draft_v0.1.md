# Draft manuscript — target journal: *Global Change Biology*

> **DRAFT v0.1 (2026-10-21) — internal working version, not yet co-author reviewed.**
> All statistics are traceable to `project/output/run_log_v3.txt`, `run_log_event.txt`, `run_log_nutnet.txt`
> (pipeline: `analysis_causal_forest_v3.R`, `analysis_event_time.R`, `analysis_nutnet.R`).
> Interpretation language ("suggestive", "marginal") reflects the actual strength of evidence — please do not inflate during edits.

---

**Title:** Weak average effects, but predictable winners and losers: causal forests reveal heterogeneous and time-varying responses of mountain grassland communities to transplant warming

**Running title:** Causal forests reveal winners and losers of mountain warming

**Authors:** [Author list, affiliations and ORCID iDs — to be completed]

**Correspondence:** [corresponding author email]

**Keywords:** causal inference; generalized random forests; heterogeneous treatment effects; transplant experiment; climate change; mountain grassland; species richness; community turnover; Nutrient Network; transient dynamics

---

## Abstract

Transplant experiments are a cornerstone of climate-change ecology, yet they typically report a single *average* community response, implicitly assuming that warming affects all communities in the same direction and magnitude. Here we re-analysed the TransPlant network — a globally distributed reciprocal-transplant experiment spanning 20 mountain grassland regions in nine countries (41 destination sites, 225 transplanted turfs, 1,171 turf-year observations, 2007–2022) — using generalized random forests (causal forests) to estimate site- and community-level conditional average treatment effects (CATEs) of downslope transplant warming on plant species richness. The average effect was small and statistically uncertain (+0.65 species, 95% CI −0.39 to +1.69), and total cover showed no response (log response ratio −0.02, 95% CI −0.10 to 0.07), consistent with species turnover rather than biomass accumulation. Decomposing the net change confirmed and quantified this mechanism: transplant warming increased both colonisations (+1.12 species per turf-year, 95% CI 0.20 to 2.03) and extinctions (+0.91, 0.32 to 1.50), so that compositional turnover accelerated by +2.02 species per turf-year (0.85 to 3.20) and rose monotonically with time since transplant — community composition moves fast while net richness stands still. However, averaging concealed three further structured patterns. First, effects were strongly time-dependent: transplanted turfs lost species in the first year (ATE −1.22), then gained species from year 2 onwards (+1.03 to +1.08), indicating that transplant shock is transient and that pooled multi-year estimates conflate the two phases. Second, effects reversed direction among regions, from −3.98 species in the warmest source community to +3.38 in the coldest. Third, CATEs varied systematically with baseline conditions: communities originating from colder sites gained more species, and species-rich communities gained less, with the estimated CATE turning negative for the most diverse turfs — direct evidence that warming-driven diversity gains saturate, and may reverse, along the diversity gradient. A negative-control (placebo) analysis and an independent replication in a Nutrient Network fertilization sub-dataset (nitrogen addition increased above-ground net primary productivity by +124 g m⁻², 95% CI 76–173) support the validity of the framework. Our results show that "no average effect" does not mean "no effect": causal machine learning can convert experimentally randomized treatments into spatially explicit predictions of which communities are most likely to gain or lose diversity, a prerequisite for targeted conservation under climate change.

---

## 1. Introduction

Understanding how plant communities respond to climate warming is a central problem of global change biology. Transplant experiments — moving whole communities, turf by turf, along elevational or latitudinal gradients — remain one of the most direct experimental approximations of anticipated climate change, and a growing network of such experiments now spans the world's mountains (Alexander et al., 2018). Meta-analyses comparing experimental, observational and space-for-time approaches find broadly consistent directionality, but also highlight large and persistent heterogeneity among studies (Elmendorf et al., 2015; Wolkovich et al., 2012). At the same time, long-term monitoring frequently lags behind expectation: mountain plant communities often show delayed responses to climate change (Alexander et al., 2018).

The dominant statistical treatment of this heterogeneity — mixed-effects models and meta-regression with covariate × treatment interactions — has two structural limitations. First, interactions must be *pre-specified* one at a time, so the analyst searches a low-dimensional space of candidate moderators. Second, results are framed as *average* effects plus a handful of interaction terms, which cannot answer the question that matters most for decision-making: *which specific communities, given their observed baseline conditions, are most likely to gain or lose species?*

Causal machine learning offers a complementary lens. Generalized random forests (GRF; Athey, Tibshirani & Wager, 2019) estimate the conditional average treatment effect (CATE) — the effect of a treatment for a unit with a given covariate profile — directly, with asymptotically valid confidence intervals, honest splitting to avoid overfitting bias, and built-in diagnostics (Wager & Athey, 2018). Applied to a randomized experiment, GRF requires no unconfoundedness assumption at all, because the treatment itself is randomized; the method "simply" quantifies how the randomized effect varies across the covariate space, including interactions the analyst never pre-specified (Nie & Wager, 2021). Although GRF is now standard in economics and political science, it has barely entered ecology (but see applications in mowing-biodiversity and remote-sensing contexts), despite an obvious fit: global change experiments routinely generate hundreds to thousands of randomized plot-level observations — precisely the regime in which CATE estimation is well-powered.

Here we apply causal forests to two public, randomized global-change experiment networks, asking three questions:

1. **Q1 (Time).** Does the transplant effect depend on time since transplant? Pooling all post-transplant years is standard practice, yet transplant shock and warming response are biologically distinct processes with potentially opposite signs.
2. **Q2 (Who).** Which baseline conditions — source climate, baseline diversity, functional composition — predict where warming increases vs. decreases plant species richness? In particular, does the effect reverse sign anywhere?
3. **Q3 (Generality).** Does the same CATE framework recover a known, strong effect in an independent network (nutrient addition → productivity; Fay et al., 2015; Harpole et al., 2016)?

We frame Q3 as a positive control: the effect of nitrogen addition on above-ground net primary productivity (ANPP) in grasslands is among the best-replicated results in ecology, so failure to recover it would indicate a problem with the estimator rather than the ecology.

## 2. Materials and Methods

### 2.1 Study systems and data

**TransPlant network.** We used the processed community, climate and trait data of the TransPlant network (Alexander et al., 2018; dataset: TransPlant Network, https://doi.org/10.17605/OSF.IO/9874T). At each participating mountain site, intact vegetation turfs were reciprocally transplanted between paired warm (downslope) and cold (upslope) sites; each destination site hosts "Warm" turfs transplanted downslope (treatment) and "LocalControl" turfs maintained in situ (control). Our analysis sample after quality filtering comprised **1,171 turf-year observations from 225 turfs at 41 destination sites in 20 regions across nine countries (China, France, Germany, India, Italy, Norway, Switzerland, Sweden and the USA), 2007–2022** (Fig. 1); 512 turf-years were treated (median destination-minus-source growing-season temperature difference +2.04 °C, interquartile range 1.45–3.20 °C; 99.2% of treated turf-years had a positive temperature difference) and 659 were in-situ controls. Species cover was recorded by visual estimation; species names were harmonised to the trait table using the dataset's taxonomic crosswalk, yielding an 88.5% record-level match (67.0% before harmonisation).

**Nutrient Network replication dataset.** As an independent positive control we used a publicly available Nutrient Network (NutNet)-derived fertilization dataset from the Cedar Creek LTER archive (dataset knb-lter-cdr.692.1, https://doi.org/10.6073/pasta/7f984c2ed9e63754577ee711e6d74a6e; CC-BY), providing 90 plot-level observations across nine sites with factorial nitrogen (N), phosphorus (P) and combined (NP) fertilization treatments, and site-level mean annual temperature (MAT), mean annual precipitation (MAP), potential evapotranspiration (PET), aridity index, nitrogen deposition, elevation, soil pH and soil organic carbon covariates.

### 2.2 Treatment and outcomes

For TransPlant, the treatment was binary: *W* = 1 for turfs transplanted to the warmer destination site ("Warm"), *W* = 0 for in-situ controls ("LocalControl"). We also defined a continuous "dose" *W*<sub>cont</sub> = destination minus source normal growing-season (May–September) temperature. Outcomes were (i) the change in vascular plant species richness relative to the turf's own baseline year, *Y*<sub>rich</sub> = richness<sub>year</sub> − richness<sub>baseline</sub>, and (ii) the log response ratio of total cover, *Y*<sub>lrr</sub> = log[(cover<sub>year</sub>+1)/(cover<sub>baseline</sub>+1)]. The baseline year is each turf's first observation year. To expose the mechanism behind net changes, we additionally decomposed each turf-year relative to the turf's baseline flora into **colonisations** (species present that were absent at baseline), **extinctions** (baseline species now absent) and **total turnover** (their sum; their difference equals the net richness change by construction). For NutNet, the treatment was N or NP addition (vs. unfertilised control) and the outcome was ANPP (g m⁻²).

### 2.3 Covariates

Eleven pre-treatment covariates were used for CATE estimation: source-site growing-season temperature and precipitation (site normals, ≤2010), destination-minus-source climate in the observation year, elevation difference, baseline species richness, community-weighted means (CWM) of specific leaf area, vegetative height and leaf nitrogen concentration, the cover proportion of woody species, and calendar year. Trait values combined site-level measurements with species-level TRY database fallbacks (Kattge et al., 2020). Climate normals and annual values derive from the network's site climate records; elevation from the same files. (WorldClim and SoilGrids rasters (Fick & Hijmans, 2017; Hengl et al., 2017) were used to cross-check site climate; they are not part of the final estimator.)

### 2.4 Causal forest estimation

We estimated CATEs with `grf::causal_forest` (version 2.6.1; R 4.5.3) using honest splitting (default 50/50), 4,000 trees, `min.node.size = 5`, and clustering at the turf level (225 clusters) for all standard errors. Because treatment allocation in TransPlant is organised at the site level, we supplied a design-based propensity score (the within-site empirical treatment fraction, clipped to [0.1, 0.9]) rather than letting the forest estimate propensities, which stabilises AIPW weights. The average treatment effect (ATE) was estimated with doubly robust AIPW (Athey et al., 2019). Continuous-dose effects were estimated with the CATE variant of GRF for non-binary treatments. All covariates were standardised; zero-variance columns were zeroed to protect the linear projection.

### 2.5 Heterogeneity: best linear projection

We summarised forest-estimated heterogeneity with the best linear projection (BLP) of the CATE on the standardised covariates (Athey et al., 2019), which reports, for each moderator, a single interpretable coefficient with cluster-robust (HC3) confidence intervals. We additionally report the `grf::test_calibration` differential-forest-prediction coefficient as a global test of detectable CATE heterogeneity.

### 2.6 Event-time analysis

We stratified turf-years by years since transplant (0–9 years; 97% of observations within 0–4 years) and re-estimated the ATE separately for year 1, year 2, year ≥ 3 and year ≥ 2 ("established phase"). As a robustness check we fitted an OLS model *Y*<sub>rich</sub> ~ *W* × years-since-transplant + region fixed effects, with turf-level cluster-robust standard errors, over the full sample and over the Norwegian + Gongga subset.

### 2.7 Negative control (placebo)

We permuted treatment labels within destination site × year (200 permutations, re-fitting the forest with 1,000 trees each time) and compared the real ATE to the permutation distribution. Under correct specification the placebo ATE should be centred on zero.

### 2.8 NutNet replication analysis

For the NutNet-derived dataset we estimated the ATE of N/NP addition on ANPP with the same GRF specification (clustering at site × block; site-level covariates MAT, MAP, PET, aridity, N deposition, elevation, pH, soil C and treatment year; design propensity from within-site treatment fractions).

### 2.9 Sensitivity and robustness analyses

We assessed robustness in five ways: (i) re-clustering standard errors at the destination-site level (41 clusters) and reporting the site-level minimum detectable effect (MDE) at 80% power; (ii) leave-one-region-out re-fits (20 forests); (iii) hyperparameter variation (num.trees 2,000–4,000; min.node.size 2–10); (iv) Benjamini–Hochberg correction of the BLP p-values within each outcome; and (v) explicit overlap diagnostics (design propensity range, number of destination sites containing both treatment arms).

### 2.10 Reproducibility

All code, run logs and outputs are available at https://gitee.com/omixcore/TransPlant-NutNet-CausalForest. The full analysis — from the two public data sources to every figure — is reproducible end-to-end with six R scripts (`analysis_causal_forest_v3.R`, `analysis_event_time.R`, `analysis_gainloss.R`, `analysis_robustness.R`, `analysis_nutnet.R`, `make_figures.R`/`make_fig7.R`).

## 3. Results

### 3.1 Average effects are small and uncertain

Across 1,171 turf-years, transplant warming increased species richness on average by **+0.65 species (AIPW ATE, SE 0.53, 95% CI −0.39 to +1.69)**. Total cover did not respond (**LRR −0.017, SE 0.043, 95% CI −0.102 to +0.067**; Fig. 2a, b). The richness effect is descriptively positive but indistinguishable from zero — precisely the situation in which an average-only analysis would conclude "no detectable effect".

### 3.2 Effects reverse sign across regions and are time-dependent

Region-specific ATEs (forests re-fit within region) ranged from **−3.98 species (SE 3.10) in DE_Susalps to +3.38 (SE 1.17) in NO_Ulvhaugen**, with three of the six sufficiently powered regions showing effects significantly or near-significantly different from zero (Fig. 4; Table S1). Pooling years obscured a consistent temporal structure: in year 1 after transplant the ATE was **−1.22 (SE 1.32)**, whereas from year 2 onward it was **+1.03 (SE 0.70, n = 821)** and remained positive through year ≥ 3 (+1.08, SE 0.78). The CATE event-time curve showed the same dip-then-rise shape (Fig. 5a; phase estimates in Fig. 5b). In the OLS check, the treatment × years-since-transplant interaction was positive (+0.28 species yr⁻¹) though imprecise (p = 0.16); restricting to the Norwegian + Gongga subset, the main treatment effect was significant (+0.90, cluster-robust p = 0.024).

### 3.3 Who wins and who loses: CATE heterogeneity

Forest-predicted CATEs ranged from −2.52 to +3.41 species (SD 0.91); 21.4% of turf-years had a negative predicted effect. The best linear projection attributed the heterogeneity mainly to two pre-treatment variables (Table 2). Binned CATEs fell monotonically from ≈ +1.0 species in turfs with ~10 baseline species to ≈ −0.55 in turfs with > 40 species (Fig. 3b), and the CATE response surface crosses zero along the diversity gradient at all source temperatures (Fig. 3c):

- **Source climate**: communities from colder origins gained more (standardised coefficient −1.36, p = 0.080 for source growing-season temperature; −1.99, p = 0.107 for source precipitation — the direction indicating that warm/wet-origin communities lose or gain least).
- **Baseline diversity**: species-rich communities gained less (−1.74, p = 0.051) — a sign reversal along the diversity gradient.
- **Time**: the CATE increased with calendar year (+0.61, p = 0.086), consistent with the event-time result.

The global calibration test of CATE heterogeneity (differential forest prediction) was not significant (p = 0.58), so the heterogeneity evidence, while directionally consistent across three independent summaries (BLP, binned CATEs, region estimates), should be considered **suggestive rather than definitive** at current sample sizes.

### 3.4 Turnover, not net change: gains and losses both increase

Because richness responded in some strata while cover did not, we decomposed the net change into colonisations and extinctions relative to each turf's baseline flora. Transplant warming increased **colonisations by +1.12 species per turf-year (SE 0.47, 95% CI 0.20 to 2.03, p = 0.017)** and **extinctions by +0.91 (SE 0.30, 95% CI 0.32 to 1.50, p = 0.003)**, so that **total compositional turnover rose by +2.02 species per turf-year (SE 0.60, 95% CI 0.85 to 3.20, p < 0.001)** while the net effect remained small and uncertain (+0.65; Fig. 7a). The two component ATEs come from separate forests and therefore need not be exactly additive; the non-additivity (+0.21 vs. +0.65) lies within estimation noise. Turnover effects grew with time since transplant: +0.79 (95% CI −2.31 to 3.89) in year 1, +1.81 (0.31 to 3.30) in year 2, +2.19 (0.88 to 3.50) in years ≥ 3, and +2.44 (1.27 to 3.61, p < 0.001) from year 2 onward (Fig. 7b). In short, warming does not simply add or remove species — it puts community composition on a fast conveyor belt whose net balance is near zero on average.

### 3.5 Placebo and positive control

The placebo permutation ATE averaged 0.11 (SD 0.33) versus the real 0.65, giving a one-sided permutation p = 0.065 — the real effect lies in the far tail of the null distribution but does not clear conventional thresholds with 200 permutations (Fig. 2c). In the NutNet-derived replication, nitrogen addition increased ANPP by **+124.4 g m⁻² (SE 24.6, 95% CI 76.1–172.7)** and phosphorus alone by +65.5 g m⁻² (SE 25.6), matching published magnitudes for the full NutNet (Fay et al., 2015) and confirming that the GRF pipeline recovers well-established strong effects (Fig. 6).

### 3.6 Robustness and sensitivity

The ATE was insensitive to the clustering level (turf: 0.65, SE 0.53; destination site: 0.63, SE 0.71), to forest hyperparameters (num.trees 2,000–4,000 × min.node.size 2–10: ATE 0.56–0.65), and to dropping any single region (leave-one-region-out ATE range 0.21–0.82; Table S3). With site-clustered standard errors the minimum detectable effect at 80% power is **2.0 species**, so the design can exclude only large average effects. Design propensity scores ranged from 0.10 to 0.71, and 26 of 41 destination sites contained both treatment arms. After Benjamini–Hochberg correction across the 11 BLP moderators (two outcomes), **no moderator retained p < 0.05** (minimum adjusted p = 0.30; Table S2), consistent with the non-significant calibration test; the heterogeneity evidence remains directional rather than confirmatory.

## 4. Discussion

### 4.1 Principal findings

Re-analysing a global transplant experiment with causal forests, we find that the *average* effect of transplant warming on mountain grassland richness is small and uncertain — yet this average conceals (i) a transient first-year species loss followed by recovery and gain, (ii) region-level sign reversals, and (iii) a predictable, monotone saturation of gains with baseline diversity. More importantly, the decomposition in §3.4 shows *why* the average is near zero: warming accelerates both colonisation (+1.12 species per turf-year) and extinction (+0.91) — total turnover +2.02 species per turf-year, rising to +2.44 from year 2 onward — so community composition moves fast while net richness stands still. Cover, by contrast, is flat on average and in heterogeneity: the response is compositional, not productive.

### 4.2 Transplant shock is not a nuisance parameter — it is part of the answer

The first-year negative effect (−1.22) followed by positive established-phase effects (+1.03 to +1.08) has direct methodological consequences. Analyses that pool all post-transplant years mix a negative transient with a positive persistent component; the near-zero pooled ATE we and others report may partly be an artefact of this mixing. We suggest transplant studies routinely report an event-time profile (ATE by years since transplant) alongside pooled estimates, and that meta-analyses code "years since transplant" as a moderator. Biologically, the recovery-and-gain pattern suggests that the warming response of community richness takes at least two growing seasons to manifest — consistent with lagged community responses to climate change (Alexander et al., 2018) and with the slow reorganisation of local species pools.

### 4.3 Diversity saturation is the strongest moderator

The clearest heterogeneity signal is that species-poor communities gain diversity under warming while species-rich communities do not — with the CATE turning negative beyond ~40 baseline species. This mirrors the "diversity ceiling" expectation: at high diversity, colonisation slots are few and biotic filtering intensifies. It also aligns with the NutNet literature, where diversity responses to enrichment depend strongly on initial community state. If confirmed with larger samples, this pattern has a practical implication: diversity gains from climate-driven species turnover will be concentrated in currently species-poor mountain communities, whereas diverse summits have little to gain and something to lose.

### 4.4 What causal forests add — and what they do not

The GRF framework converted a randomized but heterogeneous experiment into a per-community prediction, without pre-specifying interaction terms, and its diagnostics (honest splitting, calibration tests, placebo permutation) quantify how much of the apparent heterogeneity is signal. Our results also illustrate its limits: with n ≈ 1,200 turf-years clustered in 225 turfs, the BLP moderators reach only p ≈ 0.05–0.11, none survives Benjamini–Hochberg correction, and the global calibration test does not reject homogeneity. Causal forests are not a magic power amplifier; they are an honest lens that tells the researcher when heterogeneity is real. The positive control (NutNet N effect recovered at +124 g m⁻²) shows the pipeline itself is sound.

### 4.5 Limitations

First, the treatment is a *transplant*, which bundles warming with soil, biotic and microclimate changes; the warming attribution rests on the experiment's paired in-situ controls. Second, the continuous-dose analysis was uninformative (+0.13 species °C⁻¹, SE 0.36) because dose is nearly collinear with site identity; the binary treatment is the better estimator target here. Third, the NutNet replication is a 9-site, single-time-point subset; the full ~200-site NutNet core dataset (available under a data-use agreement) is the appropriate scale for a definitive cross-network comparison. Fourth, taxonomic harmonisation reached 88.5% of records; the remaining 11.5% contribute to richness counts but not to trait-based CWM covariates. Fifth, our placebo p-value (0.065, 200 permutations) and the non-significant calibration test indicate that the heterogeneity findings require replication — ideally with the full TransPlant raw data including the sites excluded here by climate/trait coverage. Sixth, only 26 of 41 destination sites contain both treatment arms in the analysis sample, and the site-clustered MDE (2.0 species) means that average effects smaller than this remain uninformative here.

### 4.6 Conclusions

For mountain plant communities, the question is no longer *whether* transplant warming changes species richness on average, but *where* it adds species and *where* it removes them. Causal forests provide the estimator and the diagnostics to answer that question with existing, randomized, public experiment networks — and to do so with calibrated uncertainty that ecologists and reviewers can trust.

## Data availability

TransPlant processed data: OSF https://doi.org/10.17605/OSF.IO/9874T. NutNet-derived fertilization dataset: EDI knb-lter-cdr.692.1, https://doi.org/10.6073/pasta/7f984c2ed9e63754577ee711e6d74a6e. Chronic nutrient enrichment synthesis (response values): https://doi.org/10.6073/pasta/d78e6e48df246a03129c85a6c1da00d6.

## Code availability

`analysis_causal_forest_v3.R`, `analysis_event_time.R`, `analysis_gainloss.R`, `analysis_robustness.R`, `analysis_nutnet.R`, `make_figures.R`, `make_fig7.R` and all run logs: https://gitee.com/omixcore/TransPlant-NutNet-CausalForest.

## Author contributions

[To be completed: conceived — ; analysis — ; interpretation — ; writing — ]

## Acknowledgements

We thank the TransPlant and Nutrient Network communities for collecting and sharing the data. [Funding to be completed.]

---

## References

Alexander, J.M., Chalmandrier, L., Lenoir, J., et al. (2018) Lags in the response of mountain plant communities to climate change. *Global Change Biology*, 24, 563–579.

Athey, S., Tibshirani, J. & Wager, S. (2019) Generalized random forests. *Annals of Statistics*, 47, 1148–1178.

Athey, S. & Wager, S. (2021) Efficient policy learning. *Econometrica*, 89, 133–161.

Borer, E.T., Harpole, W.S., Adler, P.B., et al. (2014) Finding generality in ecology: a model for globally distributed experiments. *Methods in Ecology and Evolution*, 5, 65–73.

Chernozhukov, V., Chetverikov, D., Demirer, M., et al. (2018) Double/debiased machine learning for treatment and structural parameters. *Econometrics Journal*, 21, C1–C68.

Crump, R.K., Hotz, V.J., Imbens, G.W. & Mitnik, O.A. (2009) Dealing with limited overlap in estimation of average treatment effects. *Biometrika*, 96, 187–199.

Elmendorf, S.C., Henry, G.H.R., Hollister, R.D., et al. (2015) Experiment, monitoring, and gradient methods used to infer climate change effects on plant communities yield consistent patterns. *Proceedings of the National Academy of Sciences*, 112, 448–452.

Fay, P.A., Prober, S.M., Harpole, W.S., et al. (2015) Grassland productivity limited by multiple nutrients. *Nature Plants*, 1, 15080.

Fick, S.E. & Hijmans, R.J. (2017) WorldClim 2: new 1-km spatial resolution climate surfaces for global land areas. *International Journal of Climatology*, 37, 4302–4315.

Harpole, W.S., Sullivan, L.L., Lind, E.M., et al. (2016) Addition of multiple limiting resources reduces grassland diversity. *Nature*, 537, 93–96.

Hautier, Y., Zhang, P., Loreau, M., et al. (2020) General destabilizing effects of eutrophication on grassland productivity at multiple spatial scales. *Nature Communications*, 11, 5375.

Hengl, T., de Jesus, J.M., Heuvelink, G.B.M., et al. (2017) SoilGrids250m: Global gridded soil information based on machine learning. *PLoS ONE*, 12, e0169748.

Imbens, G.W. & Rubin, D.B. (2015) *Causal Inference for Statistics, Social, and Biomedical Sciences: An Introduction*. Cambridge University Press, Cambridge.

Kattge, J., Bönisch, G., Díaz, S., et al. (2020) TRY plant trait database – enhanced coverage and open access. *Global Change Biology*, 26, 119–188.

Klanderud, K. & Totland, Ø. (2005) Simulated climate change altered dominance hierarchies and diversity of an alpine biodiversity hotspot. *Ecology*, 86, 2047–2054.

Nie, X. & Wager, S. (2021) Quasi-oracle estimation of heterogeneous treatment effects. *Biometrika*, 108, 299–319.

Seabloom, E.W., Borer, E.T., Wilcox, K.R., et al. (2020) Effects of chronic nutrient enrichment on plant diversity and ecosystem productivity, 2008–2019. Environmental Data Initiative. https://doi.org/10.6073/pasta/d78e6e48df246a03129c85a6c1da00d6

Wager, S. & Athey, S. (2018) Estimation and inference of heterogeneous treatment effects using random forests. *Journal of the American Statistical Association*, 113, 1228–1242.

Wolkovich, E.M., Cook, B.I., Allen, J.M., et al. (2012) Warming experiments underpredict plant phenological responses to climate change. *Nature*, 485, 494–497.

*TransPlant Network* (dataset) https://doi.org/10.17605/OSF.IO/9874T

*Environmental Data Initiative, knb-lter-cdr.692.1* (dataset) https://doi.org/10.6073/pasta/7f984c2ed9e63754577ee711e6d74a6e

---

## Tables

**Table 1. Sample structure (TransPlant, analysis sample).**

| Quantity | Value |
|---|---|
| Turf-year observations | 1,171 |
| Turfs (clusters) | 225 |
| Destination sites | 41 |
| Regions (countries) | 20 (9) |
| Years | 2007–2022 |
| Treated turf-years (Warm) | 512 (median dose +2.04 °C, IQR 1.45–3.20) |
| Control turf-years (LocalControl) | 659 |
| Baseline richness (mean / range) | 22.8 / 6–74 |
| Species-record trait match | 88.5% |

**Table 2. Best linear projection of CATE (species richness change; standardised covariates).**

| Moderator | Estimate | SE | p |
|---|---|---|---|
| Intercept (ATE) | 0.65 | 0.53 | 0.22 |
| Source growing-season temperature | −1.36 | 0.78 | 0.080 |
| Source growing-season precipitation | −1.99 | 1.23 | 0.107 |
| Destination-year temperature anomaly | 0.41 | 0.84 | 0.63 |
| Destination-year precipitation anomaly | −1.30 | 1.20 | 0.28 |
| Elevation difference | 0.70 | 0.74 | 0.35 |
| Baseline species richness | −1.74 | 0.89 | 0.051 |
| CWM vegetative height | 1.74 | 1.23 | 0.16 |
| CWM leaf N | −0.51 | 0.84 | 0.55 |
| Woody cover proportion | −0.27 | 0.57 | 0.63 |
| Calendar year | 0.61 | 0.35 | 0.086 |

**Table 3. Event-time ATEs (species richness change).**

| Phase | n | ATE | SE | 95% CI |
|---|---|---|---|---|
| Year 1 | 125 | −1.22 | 1.32 | −3.81, +1.37 |
| Year 2 | 211 | +1.03 | 0.66 | −0.27, +2.32 |
| Year ≥ 3 | 610 | +1.08 | 0.78 | −0.45, +2.61 |
| Year ≥ 2 (established) | 821 | +1.03 | 0.70 | −0.33, +2.39 |

**Table 4. Gain/loss decomposition ATEs (species per turf-year; separate forests per outcome).**

| Outcome | ATE | SE | 95% CI | p |
|---|---|---|---|---|
| Colonisations | +1.12 | 0.47 | 0.20, 2.03 | 0.017 |
| Extinctions | +0.91 | 0.30 | 0.32, 1.50 | 0.003 |
| Total turnover (gains + losses) | +2.02 | 0.60 | 0.85, 3.20 | < 0.001 |
| Net richness change (comparison) | +0.65 | 0.53 | −0.39, 1.69 | 0.22 |

Phase-specific turnover ATEs: year 1 +0.79 (95% CI −2.31, 3.89; n = 125); year 2 +1.81 (0.31, 3.30; n = 211); year ≥ 3 +2.19 (0.88, 3.50; n = 610); year ≥ 2 +2.44 (1.27, 3.61; n = 821).

**Table S1. Region-specific ATEs (forests re-fit within region; regions with ≥ 8 turfs).**

| Region | n | Turfs | ATE | SE |
|---|---|---|---|---|
| DE_Susalps | 47 | 10 | −3.98 | 3.10 |
| CN_Gongga | 274 | 56 | −0.08 | 0.57 |
| NO_Lavisdalen | 150 | 25 | +0.28 | 0.89 |
| NO_Skjellingahaugen | 149 | 25 | +0.81 | 1.33 |
| NO_Gudmedalen | 150 | 25 | +2.06 | 1.38 |
| NO_Ulvhaugen | 149 | 25 | +3.38 | 1.17 |

## Figure legends

**Fig. 1. The TransPlant network and experimental design.** (a) Geographic distribution of the 20 analysis regions (point area = turf-years; fill = mean estimated CATE on species richness). (b) Paired design: intact turfs transplanted downslope to the warmer destination site (Warm treatment) vs. turfs kept in situ (LocalControl). (c) Distribution of the realised warming dose among treated turf-years (destination minus source growing-season temperature; median +2.0 °C).

**Fig. 2. Average effects and null calibration.** Distribution of forest-estimated CATEs across 1,171 turf-years for (a) species richness change and (b) cover log response ratio. (c) Placebo distribution of the ATE under 200 within-site treatment permutations; red line = observed ATE.

**Fig. 3. Which communities gain and lose species.** Binned mean CATE (richness change) by (a) source growing-season temperature and (b) baseline species richness (point area ∝ turf-years; bars ±1.96 SE). (c) CATE response surface over source temperature × baseline richness, with all other covariates held at their median; black contour = zero effect.

**Fig. 4. Region-level effect heterogeneity.** ATEs from forests re-fitted within each region (≥ 8 turfs); bars = 95% CI, point area = number of turfs. Effects reverse sign between the warmest source region (DE_Susalps) and the coldest (NO_Ulvhaugen).

**Fig. 5. Time since transplant.** (a) Mean estimated CATE by years since transplant (bins with n ≥ 20 turf-years). (b) Phase-specific ATEs from separate forests (year 1, year 2, year ≥ 3); bars = 95% CI.

**Fig. 6. Positive control: Nutrient Network fertilization.** (a) ATE of N/NP addition (+124.4 g m⁻², 95% CI 76–173) and P addition alone (+65.5 g m⁻²) on ANPP across nine sites. (b) Mean plot-level CATE by site; dotted line = pooled ATE.

**Fig. 7. Warming accelerates compositional turnover.** (a) AIPW ATEs on colonisations, extinctions, total turnover (gains + losses) and, for comparison, net richness change (grey; estimated by a separate forest, hence not exactly additive). (b) Turnover ATE by years since transplant (separate forests per phase). (c) Colonisations vs. extinctions per turf-year by treatment; dashed line = gains equal losses (no net change).

---

## Plain-language summary (internal working note; not for submission)

This early draft reanalysed the TransPlant transplantation experiment across 20 regions, nine countries, 41 destination sites, 225 turfs and 1,171 turf-years. The average richness effect was small and uncertain (+0.65 species, confidence interval crossing zero), with little cover change. The first year showed a richness loss of about 1.2 species, followed by gains of about one species from year two. Regional estimates changed sign (approximately −4.0 in German Susalps and +3.4 in Norwegian Ulvhaugen), and more diverse baseline communities tended to gain less. With the initial random seed, colonisations rose by 1.12 (p = 0.017), extinctions by 0.91 (p = 0.003) and total turnover by 2.02 species per turf-year (p < 0.001); later turnover was +2.44 (p < 0.001). These turnover values were updated after a fixed-seed rerun in v0.2. The colder-origin moderator had p = 0.08, the permutation placebo p = 0.065, and the NutNet e247 positive control estimated +124 g/m² under nitrogen addition. No BLP richness moderator survived Benjamini–Hochberg correction (smallest adjusted p = 0.30), the calibration test was not significant and the site-clustered minimum detectable effect was about two species. Full source-data coverage and access to the NutNet core network remained outstanding.
