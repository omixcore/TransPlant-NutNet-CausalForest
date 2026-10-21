# Research plan: heterogeneous causal effects on plant communities across global-change networks
## Causal forests reveal who wins and who loses under global change

> Version 1.0, 2026-10-21. This historical plan describes an early TransPlant/NutNet prototype. Its preliminary sample sizes and effect estimates have been superseded by the v3 manuscript.

## 1. Questions and proposed contributions

Global-change drivers such as warming and nutrient enrichment may have very different effects across sites and communities. The proposed use of generalized random forests (GRF) estimates turf-level conditional average treatment effects (CATEs) beyond an average effect and a small set of prespecified interactions.

- **Q1, prediction:** Under which baseline conditions does the effect change sign?
- **Q2, mechanism:** Does baseline climate or community-weighted trait composition explain more variation?
- **Q3, application:** Can the tails of the CATE distribution identify grassland or mountain communities at elevated risk?

The plan proposed methodological application to two experimental networks, a focus on effect distributions and sign reversals, and comparison of within-network climate/trait gradients across networks. These were research aims, not established findings or a claim of priority.

## 2. Data envisaged

| Network | Source | Early planning scale | Treatment | Outcome |
|---|---|---|---|---|
| TransPlant | Public OSF 9874T | 21 sites, 157 turfs, 888 turf-years in the preliminary extract | Warm transplantation (median +2.1 °C; maximum +11.3 °C) | Richness change, cover LRR |
| NutNet e247 | Public EDI knb-lter-cdr.692.1 (CC BY) | Nine sites × four treatments × three blocks, 9–10 treatment years | N or NP versus control | Aboveground net primary productivity (ANPP) |
| NutNet core | Data agreement at nutnet.org | Approximately 200 sites and more than ten years, subject to access | Factorial nutrient additions and fencing | Cover, richness, biomass |

TRY, WorldClim and SoilGrids were proposed as auxiliary sources. The full NutNet core dataset is not included in this repository.

## 3. Planned fixed specification

1. **Primary model:** `grf::causal_forest`, honest splitting, 4,000 trees, turf/plot clustering and site-level empirical propensity truncated to [0.1, 0.9].
2. **Primary output:** AIPW average treatment effect (ATE), CATE distribution and predeclared BLP tests for baseline temperature, richness and woody proportion. Early p values cited in the original plan were preliminary and are not the current multiplicity-adjusted results.
3. **Dose analysis:** Continuous temperature difference and effect per +1 °C. The early +0.55 species/°C estimate was a prototype estimate.
4. **Robustness:** Within-site/year permutations, overlap diagnostics and trimming, an overlap-targeted estimate, balanced monitoring periods, and covariate-set sensitivity.
5. **Cross-network check:** Compare candidate moderators across TransPlant and NutNet where outcomes and treatment definitions permit a meaningful comparison.
6. **Implementation:** R ≥ 4.5 with `grf` and the analysis scripts.

## 4. Feasibility evidence available when this plan was written

The early TransPlant v2 subset (n = 872, taxon matching 67% to 88.5%) yielded richness ATE +0.84 [−0.03, 1.71] and no clear cover shift. Its baseline-temperature and richness BLP signals were preliminary. The NutNet e247 sample (n = 90) yielded nitrogen-addition ANPP ATE +124 g/m² [76, 173] and a phosphorus-only estimate around +66 g/m². Remaining issues included unmatched taxa, limited NutNet sites and imprecise heterogeneity estimates. Use the later v3 manuscript for current sample definitions.

## 5. Six-month planning schedule

| Month | Milestone |
|---|---|
| M1 | Request the NutNet data agreement; finish TransPlant taxon matching; expand environmental covariates |
| M2 | Primary analyses and robustness checks in both networks; assess whether a CATE risk map is defensible |
| M3 | Estimate sign-reversal thresholds with uncertainty; compare networks |
| M4 | Draft manuscript and consider a preprint |
| M5 | Submit |
| M6 | Address peer review, allowing for major revision |

## 6. Journal strategy proposed at the time

The initial target was *Global Change Biology*, with *New Phytologist*, *Journal of Ecology* and *Ecology Letters* considered depending on the strength of ecological evidence. A separate methods comparison could suit *Methods in Ecology and Evolution*. These are planning options, not current journal requirements or acceptance predictions.

## 7. Risks and responses

| Risk | Original assessment | Proposed response |
|---|---|---|
| Delay in NutNet core access | Medium | Use the public e247 subset as a positive control while awaiting access |
| Weak CATE heterogeneity after full analysis | Low in the original plan | Report uncertainty and validate on independent subsets; the current manuscript treats moderator evidence as exploratory |
| Unclear benefit over conventional models | High | Compare with mixed-effects models and out-of-sample loss |
| Different moderator directions across networks | Medium | Interpret network-specific treatment and outcome differences without forcing agreement |

## 8. Reproduction assets

The original plan named `analysis_causal_forest_v2.R`, `analysis_nutnet.R`, prototype logs, CATE tables and figures. The current pipeline is `analysis_causal_forest_v3.R`. The source first lived on Gitee and was later imported into this GitHub repository.
