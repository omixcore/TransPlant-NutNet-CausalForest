# TransPlant-NutNet-CausalForest

Public data and generalized random forests for heterogeneous treatment effects on plant communities in global-change experiments.

## Research questions

1. Under which baseline conditions do treatment effects change sign, such as species losses following warming or especially severe diversity losses under fertilization?
2. Does baseline climate or community functional composition better explain effect heterogeneity?
3. Can conditional average treatment effects (CATEs) help identify communities at higher risk?

## Data

| Network | Source | Analysis sample |
|---|---|---|
| TransPlant (community transplantation/warming) | OSF: doi.org/10.17605/OSF.IO/9874T | 20 regions in nine countries; 41 destination sites; 225 turfs; 1,171 turf-years (2007–2022) |
| NutNet e247 (nutrient addition) | EDI: knb-lter-cdr.692.1 (CC BY) | Nine sites, four treatments and 90 plot observations |
| NutNet core (planned expansion) | Data agreement at nutnet.org | Approximately 200 sites; not included in the present analysis |

Additional resources include TRY traits, WorldClim and SoilGrids. Download the source data from the cited repositories into `data/`; large source files are excluded by `.gitignore`.

## Reproduce the analyses

The scripts require R 4.5 or later and the packages used by the individual scripts, including `grf`, `dplyr`, `ggplot2` and `patchwork`. Run them in this order after obtaining the source data:

```r
source("analysis_causal_forest_v3.R") # Full TransPlant sample; composite turf key
source("analysis_event_time.R")       # First-year shock and later establishment
source("analysis_nutnet.R")           # NutNet e247 positive-control analysis
source("analysis_gainloss.R")         # Colonisation, extinction and turnover
source("analysis_joint.R")            # Joint influence-function covariance and identity tests
source("analysis_cti.R")              # CTI, STP and trait shifts
source("analysis_robustness.R")       # LOO, clustering, tuning, FDR and overlap
source("make_figures.R")
source("make_fig7.R")
source("make_fig8.R")                  # Eight main figures as PNG and vector PDF
```

## Main findings in the current draft

- **Turnover:** Transplant warming increased colonisations by 1.18 (p = 0.011) and extinctions by 0.92 (p = 0.002) species per turf-year. Total turnover increased by 2.08 (p < 0.001), reaching 2.38 from year two onward. The joint analysis found no clear difference between the two channels (p = 0.62), while turnover exceeded the net imbalance by 1.44 (p = 0.021).
- **Thermal direction:** The community temperature index (CTI) shifted by only 0.071 °C [0.000, 0.141] against mean imposed warming of 2.4 °C, an estimated tracking fraction of 2.9% [0.0%, 5.9%]. The six directional outcomes did not survive Benjamini–Hochberg correction (smallest adjusted p = 0.14), so these patterns remain suggestive.
- **Average richness effect:** Across 1,171 turf-years, the estimate was +0.65 species [−0.39, 1.69], with a cover log response ratio near −0.02. Richness fell by 1.22 species in the first year and increased by approximately 1.03–1.08 from year two onward.
- **Heterogeneity:** Estimated effects ranged from approximately −4.0 in DE_Susalps to +3.4 in NO_Ulvhaugen. Colder origins and lower baseline diversity tended to show larger gains, but the richness moderators did not survive multiplicity correction.
- **Checks:** The permutation placebo p value was 0.065. The NutNet e247 positive control estimated a nitrogen-addition effect of +124 g/m² [76, 173]. Region leave-one-out estimates ranged from 0.21 to 0.82; site-clustered SE was 0.71 (minimum detectable effect approximately two species), and both treatment arms were represented at 26 of 41 sites.

These estimates are reported as in the current manuscript draft. The e247 subset is a positive control, not a substitute for the full NutNet network.

## Repository guide

- `analysis_causal_forest_v3.R`: primary TransPlant pipeline. Earlier versions are retained for traceability.
- `analysis_event_time.R`, `analysis_nutnet.R`, `analysis_gainloss.R`, `analysis_joint.R`, `analysis_cti.R`, `analysis_robustness.R`: supporting analyses.
- `make_figures.R`, `make_fig7.R`, `make_fig8.R`: figures in 300 dpi PNG and vector PDF.
- `manuscript_GCB_draft_v0.2.md`: current English manuscript draft; `Supplementary_Information.md`: supplementary tables.
- `submission_gap_audit.md`: submission readiness and evidence limitations.
- `prototype_analysis_report.md`, `research_plan_two_networks.md`: historical planning documents; their early estimates should not replace the v3 results.
- `output/`: figures, CATE tables, run logs, session information and references.
- `scratch/`: diagnostic scripts.

## Method references

Athey, Tibshirani and Wager (2019), *Annals of Statistics*; Wager and Athey (2018), *Journal of the American Statistical Association*. Data: TransPlant Network (OSF 9874T), Seabloom et al. (2020; EDI edi.599.1) and NutNet e247 (knb-lter-cdr.692.1).
