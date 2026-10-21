# Submission gap audit: GCB manuscript

> Audit dated 2026-10-21. Scope: `manuscript_GCB_draft_v0.1.md`, `Supplementary_Information.md`, scripts and figures. This is a dated working audit; later sections record updates rather than retroactively changing the earlier assessment.

## 1. Additions completed in the first audit

| Earlier gap | Addition | Evidence at that stage |
|---|---|---|
| Turnover mechanism inferred only indirectly from unchanged cover | `analysis_gainloss.R` | Early seed: colonisations +1.12 (p = 0.017), extinctions +0.91 (p = 0.003), turnover +2.02 (p < 0.001), later phase +2.44 (p < 0.001); Fig. 7. Later rerun values appear below. |
| Robustness checks | `analysis_robustness.R` | Region leave-one-out ATE 0.21–0.82; tuning 0.56–0.65; site-clustered SE 0.71; minimum detectable effect (MDE) approximately two species; both arms at 26/41 sites. |
| No multiple-testing adjustment | Benjamini–Hochberg adjustment for BLP across two outcomes | No richness moderator survived; smallest adjusted p = 0.30. |
| Calibration mentioned without values | Full Table S6 | Differential prediction coefficient −0.18 (p = 0.58). |
| Software versions absent | `output/session_info.txt` | R 4.5.3, grf 2.6.1; versions added to Methods 2.4. |
| Too few figures | Seven main figures at that stage | Fig. 7 added; Fig. 8 was added later. |

## 2. Items requiring author input

1. Author names, affiliations, ORCIDs, corresponding author, CRediT roles, competing interests and funding numbers remain placeholders in the manuscript.
2. Full NutNet core data require a data-use agreement. The nine-site e247 sample supports a positive-control analysis, not broad network-level inference.
3. Consider contacting the TransPlant coordinators before formal publication, both for provenance and potential collaboration.
4. Confirm field permits and acknowledgements relevant to participating sites.

## 3. Further analyses and writing identified initially

- **Completed later:** Manuscript v0.2 expanded to approximately 6,046 main-text words and 71 references. The reference metadata were checked using Crossref and the in-text citations were cross-checked against the list.
- **Initial additivity concern:** Separately fitted gain/loss/net forests did not satisfy the exact observed-data identity in their ATE estimates. The later joint influence-function analysis quantified this discrepancy (Section 7).
- **Moderator inference:** None of the richness BLP terms survived FDR correction. Two strongly motivated hypotheses could be specified prospectively in a new study; they should not be retroactively relabelled as confirmatory.
- **Supplementary figures:** Consider a covariate correlation matrix, propensity distribution and regional CATE panels.
- **Site names:** Add a region/site lookup table for codes such as CH_Calanda2.

## 4. Submission formatting

Prepare separate main-text and supplementary files in the journal's current format. Vector PDFs were exported alongside preview PNGs; check embedded fonts and labels at final layout. A cover letter, potential reviewers and Data Availability, Author Contributions and Funding statements still need author review. Journal requirements should be verified again before submission.

## 5. Initial assessment

The turnover decomposition made a stronger ecological story from a small, non-significant mean richness effect: faster compositional replacement can coexist with little net change. This does not by itself guarantee editorial interest or acceptance. Author metadata, full-network access and evidence limitations remain material.

## 6. Directional analysis added later on 2026-10-21

| Measure | Estimate and interpretation | Manuscript location |
|---|---|---|
| Community temperature index (ΔCTI) | +0.071 °C [0.000, 0.141], p = 0.050; about 2.9% [0.0%, 5.9%] of mean imposed +2.4 °C warming | Sections 2.7, 3.3; Table 5; Fig. 8a,d |
| Turnover direction (ΔSTP) | Colonising species averaged +0.16 °C warmer in preference than disappearing species, p = 0.070 | Section 3.3; Fig. 8c |
| CTI event time | Near zero in year one; approximately +0.11 °C from year three, p = 0.030 | Section 3.3; Fig. 8b |
| Trait shifts | Leaf nitrogen −0.60 mg/g, p = 0.037; no clear SLA, height or woody-proportion response | Table 5 |
| Exploratory moderator | Baseline community-weighted height moderated ΔSTP (−0.26 °C/SD, adjusted p = 0.038); interpret cautiously | Table S8 |
| STP leakage prevention | Species preferences defined using LocalControl observations with leave-one-site-out estimation. Relaxing this definition attenuated the estimate to +0.048 (p = 0.11) | Section 2.7; Table S9 |
| Multiplicity | None of six directional outcomes survived BH correction (smallest adjusted p = 0.14) | Sections 3.3, 3.7 |

The contrast between rapid turnover and small thermal tracking is a useful descriptive framing. The 2.9% estimate should not be portrayed as a confirmed mechanism given the multiplicity results.

## 7. Joint inference added later on 2026-10-21

The four forests (net richness, colonisation, extinction and turnover) were retained. Aligned `grf::get_scores` influence functions across 1,171 rows yielded a cluster-robust joint covariance and delta-method contrasts in `analysis_joint.R`. Marginal SEs differed from the original forest SEs by less than 0.5%.

| Contrast | Result | Interpretation |
|---|---|---|
| Colonisation − extinction | +0.26, SE 0.52, p = 0.62 | No resolved dominance of either channel. A non-significant difference is not proof of exact symmetry. |
| Turnover − net | +1.44, SE 0.62, p = 0.021 | Supports turnover exceeding net richness change. |
| (Colonisation − extinction) − net | −0.39, SE 0.09, p < 0.001 | The exact observed-data identity fails across separately regularized forest estimates; this is an estimator inconsistency, not a biological violation. A shared-nuisance multi-outcome estimator is a possible future remedy. |

After fixing the seed at 20261021, the gain/loss rerun gave colonisation +1.18 (p = 0.011), extinction +0.92 (p = 0.002), turnover +2.08 (p < 0.001) and later-phase turnover +2.38 (p < 0.001). The manuscript, abstract and README should use these current values.

## 8. Three editorial self-check questions

### 8.1 Is there a mechanistic link? Partially supported

The experiment and turnover accounting support process-level interpretation: colonisation and extinction rise, turnover accelerates while net richness changes little, and first-year versus later phases differ. The leaf-nitrogen shift and height moderator are weaker exploratory clues. CTI tracking is small and directional outcomes do not survive multiplicity correction. The analysis does not isolate physiological or functional mechanisms: transplantation bundles soil, microbiome and microclimate changes, and does not separate dispersal limitation from thermal filtering. The cover letter and abstract should keep that boundary clear.

### 8.2 Does the result extend beyond one locality? Within a defined scope

The v3 analysis spans 20 regions, nine countries, 41 sites and 2007–2022, with regional effect signs ranging approximately from −3.98 to +3.38. This supports asking about transportability across the studied mountain grasslands. It does not establish generality across other biomes; richness moderator patterns did not survive correction, and the site-clustered MDE is about two species.

### 8.3 Is causal identification credible? Strong design, with qualifications

Experimental treatment assignment and paired local controls strengthen identification. The within-site permutation placebo gave p = 0.065, the e247 nitrogen positive control gave +124 g/m², STP preference estimation avoided within-site leakage, and overlap, clustering and MDE were reported. The placebo p value should not be described as a definitive pass, and site-level overlap and bundled transplantation effects remain important limitations.

**Current submission framing:** Emphasize the experimental design and demographic turnover accounting while reporting exploratory functional and thermal-direction evidence at its actual strength. This audit is a research checklist, not a statement that the manuscript is accepted or submission-ready without author review.
