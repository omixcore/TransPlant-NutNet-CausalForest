# Supplementary Information

**Manuscript:** Weak average effects, but predictable winners and losers: causal forests reveal heterogeneous and time-varying responses of mountain grassland communities to transplant warming

**Note.** All values traceable to run logs in `project/output/` (`run_log_v3.txt`, `run_log_gainloss.txt`, `run_log_robust.txt`, `run_log_event.txt`, `run_log_nutnet.txt`); software: R 4.5.3, grf 2.6.1 (see session_info.txt).

**Figures.** All seven main figures are provided in both raster (300 dpi PNG) and vector (PDF, fonts embedded) formats in `project/output/`: `fig1_study_system`, `fig2_average_and_placebo`, `fig3_who_benefits`, `fig4_region_ate`, `fig5_event_time`, `fig6_nutnet`, `fig7_turnover` (`.pdf` and `.png`). Print width 170 mm for Figs 1–7 (Fig. 4: 117 mm).

---

## Table S1. Region-specific ATEs (forests re-fit within region; regions with ≥ 8 turfs)

| Region | n | Turfs | ATE | SE |
|---|---|---|---|---|
| DE_Susalps | 47 | 10 | −3.98 | 3.10 |
| CN_Gongga | 274 | 56 | −0.08 | 0.57 |
| NO_Lavisdalen | 150 | 25 | +0.28 | 0.89 |
| NO_Skjellingahaugen | 149 | 25 | +0.81 | 1.33 |
| NO_Gudmedalen | 150 | 25 | +2.06 | 1.38 |
| NO_Ulvhaugen | 149 | 25 | +3.38 | 1.17 |

## Table S2. Best linear projection with Benjamini–Hochberg correction (both outcomes)

Species richness change:

| Term | Estimate | SE | p | p (BH-adjusted) |
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

Cover log response ratio: no term with raw p < 0.10; minimum BH-adjusted p = 0.754.

*After BH correction (q = 0.05) no moderator is significant for either outcome.*

## Table S3. Leave-one-region-out ATEs (species richness change; 2,000-tree forests)

| Dropped region | n | ATE | SE | 95% CI |
|---|---|---|---|---|
| CH_Calanda | 1141 | 0.57 | 0.53 | −0.47, 1.60 |
| CH_Calanda2 | 1160 | 0.71 | 0.53 | −0.34, 1.75 |
| CH_Lavey | 1150 | 0.55 | 0.53 | −0.48, 1.58 |
| CN_Damxung | 1156 | 0.69 | 0.53 | −0.36, 1.73 |
| CN_Gongga | 897 | 0.70 | 0.66 | −0.61, 2.00 |
| CN_Heibei | 1123 | 0.71 | 0.45 | −0.17, 1.58 |
| DE_Grainau | 1159 | 0.59 | 0.53 | −0.45, 1.64 |
| DE_Susalps | 1124 | 0.82 | 0.53 | −0.22, 1.86 |
| DE_TransAlps | 1146 | 0.57 | 0.54 | −0.49, 1.63 |
| FR_AlpeHuez | 1159 | 0.60 | 0.53 | −0.45, 1.64 |
| FR_Lautaret | 1159 | 0.62 | 0.51 | −0.38, 1.61 |
| IN_Kashmir | 1165 | 0.62 | 0.53 | −0.42, 1.66 |
| IT_MatschMazia1 | 1159 | 0.55 | 0.53 | −0.50, 1.58 |
| IT_MatschMazia2 | 1159 | 0.51 | 0.53 | −0.53, 1.55 |
| NO_Gudmedalen | 1021 | 0.67 | 0.57 | −0.45, 1.80 |
| NO_Lavisdalen | 1021 | 0.61 | 0.58 | −0.53, 1.76 |
| NO_Skjellingahaugen | 1022 | 0.59 | 0.58 | −0.56, 1.74 |
| NO_Ulvhaugen | 1022 | 0.21 | 0.57 | −0.91, 1.33 |
| SE_Abisko | 1147 | 0.52 | 0.53 | −0.53, 1.56 |
| US_Colorado | 1159 | 0.55 | 0.54 | −0.51, 1.61 |

*Range of LOO ATEs: 0.21–0.82 (full sample 0.65). No single region drives the estimate.*

## Table S4. Hyperparameter sensitivity (species richness change)

| num.trees | min.node.size | ATE | SE |
|---|---|---|---|
| 2000 | 2 | 0.648 | 0.526 |
| 4000 | 2 | 0.649 | 0.528 |
| 2000 | 5 | 0.562 | 0.527 |
| 4000 | 5 | 0.580 | 0.528 |
| 2000 | 10 | 0.620 | 0.526 |
| 4000 | 10 | 0.624 | 0.528 |

## Table S5. Cluster-level sensitivity and minimum detectable effect

| Clustering | ATE | SE | 95% CI |
|---|---|---|---|
| Turf (225 clusters; main text) | 0.646 | 0.531 | −0.39, 1.69 |
| Destination site (41 clusters) | 0.631 | 0.714 | −0.77, 2.03 |

MDE at 80% power (site-clustered SE): **2.0 species**.

## Table S6. Calibration tests (`grf::test_calibration`, one-sided HC3)

| Outcome | Coefficient | Estimate | SE | p |
|---|---|---|---|---|
| Richness change | mean.forest.prediction | 1.03 | 0.97 | 0.143 |
| Richness change | differential.forest.prediction | −0.18 | 0.87 | 0.582 |
| Cover LRR | mean.forest.prediction | 1.60 | 4.05 | 0.346 |
| Cover LRR | differential.forest.prediction | −0.80 | 1.40 | 0.718 |

*The differential-forest-prediction coefficient tests for detectable CATE heterogeneity; neither outcome rejects homogeneity at conventional levels.*

## Table S7. Overlap diagnostics

| Quantity | Value |
|---|---|
| Design propensity (within-site treatment fraction, clipped to [0.1, 0.9]) | 0.10 – 0.71 (mean 0.455) |
| Treated fraction | 0.437 |
| Destination sites with both treatment arms | 26 / 41 |
| Destination sites with a single arm | 15 |

*Single-arm sites contribute between-site information only; the within-site comparison rests on the 26 two-arm sites.*

---

## Supplementary references

Software: R Core Team (2026) R 4.5.3; Tibshirani, Athey & Wager `grf` 2.6.1. Full session information in `project/output/session_info.txt`.
