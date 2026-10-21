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

## Table S8. Best linear projection of the ΔCTI and ΔSTP CATEs (directional outcomes; §3.3)

p<sub>BH</sub> is the Benjamini–Hochberg adjustment within each outcome's 11 moderators. No moderator survives correction for ΔCTI; for ΔSTP, baseline CWM height survives (p<sub>BH</sub> = 0.038) and is treated as exploratory.

| Outcome | Moderator | Estimate | SE | p | p<sub>BH</sub> |
|---|---|---|---|---|---|
| ΔCTI (°C) | Intercept | 0.070 | 0.037 | 0.060 | 0.353 |
| ΔCTI | Source growing-season temperature | −0.098 | 0.068 | 0.149 | 0.353 |
| ΔCTI | Source growing-season precipitation | −0.157 | 0.112 | 0.161 | 0.353 |
| ΔCTI | Destination-year temperature anomaly | −0.036 | 0.050 | 0.472 | 0.741 |
| ΔCTI | Destination-year precipitation anomaly | −0.125 | 0.108 | 0.247 | 0.452 |
| ΔCTI | Elevation difference | −0.004 | 0.047 | 0.933 | 0.995 |
| ΔCTI | Baseline species richness | −0.009 | 0.047 | 0.850 | 0.995 |
| ΔCTI | CWM vegetative height | 0.024 | 0.016 | 0.140 | 0.353 |
| ΔCTI | CWM leaf N | −0.002 | 0.054 | 0.975 | 0.995 |
| ΔCTI | Woody cover proportion | 0.000 | 0.033 | 0.995 | 0.995 |
| ΔCTI | Calendar year | 0.044 | 0.027 | 0.106 | 0.353 |
| ΔSTP (°C) | Intercept | 0.159 | 0.089 | 0.073 | 0.311 |
| ΔSTP | Source growing-season temperature | 0.067 | 0.111 | 0.543 | 0.664 |
| ΔSTP | Source growing-season precipitation | 0.264 | 0.224 | 0.237 | 0.554 |
| ΔSTP | Destination-year temperature anomaly | 0.075 | 0.111 | 0.501 | 0.664 |
| ΔSTP | Destination-year precipitation anomaly | 0.357 | 0.207 | 0.085 | 0.311 |
| ΔSTP | Elevation difference | 0.051 | 0.110 | 0.642 | 0.706 |
| ΔSTP | Baseline species richness | 0.134 | 0.117 | 0.252 | 0.554 |
| ΔSTP | CWM vegetative height | **−0.256** | 0.087 | **0.003** | **0.038** |
| ΔSTP | CWM leaf N | 0.034 | 0.126 | 0.786 | 0.786 |
| ΔSTP | Woody cover proportion | 0.095 | 0.106 | 0.372 | 0.664 |
| ΔSTP | Calendar year | 0.042 | 0.065 | 0.522 | 0.664 |

---

## Table S9. Sensitivity of the ΔCTI result to the STP definition

| Specification | n | ATE | SE | 95% CI | p |
|---|---|---|---|---|---|
| Leave-one-site-out (main, requires ≥ 2 remaining site records) | 1,061 | +0.071 | 0.036 | 0.000, 0.141 | 0.050 |
| No leave-one-site-out (species recorded at a single site are assigned that site's temperature) | 1,171 | +0.048 | 0.030 | −0.011, 0.106 | 0.110 |

*Relaxing the leave-one-site-out requirement pulls the estimate towards zero rather than away from it, which is the direction expected if the main specification removes a mechanical dilution rather than manufacturing a signal.*

---

## Supplementary references

Software: R Core Team (2026) R 4.5.3; Tibshirani, Athey & Wager `grf` 2.6.1. Full session information in `project/output/session_info.txt`.
