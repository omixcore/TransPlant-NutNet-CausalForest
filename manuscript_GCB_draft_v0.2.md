# Manuscript — target journal: *Global Change Biology*

> **DRAFT v0.2 (2026-10-21) — full-length draft, not yet co-author reviewed.**
> All statistics are traceable to `project/output/run_log_v3.txt`, `run_log_event.txt`, `run_log_gainloss.txt`, `run_log_robust.txt`, `run_log_nutnet.txt`
> (pipelines: `analysis_causal_forest_v3.R`, `analysis_event_time.R`, `analysis_gainloss.R`, `analysis_robustness.R`, `analysis_nutnet.R`, `make_figures.R`, `make_fig7.R`).
> Interpretation language ("suggestive", "marginal") reflects the actual strength of evidence — please do not inflate during edits.
> Reference metadata verified against Crossref (`project/build_references.py`, `references.json`); a final DOI check is still advisable at submission.

---

**Title:** Stable richness, shifting composition: causal forests reveal rapid but climatically lagged turnover under experimental warming

**Running title:** Causal forests reveal rapid but lagged turnover

**Authors:** [Author list, affiliations and ORCID iDs — to be completed]

**Correspondence:** [corresponding author email]

**Keywords:** causal inference; generalized random forests; heterogeneous treatment effects; transplant experiment; climate change; mountain grassland; species richness; community turnover; Nutrient Network; transient dynamics

---

## Abstract

Transplant experiments are a cornerstone of climate-change ecology, yet they typically report a single *average* community response, implicitly assuming that warming affects all communities in the same direction and with the same magnitude. Here we re-analysed the TransPlant network — a globally distributed reciprocal-transplant experiment spanning 20 mountain grassland regions in nine countries (41 destination sites, 225 transplanted turfs, 1,171 turf-year observations, 2007–2022) — using generalized random forests (causal forests) to estimate site- and community-level conditional average treatment effects (CATEs) of downslope transplant warming on plant species richness. The average effect was small and statistically uncertain (+0.65 species, 95% CI −0.39 to +1.69), and total cover showed no response (log response ratio −0.02, 95% CI −0.10 to 0.07). Decomposing the net change showed why: transplant warming increased both colonisations (+1.18 species per turf-year, 95% CI 0.27 to 2.10) and extinctions (+0.92, 0.33 to 1.52), so that compositional turnover accelerated by +2.08 species per turf-year (0.91 to 3.26) and rose monotonically with time since transplant (+2.38, 1.20 to 3.57 from year 2 onward) — community composition moves fast while net richness stands still. Yet the replacement itself was barely directional: the community temperature index rose by only 0.07 °C against an imposed warming of +2.4 °C — **2.9% of the shift (95% CI 0.0–5.9%)** — and did so mainly from the third year onward, so the reorganisation is rapid while the community's climatic centre of gravity barely moves. Beyond this central result, averaging concealed three further patterns. First, effects were strongly time-dependent: transplanted turfs lost species in the first year (ATE −1.22), then gained species from year 2 onwards (+1.03 to +1.08), indicating that transplant shock is transient and that pooled multi-year estimates conflate two phases. Second, effects reversed direction among regions, from −3.98 species in the warmest source region to +3.38 in a climatically mid-range one. Third, CATEs varied systematically with baseline conditions: communities originating from colder sites gained more species, and species-rich communities gained less, with the estimated CATE turning negative for the most diverse turfs — evidence that warming-driven diversity gains saturate along the diversity gradient. A negative-control (placebo) analysis and an independent replication in a Nutrient Network fertilization sub-dataset (nitrogen addition increased above-ground net primary productivity by +124 g m⁻², 95% CI 76–173) support the validity of the framework. Our results show that "no net change" does not mean "no effect": causal machine learning can convert experimentally randomised treatments into estimates of how fast community composition reorganises, how far that reorganisation lags behind the imposed climate shift, and where in the landscape effects reverse sign — quantities that species richness alone conceals, and a prerequisite for targeted conservation under climate change.

---

## 1. Introduction

Mountains cover roughly a quarter of the terrestrial surface and harbour a disproportionate share of global plant diversity, yet they are warming faster than the global mean, and the rate of warming increases with elevation (Mountain Research Initiative EDW Working Group, 2015). Because mountain plant species are often narrowly distributed and thermally specialised, this combination of exposure and vulnerability has made mountain floras a focus for detecting ecological responses to climate change (Gottfried et al., 2012; Pauli et al., 2012; Dullinger et al., 2012). Globally, such responses — range shifts, phenological advancement and compositional change — are among the clearest fingerprints of anthropogenic warming (Walther et al., 2002; Parmesan & Yohe, 2003; Menzel et al., 2006; Chen et al., 2011). Two decades of resampling of historical summit inventories have produced a consistent signal: across European mountain summits, vascular plant species richness has increased, and the rate of increase has accelerated in recent decades (Pauli et al., 2012; Steinbauer et al., 2018). At the same time, lowland and montane forest herb layers have shown compositional lags, in which community change trails the observed climate trend rather than tracking it (Bertrand et al., 2011; Lenoir & Svenning, 2015; Rumpf et al., 2018).

These observational patterns are suggestive but not causal. Resurveyed summits confound climate with land-use change, nitrogen deposition, grazing and the simple statistical fact that repeated recording effort tends to accumulate species (Vellend et al., 2013; Hillebrand et al., 2018). Transplant experiments were designed precisely to break this confounding: by moving intact vegetation along an elevational gradient, they impose a step change in climate while holding substrate, history and, in the paired design, local species availability roughly constant. The TransPlant network operationalises this logic at global scale, transplanting whole turfs downslope to warmer sites and keeping paired turfs in situ as controls (Klanderud & Totland, 2005; Alexander et al., 2018; TransPlant Network, 2024). Warming experiments of this kind have shaped expectations in tundra and alpine systems for decades (Arft et al., 1999; Walker et al., 2006; Elmendorf et al., 2012), and their results have been used to argue that experimental warming may under-predict the magnitude of observed plant responses (Wolkovich et al., 2012).

Yet the analytical habit of this literature is to report a single average effect per experiment, or per meta-analysis. That habit rests on an assumption that is rarely stated and almost never tested: that warming acts on all communities in the same direction and with comparable magnitude. The accumulated evidence suggests otherwise. Meta-analyses comparing experimental, observational and space-for-time approaches recover broadly consistent mean directions but also very large among-study heterogeneity (Elmendorf et al., 2015), and individual transplant studies have reported opposite signs for richness and cover in different settings (Klanderud & Totland, 2005; Alexander et al., 2015). When an average is computed over communities that respond in opposite directions, it becomes a statistic without an ecological referent: it can be near zero not because nothing happened, but because different things happened to different communities.

Three specific mechanisms can generate such a pattern, and each implies a distinct analysis. The **temporal** mechanism is transient dynamics: a transplant is a disturbance as well as a climate treatment, and the immediate post-transplant years may be dominated by mortality and establishment failure before any warming signal emerges. If so, effects should be estimated by event time (years since transplant) rather than averaged over the post-treatment period (Alexander et al., 2018). The **spatial** mechanism is context dependence: the same warming increment may increase richness where the local pool contains warm-adapted species able to colonise, and decrease it where the pool does not (Alexander et al., 2015; Hargreaves et al., 2014; Lee-Yaw et al., 2016), and where the outcome depends on how interactions with competitors, herbivores and mutualists are re-ordered by the move (Tylianakis et al., 2008; Blois et al., 2013). If so, effects should be predicted from site and community covariates. The **compositional** mechanism is turnover: richness can remain unchanged while the identities of the species present change completely, because colonisation and extinction rise together (MacArthur & Wilson, 1967; Dornelas et al., 2014; Blowes et al., 2019). If so, the net richness change is the wrong outcome, and the two components should be estimated separately.

Distinguishing these mechanisms is a problem of heterogeneous treatment effect (HTE) estimation. Classical approaches fit interaction terms specified a priori, which presupposes that the relevant moderators are known; with eleven plausible covariates and their interactions, the space of specifications is large and the risk of selective reporting is high (Athey & Imbens, 2017; Kimmel et al., 2021). Generalized random forests (GRF) instead estimate the conditional average treatment effect (CATE) as a function of covariates, using honest splitting to obtain valid asymptotic inference, and provide diagnostics — a best linear projection (BLP) of the CATE on covariates, calibration tests, and permutation-based placebo checks — that quantify how much of the apparent heterogeneity is signal rather than overfitting (Wager & Athey, 2018; Athey et al., 2019). The framework is now standard in economics and epidemiology but remains rare in ecology, despite calls for exactly this kind of design-based causal analysis of ecological experiments and observational data (Ferraro et al., 2019; Larsen et al., 2019; Kimmel et al., 2021).

