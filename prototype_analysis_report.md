# Prototype analysis report: when warming effects reverse
## TransPlant transplantation network × causal forests

> 2026-10-21. Historical v1 prototype: the OSF download, panel construction, causal forest, robustness checks and figures ran locally. The current v3 estimates in the README and manuscript supersede these early results.

## 1. Data

- **Source:** TransPlant Network, 21 Northern Hemisphere mountain sites in six countries; OSF `doi.org/10.17605/OSF.IO/9874T`; processed `TransPlantNetwork.RData` (3.3 MB).
- **Scale:** 60,535 species × year × turf cover records, 157 turfs and 888 turf-year combinations in the preliminary extract; monthly temperature, precipitation and PET for 1979–2019; measured traits with TRY fallback.
- **Treatment:** Warm transplantation to a warmer site (median temperature difference +2.1 °C, maximum +11.3 °C) versus a LocalControl.

## 2. Design

| Component | Prototype specification |
|---|---|
| Unit | Turf × year (1,198 panel rows; clustered by turf) |
| Outcomes | Change in richness from baseline; log response ratio (LRR) of total cover |
| Covariates | Origin climate normal, destination-year climate anomaly, elevation difference, baseline richness and community-weighted traits (SLA, height, leaf nitrogen, woody proportion), year |
| Model | `grf::causal_forest`, honest splitting, 4,000 trees, cluster-robust inference |
| Checks | Treatment permutation within site × year (100 iterations), best linear projection (BLP), calibration |

## 3. Preliminary results (historical; do not cite as final estimates)

The early permutation placebo ATE was −0.18 ± 0.34. In the 274 turf-years with complete covariates, the preliminary richness estimate was +6.9 species (95% CI [5.9, 7.9]); this is the combined effect of transplantation and warming, including immigration from lower elevations. Cover LRR was approximately −0.01 (not significant). The restricted sample and trait-matching problems make these estimates unsuitable as the final result.

In this subset, colder origins appeared to gain more species (CATE approximately 10–11 at the coldest origins versus 4–8 at warmer origins; origin-temperature BLP coefficient −3.31, p < 0.001). Higher baseline diversity was associated with smaller gains (coefficient −1.89); the woody-proportion signal had p = 0.06. A +1.29 species/year trend suggested ongoing recovery.

## 4. Problems revealed by the prototype

1. **Taxon matching:** Direct joins between `dat` and `alltraits` left only 23% of rows complete (1,198 to 274). The bundled `mergedtaxa` and `cleanedspecies` tables support rematching.
2. **Overlap:** Treatment was largely site-determined; propensity estimates ranged from 0.006 to 1. Report an overlap-targeted estimate or a trimmed sample using a stated rule such as Crump et al. (2009).
3. **Unbalanced panel:** Monitoring durations differed across treated and control turfs. Align observations by years since treatment or analyse a balanced subset.
4. **Specification sensitivity:** Early effect estimates ranged from 3.9 to 6.9 species across covariate sets. Fix the primary specification before interpretation.

## 5. Historical files

| File | Purpose |
|---|---|
| `analysis_causal_forest.R` | Initial pipeline |
| `scratch/diagnose_na.R` | Missingness and covariate sensitivity |
| `output/fig1_cate_dist.png`, `fig2_cate_moderators.png`, `fig3_blp.png` | Prototype figures |
| `output/turf_year_cate.csv`, `run_log.txt` | Estimates and run log |

The original report referred to `project/output/cf_results.rds`; that object is not tracked in this repository.

## 6. Planned improvements at the prototype stage

Rematch taxonomy with `mergedtaxa`; estimate a balanced or overlap-trimmed panel; use TRY species-level traits for missing community-weighted means; expand the comparison to NutNet; and prespecify the analysis before journal submission. Some of these steps were subsequently implemented in v2/v3; see the current manuscript for their status.