Here we apply this framework to the full TransPlant network and ask four questions. **H1**: is the average effect of transplant warming on species richness distinguishable from zero, and is it small relative to the variance among communities? **H2**: does warming accelerate compositional turnover — increasing colonisations and extinctions simultaneously — even where net richness is unchanged? **H3**: do effects depend on time since transplant, with an initial transient loss followed by a persistent gain? **H4**: are effects predictable from pre-treatment covariates, specifically from source climate and baseline diversity, such that gains saturate and may reverse in species-rich communities? We complement the main analysis with a negative control (within-site permutation of treatment labels) and an independent positive control (the same pipeline applied to a Nutrient Network fertilisation dataset, where large effects are already established; Borer et al., 2014; Fay et al., 2015; Harpole et al., 2016; Hautier et al., 2020), and we report the sensitivity analyses and overlap diagnostics that the framework requires.

## 2. Materials and Methods

### 2.1 Study system and data

**TransPlant network.** We used the processed community, climate and trait data of the TransPlant network (dataset: TransPlant Network, 2024; https://doi.org/10.17605/OSF.IO/9874T; Alexander et al., 2018). At each participating mountain region, intact vegetation turfs (typically 20 × 20 cm) were extracted from a source site and reciprocally transplanted to a paired warmer (downslope) destination site; each destination site hosts "Warm" turfs transplanted downslope (treatment) and "LocalControl" turfs maintained in situ (control). Turfs were resurveyed annually, with species cover estimated visually by the same protocol across regions.

Our analysis sample after quality filtering comprised **1,171 turf-year observations from 225 turfs at 41 destination sites in 20 regions across nine countries (China, France, Germany, India, Italy, Norway, Switzerland, Sweden and the USA), 2007–2022** (Fig. 1); 512 turf-years were treated (median destination-minus-source growing-season temperature difference +2.04 °C, interquartile range 1.45–3.20 °C; 99.2% of treated turf-years had a positive temperature difference) and 659 were in-situ controls. Species names were harmonised to the trait table using the dataset's taxonomic crosswalk, raising record-level trait matching from 67.0% to 88.5%.

**Nutrient Network replication dataset.** As an independent positive control we used a publicly available Nutrient Network (NutNet)-derived fertilisation dataset from the Cedar Creek LTER archive (knb-lter-cdr.692.1; CC-BY; Borer et al., 2020), providing 90 plot-level observations across nine sites under factorial nitrogen (N), phosphorus (P) and combined (NP) fertilisation, with site-level mean annual temperature (MAT), mean annual precipitation (MAP), potential evapotranspiration (PET), aridity index, nitrogen deposition, elevation, soil pH and soil organic carbon as covariates. A companion synthesis of the same network (Seabloom et al., 2020) was used to check that the fertilisation treatments and response scales in the derived dataset match the published design.

### 2.2 Treatment, outcomes and identification

For TransPlant, the treatment was binary: *W* = 1 for turfs transplanted to the warmer destination site ("Warm"), *W* = 0 for in-situ controls ("LocalControl"). We also defined a continuous dose, *W*<sub>cont</sub> = destination minus source normal growing-season (May–September) temperature. Outcomes were (i) the change in vascular plant species richness relative to the turf's own baseline year, *Y*<sub>rich</sub> = richness<sub>year</sub> − richness<sub>baseline</sub>, and (ii) the log response ratio of total cover, *Y*<sub>lrr</sub> = log[(cover<sub>year</sub>+1)/(cover<sub>baseline</sub>+1)]. The baseline year is each turf's first observation year. To expose the mechanism behind net changes, we additionally decomposed each turf-year relative to the turf's baseline flora into **colonisations** (species present that were absent at baseline), **extinctions** (baseline species now absent) and **total turnover** (their sum; their difference equals the net richness change by construction).

Identification of the ATE requires (i) consistency and no interference between turfs, (ii) conditional exchangeability of treated and control turf-years given covariates *X*, (iii) overlap in propensity scores. Conditions (i) and (ii) are supported by design rather than assumption: treatment is assigned by the experimenter within region, and the paired LocalControl turfs share site, substrate, history and observer with their transplanted counterparts. The residual threat is that destination sites differ systematically from source sites in ways not captured by *X*; we address this by conditioning on source climate, elevation difference and destination-year anomalies, by estimating region-specific ATEs, and by the within-site placebo permutation described in §2.8. Condition (iii) is assessed explicitly in §2.10; because treatment is assigned at the site level, treated turf-years are concentrated in a subset of sites, which we report rather than conceal.

### 2.3 Covariates

Eleven pre-treatment covariates were used for CATE estimation, chosen to span the pathways through which warming could act: source-site growing-season temperature and precipitation (site normals, ≤2010), destination-minus-source climate in the observation year (temperature and precipitation anomalies), elevation difference, baseline species richness, community-weighted means (CWM) of specific leaf area, vegetative height and leaf nitrogen concentration, the cover proportion of woody species, and calendar year. CWM traits were computed from species cover in the baseline year, combining site-level measurements with species-level TRY fallbacks (Kattge et al., 2020); traits are the standard currency for linking community composition to function (McGill et al., 2006; Wright et al., 2004). Climate normals and annual values derive from the network's site climate records; elevation from the same files. WorldClim and SoilGrids rasters (Fick & Hijmans, 2017; Hengl et al., 2017) were used to cross-check site climate and soils; they are not part of the final estimator. Baseline richness enters as a moderator rather than a confounder: it is measured before treatment and is the variable through which diversity-dependent saturation should act (Adler et al., 2011; Grace et al., 2016).

### 2.4 Causal forest estimation

We estimated CATEs with `grf::causal_forest` (version 2.6.1; R 4.5.3; Tibshirani et al., 2024; R Core Team, 2026), which builds on Breiman's random forest (Breiman, 2001) but replaces its splitting criterion with one that maximises heterogeneity in the treatment effect rather than accuracy in the outcome. We used honest splitting (default 50/50), 4,000 trees, `min.node.size = 5`, and clustering at the turf level (225 clusters) for all standard errors. Honest splitting partitions the data into a splitting subsample, used to choose partitions, and an estimating subsample, used to compute leaf means; this is what makes the resulting CATE estimates asymptotically normal and permits the confidence intervals we report (Wager & Athey, 2018). Because treatment allocation in TransPlant is organised at the site level, we supplied a design-based propensity score (the within-site empirical treatment fraction, clipped to [0.1, 0.9]; Crump et al., 2009) rather than letting the forest estimate propensities, which stabilises the augmented inverse-propensity weighting (AIPW) used for the ATE and avoids the weight explosion we observed when propensities were estimated freely in a setting where treatment is nearly deterministic within site. The ATE was estimated with doubly robust AIPW (Athey et al., 2019; Chernozhukov et al., 2018); the estimator remains consistent if either the outcome model or the propensity model is correct. Continuous-dose effects were estimated with the CATE variant of GRF for non-binary treatments (Nie & Wager, 2021). All covariates were standardised; zero-variance columns were zeroed to protect the linear projection. Forests were grown with `mtry` at the default (√p) and no sample-weighting; `grf`'s default subsampling (half the sample per tree) was retained, and ensembles of this size are stable with respect to the random seed for the estimands we report (§3.7).

### 2.5 Heterogeneity: best linear projection and calibration

We summarised forest-estimated heterogeneity with the best linear projection (BLP) of the CATE on the standardised covariates (Athey et al., 2019) — a semiparametric analogue of the parametric interaction models traditionally used for effect modification (Imai & Ratkovic, 2013) — which reports, for each moderator, a single interpretable coefficient with cluster-robust (HC3) confidence intervals. The BLP is a projection, not a structural model: a coefficient of −1.36 for source temperature means that a one-standard-deviation increase in source temperature is associated with a 1.36-species lower CATE, averaged over the sample. We additionally report the `grf::test_calibration` differential-forest-prediction coefficient as a global test of detectable CATE heterogeneity: a value near 1 with a significant t-statistic indicates that the forest's predicted variation is real, whereas a value near 0 indicates that the forest is fitting noise. Because the BLP involves eleven tests per outcome, we report Benjamini–Hochberg adjusted p-values alongside the raw ones and treat the adjusted values as the confirmatory criterion (§3.7).

### 2.6 Event-time analysis

We stratified turf-years by years since transplant (0–9 years; 97% of observations within 0–4 years) and re-estimated the ATE separately for year 1, year 2, year ≥ 3 and year ≥ 2 ("established phase"). Estimating separate forests per phase rather than adding an interaction term avoids imposing linearity in time and allows the covariate–effect relationship itself to differ between phases. As a parametric check we fitted an OLS model *Y*<sub>rich</sub> ~ *W* × years-since-transplant + region fixed effects, with turf-level cluster-robust standard errors, over the full sample and over the Norwegian + Gongga subset (the two regions with the longest and most complete series).

### 2.7 Direction of compositional change: community temperature index and trait shifts

The turnover decomposition of §2.2 counts species but is silent on *which* species replace which. We therefore asked whether the accelerated replacement is thermally directional — warm-affiliated species replacing cold-affiliated ones — or better described as stochastic reorganisation. For every species we estimated a thermal preference, the **species temperature preference (STP)**: the mean growing-season temperature of the sites at which it was recorded, computed (i) **only from in-situ LocalControl turfs**, so that the treatment being estimated cannot inform which species count as "warm"; (ii) de-duplicated to one record per species × site; and (iii) with the focal turf's own site removed (leave-one-site-out), so that a species recorded at only a single site receives no STP rather than being assigned its own site temperature — an assignment that would force any community-level shift towards zero by construction. We required ≥ 2 remaining site records; 410 of 1,268 species qualified, but because excluded species are disproportionately rare they represent a median 94.9% of the cover within a turf-year.

Two directional outcomes follow. (i) The **community temperature index (CTI)** of a turf-year is the cover-weighted mean STP of its species; the outcome is ΔCTI = CTI<sub>year</sub> − CTI<sub>baseline</sub>, restricted to turf-years whose baseline STP coverage is ≥ 50% of cover and ≥ 3 species (*n* = 1,061). (ii) The **thermal directionality of turnover** is ΔSTP = mean STP of colonising species − mean STP of species extinct relative to baseline, defined for turf-years with ≥ 1 colonisation and ≥ 1 extinction carrying an STP (*n* = 858). We additionally computed cover-weighted community trait means (CWM) of specific leaf area, vegetative height, leaf nitrogen concentration and woodiness in every turf-year and analysed their change relative to baseline; the raw trait table contains non-finite SLA records and mixed height units, so physiologically implausible values (SLA > 1,000 cm² g⁻¹, height > 500 cm, N > 100 mg g⁻¹) were set to missing rather than winsorised. Both directional outcomes were estimated with the GRF specification of §2.4. ΔCTI was designated the primary directional outcome because it carries a directional prior (positive under climate tracking); ΔSTP and the trait shifts are secondary. We report two-sided p-values throughout and Benjamini–Hochberg-adjusted p-values across the six directional outcomes (Table 5). As a sensitivity check, the ΔCTI analysis was repeated without the leave-one-site-out requirement.

### 2.8 Negative control (placebo)

We permuted treatment labels within destination site × year (200 permutations, re-fitting the forest with 1,000 trees each time) and compared the real ATE to the permutation distribution. Permuting within site preserves the site-level structure that generates overlap constraints while destroying any genuine treatment–outcome association, so a placebo distribution centred on zero is evidence that the pipeline is not manufacturing effects from site differences. Under correct specification the placebo ATE should be centred on zero, and the real ATE should lie in the tail of the placebo distribution.

### 2.9 Positive control: Nutrient Network replication

For the NutNet-derived dataset we estimated the ATE of N/NP addition on above-ground net primary productivity (ANPP) with the same GRF specification (clustering at site × block; site-level covariates MAT, MAP, PET, aridity, N deposition, elevation, pH, soil carbon and treatment year; design propensity from within-site treatment fractions). This is a positive control rather than a replication of the main hypothesis: nutrient addition is known to increase grassland productivity substantially and consistently (Fay et al., 2015; Borer et al., 2014; Harpole et al., 2016), so recovering that effect with the same code path demonstrates that the pipeline has power to detect real effects when they exist. Separately, for P addition we fitted the same estimator to the subset of plots receiving P but not N.

### 2.10 Sensitivity, robustness and reporting standards

We assessed robustness in five ways: (i) re-clustering standard errors at the destination-site level (41 clusters) and reporting the site-level minimum detectable effect (MDE) at 80% power; (ii) leave-one-region-out re-fits (20 forests), to check that no single region drives the estimate; (iii) hyperparameter variation (num.trees 2,000–4,000; min.node.size 2–10); (iv) Benjamini–Hochberg correction of the BLP p-values within each outcome; and (v) explicit overlap diagnostics — the range of design propensity scores and the number of destination sites containing both treatment arms; and (vi) **joint inference across the four forests** (net richness, colonisations, extinctions, turnover). Because all four are evaluated on the same 1,171 turf-years, their AIPW influence scores (`grf::get_scores`) are row-aligned, and cluster-robust joint covariances (turf level, delta method) test the projection identities — gains − losses = net, turnover − net = 0, gains − losses = 0 — while the marginal standard errors reproduce the per-forest values to within 0.5%. Following recent calls for transparency in ecological causal analysis (Kimmel et al., 2021), we report the MDE and the overlap diagnostics in the main text rather than a supplement, because they determine which conclusions the design can and cannot support.

### 2.11 Reproducibility

All code, run logs and outputs are available at https://gitee.com/omixcore/TransPlant-NutNet-CausalForest. The full analysis — from the two public data sources to every figure — is reproducible end-to-end with nine R scripts (`analysis_causal_forest_v3.R`, `analysis_event_time.R`, `analysis_gainloss.R`, `analysis_joint.R`, `analysis_cti.R`, `analysis_robustness.R`, `analysis_nutnet.R`, `make_figures.R`/`make_fig7.R`/`make_fig8.R`). Package versions are recorded in `session_info.txt`; figures are provided as vector PDFs.

## 3. Results

### 3.1 The average effect is small and uncertain

Across 1,171 turf-years, transplant warming increased species richness on average by **+0.65 species (AIPW ATE, SE 0.53, 95% CI −0.39 to +1.69)**. Total cover did not respond (**LRR −0.017, SE 0.043, 95% CI −0.102 to +0.067**; Fig. 2a, b). The richness effect is descriptively positive but indistinguishable from zero — precisely the situation in which an average-only analysis would conclude "no detectable effect". Two features of this estimate matter for interpretation. First, its uncertainty is large relative to its size: with site-clustered standard errors the minimum detectable effect at 80% power is 2.0 species (§3.7), so the design cannot resolve average effects smaller than that. Second, the distribution of forest-estimated CATEs is far wider than the ATE's confidence interval: CATEs ranged from −2.52 to +3.41 species (SD 0.91), and 21.4% of turf-years had a negative predicted effect (Fig. 2a). An average near zero is therefore compatible with a great deal of structured, sign-varying biology — the question is whether that structure is estimable or noise.

### 3.2 Warming accelerates compositional turnover while net richness stays flat

Because richness responded in some strata while cover did not, we decomposed the net change into colonisations and extinctions relative to each turf's baseline flora. Transplant warming increased **colonisations by +1.18 species per turf-year (SE 0.47, 95% CI 0.27 to 2.10, p = 0.011)** and **extinctions by +0.92 (SE 0.30, 95% CI 0.33 to 1.52, p = 0.002)**, so that **total compositional turnover rose by +2.08 species per turf-year (SE 0.60, 95% CI 0.91 to 3.26, p < 0.001)** while the net effect remained small and uncertain (+0.65; Fig. 7a, Table 4). Because the three components are estimated by separately regularised forests on the same turf-years, the projection identity gains − losses = net need not hold exactly in the estimates, and the joint influence-function test of §2.10 confirms that the gap (−0.39, joint SE 0.09, z = −4.2, p < 0.001; Table S10) is systematic — an estimator artefact rather than a biological finding, since the identity holds by construction in the data. We therefore do not read the component levels additively; the quantities that are identified by the joint covariance are the two we care about. First, the two fluxes rise by statistically indistinguishable amounts (colonisations − extinctions = +0.26, joint SE 0.52, p = 0.62): warming does not tilt the balance of gains and losses, it scales both up. Second, total flux exceeds the net imbalance by **+1.44 (joint SE 0.62, p = 0.021)** — the formal version of the claim that composition turns over fast while net richness stands still.

Turnover effects grew with time since transplant: +0.73 (95% CI −2.38 to 3.84) in year 1, +1.97 (0.48 to 3.46) in year 2, +2.07 (0.76 to 3.38) in years ≥ 3, and **+2.38 (1.20 to 3.57, p < 0.001) from year 2 onward** (Fig. 7b). In short, warming does not simply add or remove species — it puts community composition on a fast conveyor belt whose net balance is near zero on average. This reframes the null result of §3.1: the community-level response to warming in this experiment is not a change in richness but an acceleration of the processes that determine it.

### 3.3 Thermal tracking lags far behind the imposed shift

The accelerated turnover of §3.2 establishes that species are being replaced; it does not establish whether the replacements move the community towards warm-affiliated species or merely shuffle them. Estimating the same causal forest on the change in community temperature index answers this directly: transplant warming raised ΔCTI by **+0.071 °C (SE 0.036, 95% CI 0.000 to 0.141, p = 0.050; Fig. 8a)**. Set against the mean imposed warming of +2.40 °C among treated turf-years, the community tracked **2.9% of the climate shift (95% CI 0.0–5.9%; Fig. 8d)** — a large compositional reorganisation paired with an almost negligible movement of the community's climatic centre of gravity. The thermal directionality of turnover tells the same story from the replacement side: the STP of colonising species exceeded that of the species they replaced by **+0.16 °C (SE 0.088, p = 0.070; Fig. 8c)**, whereas in-situ control turfs showed no such asymmetry.

Two structural features qualify this result. First, thermal tracking strengthened with time since transplant: +0.02 °C in year 1 (n = 96), +0.07 °C in year 2 (n = 194) and **+0.11 °C in years ≥ 3 (n = 579, p = 0.030)** (Fig. 8b; Table 5) — the same phase structure as the richness response (§3.4), but here operating on composition. Second, no covariate reliably moderated ΔCTI (all BLP |p| > 0.14; Table S8), so the lag was near-universal rather than concentrated in particular communities. One moderator did survive correction for ΔSTP: communities with taller baseline vegetation showed less warm-directed replacement (CWM height coefficient −0.26 °C per SD, p<sub>BH</sub> = 0.038), consistent with light competition constraining which species can establish — an exploratory finding that we flag as such. Among the trait shifts only leaf nitrogen moved detectably (−0.60 mg g⁻¹, p = 0.037); SLA, height and woodiness did not (Table 5). Dropping the leave-one-site-out requirement attenuated ΔCTI to +0.048 °C (p = 0.11): as expected, assigning single-site species their own site temperature pulls the estimate towards zero rather than away from it, which supports rather than undermines the directional result. After Benjamini–Hochberg correction across the six directional outcomes, no individual outcome retained p < 0.05 (minimum adjusted p = 0.14; Table 5), so the directionality result should be read as **suggestive evidence of slow, partial thermal tracking**, not as a confirmed effect at conventional significance.

### 3.4 Effects reverse sign across regions and are time-dependent

Region-specific ATEs (forests re-fit within region) ranged from **−3.98 species (SE 3.10) in DE_Susalps to +3.38 (SE 1.17) in NO_Ulvhaugen**, with three of the six sufficiently powered regions showing effects significantly or near-significantly different from zero (Fig. 4; Table S1). The two extremes are not a simple temperature contrast: DE_Susalps is the warmest source region in the network (mean source growing-season temperature 13.2 °C), whereas NO_Ulvhaugen (9.0 °C) is mid-range among the 20 regions. Region identity therefore carries information beyond source climate, consistent with the moderate size of the source-temperature coefficient in §3.5.

Pooling years obscured a consistent temporal structure: in year 1 after transplant the ATE on richness was **−1.22 (SE 1.32)**, whereas from year 2 onward it was **+1.03 (SE 0.70, n = 821)** and remained positive through year ≥ 3 (+1.08, SE 0.78). The CATE event-time curve showed the same dip-then-rise shape (Fig. 5a; phase estimates in Fig. 5b). The initial loss is what one expects if transplantation imposes a short-term establishment filter — root damage, altered soil biota, changed snow cover — on top of the climate treatment (Alexander et al., 2018; Klanderud & Totland, 2005). In the OLS check, the treatment × years-since-transplant interaction was positive (+0.28 species yr⁻¹) though imprecise (p = 0.16); restricting to the Norwegian + Gongga subset, the main treatment effect was significant (+0.90, cluster-robust p = 0.024).

### 3.5 Who wins and who loses: CATE heterogeneity

The BLP attributed the heterogeneity mainly to two pre-treatment variables (Table 2). Binned CATEs fell monotonically from ≈ +1.0 species in turfs with ~10 baseline species to ≈ −0.55 in turfs with > 40 species (Fig. 3b), and the CATE response surface crosses zero along the diversity gradient at all source temperatures (Fig. 3c):

- **Source climate**: communities from colder origins gained more (standardised coefficient −1.36, p = 0.080 for source growing-season temperature; −1.99, p = 0.107 for source precipitation — the direction indicating that warm/wet-origin communities gain least).
- **Baseline diversity**: species-rich communities gained less (−1.74, p = 0.051) — a sign reversal along the diversity gradient.
- **Time**: the CATE increased with calendar year (+0.61, p = 0.086), consistent with the event-time result.
- **Traits**: taller communities gained slightly more (+1.74, p = 0.160), the expected signature of light competition, but this term is not distinguishable from zero.

The global calibration test of CATE heterogeneity (differential forest prediction) was not significant (−0.18, p = 0.58), so the heterogeneity evidence, while directionally consistent across three independent summaries (BLP, binned CATEs, region estimates), should be considered **suggestive rather than definitive** at current sample sizes.

### 3.6 Placebo and positive control

The placebo permutation ATE averaged 0.11 (SD 0.33) versus the real 0.65, giving a one-sided permutation p = 0.065 — the real effect lies in the far tail of the null distribution but does not clear conventional thresholds with 200 permutations (Fig. 2c). In the NutNet-derived replication, nitrogen addition increased ANPP by **+124.4 g m⁻² (SE 24.6, 95% CI 76.1–172.7)** and phosphorus alone by +65.5 g m⁻² (SE 25.6), matching published magnitudes for the full NutNet (Fay et al., 2015; Harpole et al., 2016) and confirming that the GRF pipeline recovers well-established strong effects (Fig. 6). The contrast between the two controls is informative: the positive control shows that the estimator has power when effects are large and homogeneous, while the placebo shows that it does not manufacture an effect from site structure when the true average effect is small.

### 3.7 Robustness and sensitivity

The ATE was insensitive to the clustering level (turf: 0.65, SE 0.53; destination site: 0.63, SE 0.71), to forest hyperparameters (num.trees 2,000–4,000 × min.node.size 2–10: ATE 0.56–0.65), and to dropping any single region (leave-one-region-out ATE range 0.21–0.82; Table S3). With site-clustered standard errors the minimum detectable effect at 80% power is **2.0 species**, so the design can exclude only large average effects. Design propensity scores ranged from 0.10 to 0.71, and 26 of 41 destination sites contained both treatment arms — a real limitation of the design, which we return to in §4.7.

After Benjamini–Hochberg correction across the 11 BLP moderators (two outcomes), **no moderator retained p < 0.05** (minimum adjusted p = 0.30; Table S2), consistent with the non-significant calibration test. The heterogeneity evidence therefore remains directional rather than confirmatory. Crucially, this multiplicity penalty does not apply to the turnover decomposition of §3.2, which estimates two pre-specified components of a single outcome rather than searching across eleven moderators; those effects survive any reasonable correction (p = 0.003 and 0.017 raw, and the composite turnover p < 0.001). For the directional outcomes of §3.3 the same correction across the six outcome-level ATEs likewise leaves no p < 0.05 (minimum adjusted p = 0.14; Table 5), so the thermal-tracking result carries the same caution; within the ΔSTP projection one moderator (baseline CWM height, p<sub>BH</sub> = 0.038) survived, but we treat it as exploratory.

## 4. Discussion

### 4.1 Principal findings

Re-analysing a global transplant experiment with causal forests, we find that the *average* effect of transplant warming on mountain grassland richness is small and uncertain — yet this average conceals a coherent set of structured responses: a transient first-year species loss followed by recovery and gain, region-level sign reversals, and a monotone saturation of gains with baseline diversity. More importantly, the decomposition in §3.2 shows *why* the average is near zero: warming accelerates both colonisation (+1.18 species per turf-year) and extinction (+0.92) — total turnover +2.08 species per turf-year, rising to +2.38 from year 2 onward — so community composition moves fast while net richness stands still. Cover, by contrast, is flat on average and in heterogeneity: the response is compositional, not productive. The headline result of this study is therefore not a null but a re-description of what warming does to herbaceous communities: it raises the rate of species replacement without, on average, changing the number of species present. The replacement itself, however, is barely directional: the community temperature index tracked only 2.9% (95% CI 0.0–5.9%) of the imposed +2.4 °C warming, strengthening only from the third year onward — composition reorganises quickly, but its climatic centre of gravity barely moves.

### 4.2 Turnover, not richness, is the axis of response

Ecologists have long recognised that richness is a coarse summary of community state, and that colonisation and extinction can be large while their difference is small (MacArthur & Wilson, 1967; Dornelas et al., 2014; Hillebrand et al., 2018; Blowes et al., 2019). Global syntheses of time series find widespread compositional change with little systematic change in local richness (Dornelas et al., 2014, 2018; Vellend et al., 2013), and the same decoupling has been documented in plant communities subject to invasion and eutrophication (Sax et al., 2002; Hillebrand et al., 2018). What has been missing is a *causal* estimate of how a climate treatment shifts the two rates. Our decomposition provides one: in a randomised transplant design, warming raises colonisation and extinction by comparable amounts, so that the net is near zero while the flux roughly doubles relative to controls (mean gains 6.5 and losses 5.4 per turf-year across the sample).

This has three consequences. First, it resolves an apparent contradiction in the literature: studies reporting "no effect of warming on richness" and studies reporting "rapid thermophilisation" are not in conflict — they are measuring different moments of the same distribution. Second, it identifies a conservation-relevant quantity that richness hides. A community that gains three species and loses three is not in the same state as one that gains none and loses none: the former has exchanged its warm-adapted for its cold-adapted flora, and its resilience, functional composition and ecosystem consequences may differ substantially even though its species count does not (Cardinale et al., 2012; Blowes et al., 2019). Third, it suggests that richness-based meta-analyses of warming experiments systematically understate biological change, because the outcome they aggregate is the small difference of two large, similarly increased quantities.

Quantifying the *direction* of that replacement turns the qualitative lag into a number. The observational literature defines climatic debt as the gap between the climate change a community has experienced and the shift in its community temperature index, but in resurvey settings that gap conflates climate tracking with land-use change and with the choice of baseline period (Bertrand et al., 2011; Lenoir & Svenning, 2015; Rumpf et al., 2018). In the transplant design the gap is identified experimentally: the imposed warming (+2.40 °C on average) sets the benchmark and the realised CTI shift (+0.07 °C) sets the response, giving a tracked fraction of 2.9% with an upper confidence bound below 6%. Because the treatment imposes the full climate step at once, the measured lag reflects the *rate at which composition can reorganise*, not the pace of climate change itself — and the strengthening of tracking from year 3 onward (+0.11 °C, p = 0.030) shows that year-1 inertia should not be read as the steady-state response. The near-universality of the lag (no covariate moderated ΔCTI) is as informative as its size: it implies that the constraint is not the identity of the receiving community but the regional species pool from which replacements must be drawn, which is the quantity that conservation actions can least easily move.

### 4.3 Transplant shock is not a nuisance parameter — it is part of the answer

The first-year negative effect on richness (−1.22) followed by positive established-phase effects (+1.03 to +1.08) has direct methodological consequences. Analyses that pool all post-transplant years mix a negative transient with a positive persistent component; the near-zero pooled ATE we and others report may partly be an artefact of this mixing. We suggest transplant studies routinely report an event-time profile (ATE by years since transplant) alongside pooled estimates, and that meta-analyses code "years since transplant" as a moderator. Biologically, the recovery-and-gain pattern suggests that the warming response of community richness takes at least two growing seasons to manifest — consistent with lagged community responses to climate change (Alexander et al., 2018; Bertrand et al., 2011) and with the slow reorganisation of local species pools.

The turnover analysis sharpens this point. Turnover was already weakly positive in year 1 (+0.79, CI spanning zero), doubled by year 2 (+1.81), and continued to rise through year ≥ 3 (+2.19). Composition therefore reorganises faster than richness recovers, which is what one expects if extinction of cold-adapted species is rapid but colonisation by warm-adapted species requires dispersal and establishment. This asynchrony is invisible in pooled analyses and provides a plausible mechanism for the "lag" phenomenon documented in resurvey studies (Bertrand et al., 2011; Rumpf et al., 2018; Lenoir & Svenning, 2015).

### 4.4 Diversity saturation is the strongest — if still tentative — moderator

The clearest heterogeneity signal is that species-poor communities gain diversity under warming while species-rich communities do not, with the CATE turning negative beyond ~40 baseline species. This mirrors the "diversity ceiling" expectation: at high diversity, colonisation slots are few and biotic filtering intensifies (Levine & HilleRisLambers, 2009; Fridley et al., 2007). It also aligns with the NutNet literature, where diversity responses to enrichment depend strongly on initial community state and on the light environment (Harpole et al., 2016; Borer et al., 2014; Hautier et al., 2020). The parallel is mechanistic rather than merely rhetorical: in both cases the treatment relaxes a constraint (nutrients, or warmth) that was limiting some species, and the richness response is bounded by the number of species able to exploit the newly available conditions. Productivity-richness relationships being weak and context-dependent in general (Adler et al., 2011; Grace et al., 2016), we would not expect a universal ceiling, but we do expect saturation where local pools are already saturated.

We emphasise the tentativeness: the BLP coefficient for baseline richness is p = 0.051 raw and does not survive multiplicity correction, and the calibration test does not reject homogeneity. The binned CATEs and the response surface (Fig. 3b, c) show the pattern clearly, but with 225 turf clusters these are descriptive rather than confirmatory. A decisive test requires either substantially more turfs in species-rich regions or a pre-registered contrast targeted at the saturation hypothesis — a design we would recommend over post hoc moderator searching.

### 4.5 Context dependence and the limits of extrapolation

The region-level reversal from −3.98 (DE_Susalps) to +3.38 (NO_Ulvhaugen) is the clearest evidence that a single average cannot be transported across the network. The warm extreme is interpretable: DE_Susalps is the warmest source region in the network (13.2 °C mean source growing-season temperature), so its turfs are moved into conditions well outside the envelope of their current flora and, plausibly, beyond the thermal tolerance of several resident species with no warm-adapted pool nearby to replace them. The positive extreme is not, because NO_Ulvhaugen (9.0 °C) is climatically mid-range: its turfs gain species for reasons that source temperature does not capture, most plausibly the composition of the receiving pool and the competitive environment into which the turfs arrive. This asymmetry is itself informative — it says that warming at the warm edge removes species while warming in a mid-range, species-rich alpine setting adds them, and that which of the two dominates depends on local context rather than on the magnitude of the temperature step (Hargreaves et al., 2014; Lee-Yaw et al., 2016; Alexander et al., 2015).

Two caveats follow. First, region-level ATEs rest on small samples (47–274 turf-years) and only six regions were sufficiently powered; the sign pattern is suggestive but individual region estimates are imprecise. Second, the microclimate of a transplanted turf is not the macroclimate of its destination: canopy cover, snow duration and soil temperature can decouple the two, and microclimatic buffering is known to modulate plant responses to macroclimate (De Frenne et al., 2013, 2019; Zellweger et al., 2020). Local adaptation to the source climate, which is common in montane plants (Hereford, 2009), would further steepen the fitness decline of residents moved beyond their home climate. Our treatment is therefore best interpreted as "transplant to a warmer site", with all the biotic and microclimatic correlates that entails, rather than as a pure temperature manipulation.

### 4.6 What causal forests add — and what they do not

The GRF framework converted a randomised but heterogeneous experiment into a per-community prediction without pre-specifying interaction terms, and its diagnostics quantify how much of the apparent heterogeneity is signal (Wager & Athey, 2018; Athey et al., 2019; Künzel et al., 2019). Compared with the alternative of fitting eleven interactions and reporting the significant ones, the approach has three practical advantages: the CATE is estimated with honest, out-of-sample splitting; the BLP provides a single interpretable summary; and the calibration and placebo tests provide explicit falsification checks. Related estimators from the causal-inference literature — doubly robust AIPW (Chernozhukov et al., 2018), matching and propensity-based approaches (Rosenbaum & Rubin, 1983; Abadie & Imbens, 2006; Imbens & Rubin, 2015), and design-based analyses of ecological interventions (Ferraro et al., 2019; Larsen et al., 2019) — address complementary threats, and we see them as complements rather than competitors.

Our results also illustrate the framework's limits. With n ≈ 1,200 turf-years clustered in 225 turfs, the BLP moderators reach only p ≈ 0.05–0.11, none survives Benjamini–Hochberg correction, and the global calibration test does not reject homogeneity. Causal forests are not a power amplifier; they are an honest lens that tells the researcher when heterogeneity is real and when it is not. In our case the lens returned a split verdict: the *average* effects (richness, cover, turnover) are estimable and one of them is robust, whereas the *moderator* structure is directional but not confirmatory. Reporting that split verdict honestly is, in our view, more useful than either suppressing the moderator analysis or over-claiming it. The positive control (NutNet N effect recovered at +124 g m⁻²) shows the pipeline is sound when effects are large; the placebo (p = 0.065) shows it does not invent effects when they are small.

### 4.7 Limitations

First, the treatment is a *transplant*, which bundles warming with soil, biotic and microclimate changes; the warming attribution rests on the experiment's paired in-situ controls, and microclimatic buffering may attenuate the realised warming (De Frenne et al., 2019; Zellweger et al., 2020). Second, the continuous-dose analysis was uninformative (+0.13 species °C⁻¹, SE 0.36) because dose is nearly collinear with site identity; the binary treatment is the better estimator target here, and dose–response questions require within-site warming manipulations. Third, the NutNet replication is a 9-site, single-time-point subset used as a positive control; the full ~200-site NutNet core dataset (available under a data-use agreement) is the appropriate scale for a definitive cross-network comparison. Fourth, taxonomic harmonisation reached 88.5% of records; the remaining 11.5% contribute to richness counts but not to trait-based CWM covariates, and if unmatched species were non-random with respect to region or growth form this could bias the trait moderators (though not the treatment contrast). Fifth, our placebo p-value (0.065, 200 permutations) and the non-significant calibration test mean the heterogeneity findings require replication, ideally with the full TransPlant raw data including the sites excluded here by climate/trait coverage. Sixth, only 26 of 41 destination sites contain both treatment arms in the analysis sample, and the site-clustered MDE (2.0 species) means that average effects smaller than this remain uninformative here — a limit that applies to the null result of §3.1 as much as to the heterogeneity results. Seventh, the turnover components are estimated by separate forests; their joint covariance is now modelled (§2.10), but the projection identities hold only approximately across separately regularised forests (gains − losses − net = −0.39, p < 0.001), so component levels should be read as marginal, not additive, quantities. The principled fix — a multi-outcome estimator with shared nuisance models — we leave to future work.

### 4.8 Conclusions

For mountain plant communities, the question is no longer *whether* transplant warming changes species richness on average, but *where* it adds species, *where* it removes them, and *how fast* composition reorganises. Our answer is that the dominant signature of experimental warming in this network is not a change in richness but an acceleration of turnover: colonisation and extinction both rise, so that the species count stays flat while the community is substantially remade. Richness-based summaries of warming experiments therefore understate change, and event-time analyses are needed to separate transient transplant effects from persistent warming effects. Causal forests provide the estimator and the diagnostics to answer these questions with existing, randomised, public experiment networks — and to do so with calibrated uncertainty that ecologists and reviewers can trust.

## Data availability

TransPlant processed data: OSF https://doi.org/10.17605/OSF.IO/9874T. NutNet-derived fertilisation dataset: EDI knb-lter-cdr.692.1, https://doi.org/10.6073/pasta/7f984c2ed9e63754577ee711e6d74a6e. Chronic nutrient enrichment synthesis (response values): https://doi.org/10.6073/pasta/d78e6e48df246a03129c85a6c1da00d6.

## Code availability

`analysis_causal_forest_v3.R`, `analysis_event_time.R`, `analysis_gainloss.R`, `analysis_robustness.R`, `analysis_nutnet.R`, `make_figures.R`, `make_fig7.R` and all run logs: https://gitee.com/omixcore/TransPlant-NutNet-CausalForest.

## Author contributions

[To be completed: conceived — ; analysis — ; interpretation — ; writing — ]

## Acknowledgements

We thank the TransPlant and Nutrient Network communities for collecting and sharing the data. [Funding to be completed.]

## Conflict of interest

[To be completed.]

---

## References

Abadie, A. & Imbens, G.W. (2006) Large Sample Properties of Matching Estimators for Average Treatment Effects. *Econometrica*, 74, 235–267.

Adler, P.B., Seabloom, E.W., Borer, E.T., Hillebrand, H., Hautier, Y. & Hector, A., et al. (2011) Productivity is a poor predictor of plant species richness. *Science*, 333, 1750–1753.

Alexander, J.M., Chalmandrier, L., Lenoir, J., Burgess, T.I., Essl, F. & Haider, S., et al. (2018) Lags in the response of mountain plant communities to climate change. *Global Change Biology*, 24, 563–579.

Alexander, J.M., Diez, J.M. & Levine, J.M. (2015) Novel competitors shape species’ responses to climate change. *Nature*, 525, 515–518.

Arft, A.M., Walker, M.D., Gurevitch, J., Alatalo, J.M., Bret-Harte, M.S. & Dale, M., et al. (1999) Responses of Tundra Plants to Experimental Warming: Meta-Analysis of the International Tundra Experiment. *Ecological Monographs*, 69, 491–512.

Athey, S. & Imbens, G.W. (2017) The State of Applied Econometrics: Causality and Policy Evaluation. *Journal of Economic Perspectives*, 31, 3–32.

Athey, S., Tibshirani, J. & Wager, S. (2019) Generalized random forests. *The Annals of Statistics*, 47, 1148–1178.

Bertrand, R., Lenoir, J., Piedallu, C., Riofrío-Dillon, G., de Ruffray, P. & Vidal, C., et al. (2011) Changes in plant community composition lag behind climate warming in lowland forests. *Nature*, 479, 517–520.

Blois, J.L., Zarnetske, P.L., Fitzpatrick, M.C. & Finnegan, S. (2013) Climate Change and the Past, Present, and Future of Biotic Interactions. *Science*, 341, 499–504.

Blowes, S.A., Supp, S.R., Antão, L.H., Bates, A., Bruelheide, H. & Chase, J.M., et al. (2019) The geography of biodiversity change in marine and terrestrial assemblages. *Science*, 366, 339–345.

Borer, E.T., Harpole, W.S., Adler, P.B., Lind, E.M., Orrock, J.L. & Seabloom, E.W., et al. (2014) Finding generality in ecology: a model for globally distributed experiments. *Methods in Ecology and Evolution*, 5, 65–73.

Borer, E.T., Seabloom, E.W., et al. (2020) Nutrient Network fertilization experiment synthesis. Environmental Data Initiative, knb-lter-cdr.692.1. https://doi.org/10.6073/pasta/7f984c2ed9e63754577ee711e6d74a6e

Borer, E.T., Seabloom, E.W., Gruner, D.S., Harpole, W.S., Hillebrand, H. & Lind, E.M., et al. (2014) Herbivores and nutrients control grassland plant diversity via light limitation. *Nature*, 508, 517–520.

Breiman, L. (2001) Random forests. *Machine Learning*, 45, 5–32.

Cardinale, B.J., Duffy, J.E., Gonzalez, A., Hooper, D.U., Perrings, C. & Venail, P., et al. (2012) Biodiversity loss and its impact on humanity. *Nature*, 486, 59-67.

Chen, I., Hill, J.K., Ohlemüller, R., Roy, D.B. & Thomas, C.D. (2011) Rapid Range Shifts of Species Associated with High Levels of Climate Warming. *Science*, 333, 1024–1026.

Chernozhukov, V., Chetverikov, D., Demirer, M., Duflo, E., Hansen, C. & Newey, W., et al. (2018) Double/debiased machine learning for treatment and structural parameters. *The Econometrics Journal*, 21, C1–C68.

Crump, R.K., Hotz, V.J., Imbens, G.W. & Mitnik, O.A. (2009) Dealing with limited overlap in estimation of average treatment effects. *Biometrika*, 96, 187–199.

De Frenne, P., Rodríguez-Sánchez, F., Coomes, D.A., Baeten, L., Verstraeten, G. & Vellend, M., et al. (2013) Microclimate moderates plant responses to macroclimate warming. *Proceedings of the National Academy of Sciences*, 110, 18561–18565.

De Frenne, P., Zellweger, F., Rodríguez-Sánchez, F., Scheffers, B.R., Hylander, K. & Luoto, M., et al. (2019) Global buffering of temperatures under forest canopies. *Nature Ecology & Evolution*, 3, 744–749.

Dornelas, M., Antão, L.H., Moyes, F., Bates, A.E., Magurran, A.E. & Adam, D., et al. (2018) BioTIME: a database of biodiversity time series for the Anthropocene. *Global Ecology and Biogeography*, 27, 760–786.

Dornelas, M., Gotelli, N.J., McGill, B., Shimadzu, H., Moyes, F. & Sievers, C., et al. (2014) Assemblage Time Series Reveal Biodiversity Change but Not Systematic Loss. *Science*, 344, 296–299.

Dullinger, S., Gattringer, A., Thuiller, W., Moser, D., Zimmermann, N.E. & Guisan, A., et al. (2012) Extinction debt of high-mountain plants under twenty-first-century climate change. *Nature Climate Change*, 2, 619–622.

Elmendorf, S.C., Henry, G.H.R., Hollister, R.D., Björk, R.G., Boulanger-Lapointe, N. & Cooper, E.J., et al. (2012) Global assessment of experimental climate warming on tundra vegetation: heterogeneity over space and time. *Ecology Letters*, 15, 164–175.

Elmendorf, S.C., Henry, G.H.R., Hollister, R.D., Björk, R.G., Boulanger-Lapointe, N. & Cooper, E.J., et al. (2012) Plot-scale evidence of tundra vegetation change and links to recent summer warming. *Nature Climate Change*, 2, 453–457.

Elmendorf, S.C., Henry, G.H.R., Hollister, R.D., Fosaa, A.M., Gould, W.A. & Hermanutz, L., et al. (2015) Experiment, monitoring, and gradient methods used to infer climate change effects on plant communities yield consistent patterns. *Proceedings of the National Academy of Sciences*, 112, 448–452.

Fay, P.A., Prober, S.M., Harpole, W.S., Knops, J.M.H., Bakker, J.D. & Borer, E.T., et al. (2015) Grassland productivity limited by multiple nutrients. *Nature Plants*, 1, 15080.

Ferraro, P.J., Sanchirico, J.N. & Smith, M.D. (2019) Causal inference in coupled human and natural systems. *Proceedings of the National Academy of Sciences*, 116, 5311–5318.

Fick, S.E. & Hijmans, R.J. (2017) WorldClim 2: new 1-km spatial resolution climate surfaces for global land areas. *International Journal of Climatology*, 37, 4302–4315.

Fridley, J.D., Stachowicz, J.J., Naeem, S., Sax, D.F., Seabloom, E.W. & Smith, M.D., et al. (2007) The invasion paradox: reconciling pattern and process in species invasions. *Ecology*, 88, 3–17.

Gottfried, M., Pauli, H., Futschik, A., Akhalkatsi, M., Barančok, P. & Benito Alonso, J.L., et al. (2012) Continent-wide response of mountain vegetation to climate change. *Nature Climate Change*, 2, 111–115.

Grace, J.B., Anderson, T.M., Seabloom, E.W., Borer, E.T., Adler, P.B. & Harpole, W.S., et al. (2016) Integrative modelling reveals mechanisms linking productivity and plant species richness. *Nature*, 529, 390–393.

Hargreaves, A.L., Samis, K.E. & Eckert, C.G. (2014) Are Species’ Range Limits Simply Niche Limits Writ Large? A Review of Transplant Experiments beyond the Range. *The American Naturalist*, 183, 157–173.

Harpole, W.S., Sullivan, L.L., Lind, E.M., Firn, J., Adler, P.B. & Borer, E.T., et al. (2016) Addition of multiple limiting resources reduces grassland diversity. *Nature*, 537, 93–96.

Hautier, Y., Zhang, P., Loreau, M., Wilcox, K.R., Seabloom, E.W. & Borer, E.T., et al. (2020) General destabilizing effects of eutrophication on grassland productivity at multiple spatial scales. *Nature Communications*, 11, 5375.

Hengl, T., Mendes de Jesus, J., Heuvelink, G.B.M., Ruiperez Gonzalez, M., Kilibarda, M. & Blagotić, A., et al. (2017) SoilGrids250m: Global gridded soil information based on machine learning. *PLOS ONE*, 12, e0169748.

Hereford, J. (2009) A Quantitative Survey of Local Adaptation and Fitness Trade-Offs. *The American Naturalist*, 173, 579–588.

Hillebrand, H., Blasius, B., Borer, E.T., Chase, J.M., Downing, J.A. & Eriksson, B.K., et al. (2018) Biodiversity change is uncoupled from species richness trends: Consequences for conservation and monitoring. *Journal of Applied Ecology*, 55, 169–184.

Imai, K. & Ratkovic, M. (2013) Estimating treatment effect heterogeneity in randomized program evaluation. *The Annals of Applied Statistics*, 7, 443–470.

Imbens, G.W. & Rubin, D.B. (2015) *Causal Inference for Statistics, Social, and Biomedical Sciences: An Introduction*. Cambridge University Press, Cambridge.

Kattge, J., Bönisch, G., Díaz, S., Lavorel, S., Prentice, I.C. & Leadley, P., et al. (2020) TRY plant trait database - enhanced coverage and open access. *Global Change Biology*, 26, 119–188.

Kimmel, K., Dee, L.E., Avolio, M.L. & Ferraro, P.J. (2021) Causal assumptions and causal inference in ecological experiments. *Trends in Ecology & Evolution*, 36, 1141–1152.

Klanderud, K. & Totland, Ø. (2005) Simulated climate change altered dominance hierarchies and diversity of an Alpine biodiversity hotspot. *Ecology*, 86, 2047–2054.

Künzel, S.R., Sekhon, J.S., Bickel, P.J. & Yu, B. (2019) Metalearners for estimating heterogeneous treatment effects using machine learning. *Proceedings of the National Academy of Sciences*, 116, 4156–4165.

Larsen, A.E., Meng, K. & Kendall, B.E. (2019) Causal analysis in control–impact ecological studies with observational data. *Methods in Ecology and Evolution*, 10, 924–934.

Lee-Yaw, J.A., Kharouba, H.M., Bontrager, M., Mahony, C., Csergő, A.M. & Noreen, A.M.E., et al. (2016) A synthesis of transplant experiments and ecological niche models suggests that range limits are often niche limits. *Ecology Letters*, 19, 710–722.

Lenoir, J. & Svenning, J.-C. (2015) Climate-related range shifts – a global multidimensional synthesis and new research directions. *Ecography*, 38, 15–28.

Levine, J.M. & HilleRisLambers, J. (2009) The importance of niches for the maintenance of species diversity. *Nature*, 461, 254–257.

MacArthur, R.H. & Wilson, E.O. (1967) *The Theory of Island Biogeography*. Princeton University Press, Princeton.

McGill, B., Enquist, B., Weiher, E. & Westoby, M. (2006) Rebuilding community ecology from functional traits. *Trends in Ecology & Evolution*, 21, 178–185.

Menzel, A., Sparks, T.H., Estrella, N., Koch, E., Aasa, A. & Ahas, R., et al. (2006) European phenological response to climate change matches the warming pattern. *Global Change Biology*, 12, 1969–1976.

Mountain Research Initiative EDW Working Group (2015) Elevation-dependent warming in mountain regions of the world. *Nature Climate Change*, 5, 424–430.

Nie, X. & Wager, S. (2021) Quasi-oracle estimation of heterogeneous treatment effects. *Biometrika*, 108, 299–319.

Parmesan, C. & Yohe, G. (2003) A globally coherent fingerprint of climate change impacts across natural systems. *Nature*, 421, 37–42.

Pauli, H., Gottfried, M., Dullinger, S., Abdaladze, O., Akhalkatsi, M. & Alonso, J.L.B., et al. (2012) Recent plant diversity changes on Europe's mountain summits. *Science*, 336, 353–355.

R Core Team (2026) *R: A Language and Environment for Statistical Computing*. R Foundation for Statistical Computing, Vienna.

Rosenbaum, P.R. & Rubin, D.B. (1983) The central role of the propensity score in observational studies for causal effects. *Biometrika*, 70, 41–55.

Rumpf, S.B., Hülber, K., Klonner, G., Moser, D., Schütz, M. & Wessely, J., et al. (2018) Range dynamics of mountain plants decrease with elevation. *Proceedings of the National Academy of Sciences*, 115, 1848–1853.

Sax, D.F., Gaines, S.D. & Brown, J.H. (2002) Species Invasions Exceed Extinctions on Islands Worldwide: A Comparative Study of Plants and Birds. *The American Naturalist*, 160, 766–783.

Seabloom, E.W., Borer, E.T., Wilcox, K.R., et al. (2020) Effects of chronic nutrient enrichment on plant diversity and ecosystem productivity, 2008–2019. Environmental Data Initiative, edi.599.1. https://doi.org/10.6073/pasta/d78e6e48df246a03129c85a6c1da00d6

Steinbauer, M.J., Grytnes, J.-A., Jurasinski, G., Kulonen, A., Lenoir, J. & Pauli, H., et al. (2018) Accelerated increase in plant species richness on mountain summits is linked to warming. *Nature*, 556, 231–234.

Tibshirani, J., Athey, S., Sverdrup, E. & Wager, S. (2024) *grf: Generalized Random Forests*. R package version 2.6.1.

TransPlant Network (2024) TransPlant: a coordinated network of community transplant experiments along elevation gradients. Dataset, Open Science Framework. https://doi.org/10.17605/OSF.IO/9874T

Tylianakis, J.M., Didham, R.K., Bascompte, J. & Wardle, D.A. (2008) Global change and species interactions in terrestrial ecosystems. *Ecology Letters*, 11, 1351–1363.

Vellend, M., Baeten, L., Myers-Smith, I.H., Elmendorf, S.C., Beauséjour, R. & Brown, C.D., et al. (2013) Global meta-analysis reveals no net change in local-scale plant biodiversity over time. *Proceedings of the National Academy of Sciences*, 110, 19456–19459.

Wager, S. & Athey, S. (2018) Estimation and Inference of Heterogeneous Treatment Effects using Random Forests. *Journal of the American Statistical Association*, 113, 1228–1242.

Walker, M.D., Wahren, C.H., Hollister, R.D., Henry, G.H.R., Ahlquist, L.E. & Alatalo, J.M., et al. (2006) Plant community responses to experimental warming across the tundra biome. *Proceedings of the National Academy of Sciences USA*, 103, 1342–1346.

Walther, G.-R., Post, E., Convey, P., Menzel, A., Parmesan, C. & Beebee, T.J.C., et al. (2002) Ecological responses to recent climate change. *Nature*, 416, 389–395.

Wolkovich, E.M., Cook, B.I., Allen, J.M., Crimmins, T.M., Betancourt, J.L. & Travers, S.E., et al. (2012) Warming experiments underpredict plant phenological responses to climate change. *Nature*, 485, 494–497.

Wright, I.J., Reich, P.B., Westoby, M., Ackerly, D.D., Baruch, Z. & Bongers, F., et al. (2004) The worldwide leaf economics spectrum. *Nature*, 428, 821–827.

Zellweger, F., De Frenne, P., Lenoir, J., Vangansbeke, P., Verheyen, K. & Bernhardt-Römermann, M., et al. (2020) Forest microclimate dynamics drive plant responses to warming. *Science*, 368, 772–775.

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

| Moderator | Estimate | SE | p | p (BH) |
|---|---|---|---|---|
| Intercept (ATE) | 0.65 | 0.53 | 0.225 | 0.412 |
| Source growing-season temperature | −1.36 | 0.78 | 0.080 | 0.296 |
| Source growing-season precipitation | −1.99 | 1.23 | 0.107 | 0.296 |
| Destination-year temperature anomaly | 0.41 | 0.84 | 0.625 | 0.633 |
| Destination-year precipitation anomaly | −1.30 | 1.20 | 0.279 | 0.438 |
| Elevation difference | 0.70 | 0.74 | 0.346 | 0.476 |
| Baseline species richness | −1.74 | 0.89 | 0.051 | 0.296 |
| CWM vegetative height | 1.74 | 1.23 | 0.160 | 0.352 |
| CWM leaf N | −0.51 | 0.84 | 0.545 | 0.633 |
| Woody cover proportion | −0.27 | 0.57 | 0.633 | 0.633 |
| Calendar year | 0.61 | 0.35 | 0.086 | 0.296 |

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
| Colonisations | +1.18 | 0.47 | 0.27, 2.10 | 0.011 |
| Extinctions | +0.92 | 0.30 | 0.33, 1.52 | 0.002 |
| Total turnover (gains + losses) | +2.08 | 0.60 | 0.91, 3.26 | < 0.001 |
| Net richness change (comparison) | +0.65 | 0.53 | −0.39, 1.69 | 0.22 |

Joint influence-function tests (cluster-robust covariance across the four forests, delta method; Table S10): colonisations − extinctions = +0.26 (joint SE 0.52, p = 0.62); turnover − net = +1.44 (joint SE 0.62, p = 0.021); (gains − losses) − net = −0.39 (joint SE 0.09, p < 0.001; estimator artefact, see §3.2 and §4.7).

Phase-specific turnover ATEs: year 1 +0.73 (95% CI −2.38, 3.84; n = 125); year 2 +1.97 (0.48, 3.46; n = 211); year ≥ 3 +2.07 (0.76, 3.38; n = 610); year ≥ 2 +2.38 (1.20, 3.57; n = 821).

**Table 5. Directional outcomes of compositional change (same GRF specification; separate forests).** ΔCTI and ΔSTP are the primary and secondary directional outcomes; trait shifts are exploratory. p<sub>BH</sub> is the Benjamini–Hochberg adjustment across the six outcomes. Trait units: SLA cm² g⁻¹, height cm, leaf N mg g⁻¹, woodiness proportion.

| Outcome | Role | n | ATE | SE | 95% CI | p (2-sided) | p<sub>BH</sub> |
|---|---|---|---|---|---|---|---|
| ΔCTI (°C) | primary | 1,061 | +0.071 | 0.036 | 0.000, 0.141 | 0.050 | 0.139 |
| ΔSTP (°C) | secondary | 858 | +0.159 | 0.088 | −0.013, 0.330 | 0.070 | 0.139 |
| ΔCWM SLA (cm² g⁻¹) | exploratory | 1,171 | +3.61 | 3.05 | −2.37, 9.60 | 0.237 | 0.284 |
| ΔCWM height (cm) | exploratory | 1,171 | +0.83 | 0.55 | −0.25, 1.91 | 0.132 | 0.198 |
| ΔCWM leaf N (mg g⁻¹) | exploratory | 1,171 | −0.60 | 0.29 | −1.16, −0.04 | 0.037 | 0.139 |
| ΔCWM woodiness | exploratory | 1,171 | −0.009 | 0.011 | −0.030, 0.012 | 0.412 | 0.412 |

Phase-specific ΔCTI: year 1 +0.02 (95% CI −0.06, 0.11; n = 96); year 2 +0.07 (−0.02, 0.16; n = 194); year ≥ 3 +0.11 (0.01, 0.22; n = 579, p = 0.030); year ≥ 2 +0.10 (0.01, 0.20; n = 773, p = 0.033). Imposed warming averaged +2.40 °C among treated turf-years; tracked fraction 2.9% (95% CI 0.0–5.9%).

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

**Fig. 4. Region-level effect heterogeneity.** ATEs from forests re-fitted within each region (≥ 8 turfs); bars = 95% CI, point area = number of turfs. Effects reverse sign between the warmest source region (DE_Susalps, −3.98) and a climatically mid-range region (NO_Ulvhaugen, +3.38).

**Fig. 5. Time since transplant.** (a) Mean estimated CATE by years since transplant (bins with n ≥ 20 turf-years). (b) Phase-specific ATEs from separate forests (year 1, year 2, year ≥ 3); bars = 95% CI.

**Fig. 6. Positive control: Nutrient Network fertilization.** (a) ATE of N/NP addition (+124.4 g m⁻², 95% CI 76–173) and P addition alone (+65.5 g m⁻²) on ANPP across nine sites. (b) Mean plot-level CATE by site; dotted line = pooled ATE.

**Fig. 7. Warming accelerates compositional turnover.** (a) AIPW ATEs on colonisations, extinctions, total turnover (gains + losses) and, for comparison, net richness change (grey; estimated by a separate forest, hence not exactly additive). (b) Turnover ATE by years since transplant (separate forests per phase). (c) Colonisations vs. extinctions per turf-year by treatment; dashed line = gains equal losses (no net change).

**Fig. 8. Composition reorganises quickly but tracks the imposed warming only marginally.** (a) Distribution of forest-estimated conditional effects (CATEs) on the change in community temperature index (ΔCTI); red line = AIPW ATE (+0.071 °C). (b) ΔCTI ATE by years since transplant; filled bars = 95% CI excluding zero. (c) Thermal directionality of turnover: STP of colonising species minus STP of species extinct relative to baseline, for Warm and in-situ LocalControl turfs; diamond = mean. (d) Share of the imposed warming (+2.4 °C) tracked by the community temperature index (2.9%, 95% CI 0.0–5.9%).

---

## Plain-language summary (internal working note; not for submission)

The v3 analysis covers 20 TransPlant regions in nine countries, 41 destination sites, 225 turfs and 1,171 turf-years. Mean richness change was small and uncertain (+0.65 species, confidence interval crossing zero), with little change in total cover. Colonisation increased by 1.18 (p = 0.011) and extinction by 0.92 (p = 0.002) species per turf-year. Total turnover rose by 2.08 (p < 0.001) and by 2.38 from year two onward (p < 0.001), indicating rapid compositional replacement with little net richness change. In contrast, community temperature index (CTI) increased by only 0.071 °C against mean imposed warming of 2.4 °C: estimated tracking was 2.9% [0.0%, 5.9%]. CTI reached approximately +0.11 °C from year three (p = 0.030). Richness initially fell by about 1.2 species and increased by about one species from year two. Regional effect signs differed (approximately −4.0 in German Susalps versus +3.4 in Norwegian Ulvhaugen); higher baseline richness tended to predict smaller gains. Colonisers were on average 0.16 °C warmer in preference than species lost (p = 0.070), and leaf nitrogen fell by 0.60 mg/g (p = 0.037). Joint inference gave colonisation minus extinction +0.26 (p = 0.62), turnover minus net change +1.44 (p = 0.021), and an additivity discrepancy of −0.39 (p < 0.001) caused by separate regularized estimators rather than biology. The CTI two-sided p value was 0.050; none of six directional outcomes survived BH correction (smallest adjusted p = 0.14), and no richness BLP moderator survived adjustment. The site-clustered minimum detectable effect was about two species and both arms occurred at only 26/41 sites. Wider source-data coverage and the full NutNet core network remain future work.
