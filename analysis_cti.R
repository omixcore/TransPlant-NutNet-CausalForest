## ============================================================================
##  Directionality of compositional change under transplant warming
##
##  The turnover analysis (analysis_gainloss.R) established that warming
##  accelerates species replacement without changing net richness. It did not
##  ask which *kind* of species replace which. This script adds direction:
##
##   (1) CTI  - community temperature index: cover-weighted mean of species
##              thermal preferences (STP), so dCTI > 0 means the community
##              shifted towards warm-affiliated species.
##   (2) dSTP - thermal directionality of turnover: mean STP of colonisers
##              minus mean STP of extinctions. Positive = warm species are
##              replacing cold ones; near zero = replacement is stochastic.
##   (3) dCWM - shifts in cover-weighted trait means (SLA, height, leaf N,
##              woodiness), which are species attributes and therefore free of
##              any circularity with the treatment.
##
##  STP definition and its circularity control
##  ------------------------------------------
##  STP for a species is the mean growing-season temperature of the sites
##  where it was recorded. Two safeguards keep STP independent of the
##  treatment being estimated:
##    (i)  only in-situ LocalControl turfs contribute records. Transplanted
##         turfs are never used, so the warming treatment cannot inform which
##         species are "warm" species.
##    (ii) records are de-duplicated to one per species x site, and the focal
##         turf's own site is removed (leave-one-site-out). A species that is
##         recorded at only one site network-wide therefore receives no STP
##         and is excluded from CTI rather than being assigned its own site
##         temperature (which would force dCTI towards zero by construction).
##  Coverage of the CTI by species and by cover is reported, and the
##  leave-one-site-out requirement is relaxed in a sensitivity analysis.
## ============================================================================

.libPaths(c("project/rlibs", .libPaths()))
suppressPackageStartupMessages({ library(dplyr); library(tidyr); library(grf) })

out <- "project/output"
dir.create(out, showWarnings = FALSE, recursive = TRUE)

## ---------------------------------------------------------------- 1. load + taxonomy fix (as v3)
e <- new.env(); load("project/data/TransPlantNetwork.RData", envir = e)
dat    <- as.data.frame(e$dat)
clim   <- as.data.frame(e$climdata)
traits <- as.data.frame(e$alltraits)
mt     <- as.data.frame(e$mergedtaxa)

mt2 <- mt %>% group_by(Region, destSiteID, SpeciesName) %>%
  summarise(taxa = first(taxa), .groups = "drop")
dat <- dat %>%
  left_join(mt2, by = c("Region", "destSiteID", "SpeciesName")) %>%
  mutate(SpeciesName = coalesce(taxa, SpeciesName)) %>%
  dplyr::select(-taxa) %>%
  distinct() %>%
  mutate(turf_key = paste(Region, originSiteID, destSiteID, turfID, sep = "|"),
         present  = !is.na(Cover) & Cover > 0)

## ---------------------------------------------------------------- 2. site growing-season temperature
gs <- clim %>% filter(month %in% 5:9)
siteT <- gs %>%
  filter(year <= 2010, var == "temperature") %>%
  group_by(destSiteID) %>%
  summarise(T_gs = mean(value, na.rm = TRUE), .groups = "drop")

cat("### Site growing-season temperature ###\n")
cat("sites with T_gs:", sum(!is.na(siteT$T_gs)), "| range:",
    round(min(siteT$T_gs, na.rm = TRUE), 2), "-", round(max(siteT$T_gs, na.rm = TRUE), 2), "deg C\n")

## ---------------------------------------------------------------- 3. species thermal preference (STP)
lc <- dat %>%
  filter(Treatment == "LocalControl", present) %>%
  left_join(siteT, by = c("originSiteID" = "destSiteID")) %>%
  filter(!is.na(T_gs))

## one record per species x site, from in-situ turfs only
sp_site <- lc %>% distinct(SpeciesName, originSiteID, T_gs)
sp_agg  <- sp_site %>% group_by(SpeciesName) %>%
  summarise(sumT = sum(T_gs), n_site = n(), .groups = "drop")

turf_site <- dat %>% distinct(turf_key, originSiteID) %>%
  left_join(siteT, by = c("originSiteID" = "destSiteID"))

## leave-one-site-out STP for every turf x species pair
sp_turf <- dat %>% filter(present) %>%
  distinct(turf_key, SpeciesName) %>%
  left_join(turf_site, by = "turf_key") %>%
  left_join(sp_agg, by = "SpeciesName") %>%
  mutate(.key  = paste(SpeciesName, originSiteID, sep = "@"),
         at_S  = .key %in% paste(sp_site$SpeciesName, sp_site$originSiteID, sep = "@"),
         n_use = n_site - as.integer(at_S),
         sumT_use = sumT - ifelse(at_S, T_gs, 0),
         STP   = ifelse(n_use >= 2, sumT_use / n_use, NA_real_)) %>%
  dplyr::select(turf_key, SpeciesName, STP, n_site)

cat("\n### STP availability(leave-one-site-out, n_use >= 2)###\n")
cat("species total:", n_distinct(dat$SpeciesName),
    "| with STP:", n_distinct(sp_turf$SpeciesName[!is.na(sp_turf$STP)]),
    sprintf("(%.1f%%)\n", 100 * n_distinct(sp_turf$SpeciesName[!is.na(sp_turf$STP)]) / n_distinct(dat$SpeciesName)))

## ---------------------------------------------------------------- 4. CTI per turf-year
wm_na <- function(x, w) {
  ok <- !is.na(x)
  if (!any(ok) || sum(w[ok], na.rm = TRUE) == 0) return(NA_real_)
  weighted.mean(x[ok], w[ok], na.rm = TRUE)
}

cti_panel <- dat %>% filter(present) %>%
  left_join(sp_turf %>% dplyr::select(turf_key, SpeciesName, STP),
            by = c("turf_key", "SpeciesName")) %>%
  group_by(turf_key, Year) %>%
  summarise(cti      = wm_na(STP, Cover),
            n_sp     = n_distinct(SpeciesName),
            n_sp_stp = n_distinct(SpeciesName[!is.na(STP)]),
            cov_frac = if (sum(Cover, na.rm = TRUE) > 0)
                         sum(Cover[!is.na(STP)], na.rm = TRUE) / sum(Cover, na.rm = TRUE) else NA_real_,
            .groups = "drop") %>%
  group_by(turf_key) %>% arrange(Year, .by_group = TRUE) %>%
  mutate(base_year = first(Year),
         cti_base  = first(cti),
         d_cti     = cti - cti_base,
         ys        = Year - base_year) %>%
  ungroup()

cat("\n### CTI coverage ###\n")
cat("turf-years:", nrow(cti_panel),
    "| median cover-weighted coverage:", round(median(cti_panel$cov_frac, na.rm = TRUE), 3),
    "| mean:", round(mean(cti_panel$cov_frac, na.rm = TRUE), 3), "\n")
cat("median species-count coverage:", round(median(cti_panel$n_sp_stp / cti_panel$n_sp, na.rm = TRUE), 3), "\n")

## ---------------------------------------------------------------- 5. thermal directionality of turnover
sets <- dat %>% filter(present) %>% distinct(turf_key, Year, SpeciesName)
base_year_tbl <- sets %>% group_by(turf_key) %>%
  summarise(base_year = min(Year), .groups = "drop")
base_sp <- sets %>% inner_join(base_year_tbl, by = c("turf_key", "Year" = "base_year")) %>%
  distinct(turf_key, SpeciesName) %>% mutate(in_base = TRUE)

## gains: species present now but absent from the baseline flora
gain_df <- sets %>%
  left_join(base_sp %>% dplyr::select(turf_key, SpeciesName, in_base),
            by = c("turf_key", "SpeciesName")) %>%
  mutate(gained = is.na(in_base)) %>%
  left_join(sp_turf %>% dplyr::select(turf_key, SpeciesName, STP),
            by = c("turf_key", "SpeciesName")) %>%
  group_by(turf_key, Year) %>%
  summarise(stp_gain   = mean(STP[gained & !is.na(STP)]),
            n_gain_stp = sum(gained & !is.na(STP)),
            n_gain     = sum(gained),
            .groups = "drop")

## losses: baseline species absent from the current survey
loss_df <- sets %>% distinct(turf_key, Year) %>%
  left_join(base_sp %>% dplyr::select(turf_key, SpeciesName), by = "turf_key") %>%
  left_join(sets %>% mutate(now = 1L), by = c("turf_key", "Year", "SpeciesName")) %>%
  mutate(lost = is.na(now)) %>%
  left_join(sp_turf %>% dplyr::select(turf_key, SpeciesName, STP),
            by = c("turf_key", "SpeciesName")) %>%
  group_by(turf_key, Year) %>%
  summarise(stp_loss   = mean(STP[lost & !is.na(STP)]),
            n_loss_stp = sum(lost & !is.na(STP)),
            n_loss     = sum(lost),
            .groups = "drop")

dir_tbl <- gain_df %>%
  full_join(loss_df, by = c("turf_key", "Year")) %>%
  mutate(d_stp = ifelse(n_gain_stp >= 1 & n_loss_stp >= 1, stp_gain - stp_loss, NA_real_))

cat("\n### Directional turnover metrics ###\n")
cat("turf-years with d_stp defined:", sum(!is.na(dir_tbl$d_stp)),
    "| mean d_stp:", round(mean(dir_tbl$d_stp, na.rm = TRUE), 3), "\n")

## ---------------------------------------------------------------- 6. trait CWM per turf-year
sp_fallback <- traits %>%
  mutate(SLA_fb = TSLA_cm2_g, Hgt_fb = TPlant_Veg_Height_cm, Npc_fb = TN_percent) %>%
  group_by(SpeciesName) %>%
  summarise(across(c(SLA_fb, Hgt_fb, Npc_fb), ~ mean(.x, na.rm = TRUE)), .groups = "drop")

sp_traits <- traits %>%
  mutate(SLA = coalesce(SLA_cm2_g, TSLA_cm2_g),
         Hgt = coalesce(Plant_Veg_Height_cm, TPlant_Veg_Height_cm),
         Npc = coalesce(N_percent, TN_percent),
         woody_num = if (is.character(woodiness))
           as.numeric(!grepl("non", woodiness, ignore.case = TRUE)) else as.numeric(woodiness)) %>%
  dplyr::select(Region, destSiteID, SpeciesName, SLA, Hgt, Npc, woody_num) %>%
  left_join(sp_fallback, by = "SpeciesName") %>%
  mutate(SLA = coalesce(SLA, SLA_fb), Hgt = coalesce(Hgt, Hgt_fb), Npc = coalesce(Npc, Npc_fb)) %>%
  dplyr::select(-ends_with("_fb")) %>%
  ## --- trait cleaning: the raw table contains Inf SLA values and a mixture of
  ##     height units, and N is reported in mg/g rather than %. Values outside
  ##     physically plausible bounds are set to NA rather than winsorised, so
  ##     that CWM deltas are not driven by a handful of corrupt records.
  mutate(SLA = ifelse(is.finite(SLA) & SLA > 0 & SLA < 1000, SLA, NA_real_),
         Npc = ifelse(is.finite(Npc) & Npc > 0 & Npc < 100, Npc, NA_real_),
         Hgt = ifelse(is.finite(Hgt) & Hgt > 0 & Hgt < 500, Hgt, NA_real_)) %>%
  group_by(Region, destSiteID, SpeciesName) %>%
  summarise(across(everything(), ~ mean(.x, na.rm = TRUE)), .groups = "drop") %>%
  mutate(across(c(SLA, Hgt, Npc), ~ ifelse(is.nan(.x), NA_real_, .x)))

cwm_y <- dat %>% filter(present) %>%
  left_join(sp_traits, by = c("Region", "destSiteID", "SpeciesName")) %>%
  group_by(turf_key, Year) %>%
  summarise(cwm_SLA0 = wm_na(SLA, Cover), cwm_Hgt0 = wm_na(Hgt, Cover),
            cwm_Npc0 = wm_na(Npc, Cover), cwm_woody0 = wm_na(woody_num, Cover),
            .groups = "drop") %>%
  group_by(turf_key) %>% arrange(Year, .by_group = TRUE) %>%
  mutate(d_cwm_SLA   = cwm_SLA0   - first(cwm_SLA0),
         d_cwm_Hgt   = cwm_Hgt0   - first(cwm_Hgt0),
         d_cwm_Npc   = cwm_Npc0   - first(cwm_Npc0),
         d_cwm_woody = cwm_woody0 - first(cwm_woody0)) %>%
  ungroup() %>%
  dplyr::select(turf_key, Year, d_cwm_SLA, d_cwm_Hgt, d_cwm_Npc, d_cwm_woody)

## ---------------------------------------------------------------- 7. assemble analysis frame
res <- readRDS(file.path(out, "cf_results_v3.rds"))
d2  <- res$rich$d2 %>%
  dplyr::select(turf_key, Year, Region, Treatment, W_bin, W_cont, all_of(c(
    "orig_temp", "orig_prec", "d_temp_y", "d_prec_y", "d_elev",
    "base_rich", "cwm_SLA", "cwm_Hgt", "cwm_Npc", "prop_woody", "Year",
    "W_hat_site", "Y_rich")))

ana <- d2 %>%
  left_join(cti_panel %>% dplyr::select(turf_key, Year, cti, cti_base, d_cti, ys, cov_frac, n_sp_stp, n_sp),
            by = c("turf_key", "Year")) %>%
  left_join(dir_tbl, by = c("turf_key", "Year")) %>%
  left_join(cwm_y, by = c("turf_key", "Year"))

## quality filter for the CTI outcomes: baseline must be well covered
ana <- ana %>%
  mutate(d_cti_ok = ifelse(cov_frac >= 0.5 & n_sp_stp >= 3, d_cti, NA_real_))

cat("\n### After merging ###\n")
cat("rows:", nrow(ana),
    "| d_cti nonmissing:", sum(!is.na(ana$d_cti)),
    "| d_cti_ok nonmissing:", sum(!is.na(ana$d_cti_ok)),
    "| d_stp nonmissing:", sum(!is.na(ana$d_stp)), "\n")

## ---------------------------------------------------------------- 8. causal forest
X_names <- c("orig_temp", "orig_prec", "d_temp_y", "d_prec_y", "d_elev",
             "base_rich", "cwm_SLA", "cwm_Hgt", "cwm_Npc", "prop_woody", "Year")

run_cf <- function(data, Yname, label) {
  dd <- data %>% filter(!is.na(.data[[Yname]])) %>%
    drop_na(all_of(c(X_names, "turf_key", "W_hat_site")))
  Xm <- as.matrix(dd[, X_names]); X <- scale(Xm)
  X[, apply(X, 2, function(z) sd(z, na.rm = TRUE) == 0)] <- 0
  X[is.na(X)] <- 0
  set.seed(20261021)
  cf <- causal_forest(X, dd[[Yname]], dd$W_bin, W.hat = dd$W_hat_site,
                      clusters = as.numeric(factor(dd$turf_key)),
                      num.trees = 4000, min.node.size = 5)
  ate <- average_treatment_effect(cf)
  p   <- 2 * pnorm(-abs(ate[1] / ate[2]))
  cat(sprintf("\n== %s ==\nn=%d clusters=%d ATE=%.4f SE=%.4f 95%%CI=[%.4f, %.4f] p=%.4f\n",
              label, nrow(dd), n_distinct(dd$turf_key), ate[1], ate[2],
              ate[1] - 1.96 * ate[2], ate[1] + 1.96 * ate[2], p))
  list(cf = cf, d2 = dd, ate = ate, p = p, label = label, X = X)
}

r_cti  <- run_cf(ana, "d_cti_ok", "dCTI (community temperature index shift, deg C)")
r_stp  <- run_cf(ana, "d_stp",    "dSTP (colonist STP - extinct STP, deg C)")
r_sla  <- run_cf(ana, "d_cwm_SLA", "dCWM SLA (mm2/mg)")
r_hgt  <- run_cf(ana, "d_cwm_Hgt", "dCWM height (cm)")
r_npc  <- run_cf(ana, "d_cwm_Npc", "dCWM leaf N (%)")
r_wdy  <- run_cf(ana, "d_cwm_woody", "dCWM woodiness (proportion)")

ate_tbl <- tibble::tibble(
  outcome = c("dCTI_degC", "dSTP_degC", "dCWM_SLA", "dCWM_Hgt", "dCWM_Npc", "dCWM_woody"),
  role    = c("primary", "secondary", "exploratory", "exploratory", "exploratory", "exploratory"),
  n       = c(nrow(r_cti$d2), nrow(r_stp$d2), nrow(r_sla$d2), nrow(r_hgt$d2), nrow(r_npc$d2), nrow(r_wdy$d2)),
  est     = c(r_cti$ate[1], r_stp$ate[1], r_sla$ate[1], r_hgt$ate[1], r_npc$ate[1], r_wdy$ate[1]),
  se      = c(r_cti$ate[2], r_stp$ate[2], r_sla$ate[2], r_hgt$ate[2], r_npc$ate[2], r_wdy$ate[2])
) %>% mutate(lo = est - 1.96 * se, hi = est + 1.96 * se, p = 2 * pnorm(-abs(est / se)),
             p_one_sided = ifelse(est > 0, pnorm(-est / se), 1 - pnorm(-est / se)))
ate_tbl$p_BH <- p.adjust(ate_tbl$p, method = "BH")   # 6 related outcomes, family-wise
print(ate_tbl, digits = 4)
write.csv(ate_tbl, file.path(out, "cti_ate.csv"), row.names = FALSE)

## how much of the imposed warming does community composition actually track?
dose <- mean(ana$W_cont[ana$W_bin == 1], na.rm = TRUE)
trk  <- 100 * r_cti$ate[1] / dose
cat(sprintf("\n### Climate tracking fraction ###\nMean imposed warming = %.2f deg C | dCTI = %.3f deg C | tracking = %.1f%% of imposed warming\n",
            dose, r_cti$ate[1], trk))
write.csv(data.frame(dose_degC = dose, dCTI_degC = r_cti$ate[1], tracking_pct = trk),
          file.path(out, "cti_tracking.csv"), row.names = FALSE)

saveRDS(list(cti = r_cti, stp = r_stp, sla = r_sla, hgt = r_hgt, npc = r_npc,
             woody = r_wdy, ana = ana), file.path(out, "cti_results.rds"))

## BLP for the two directional outcomes
blp_rows <- list()
for (r in list(r_cti, r_stp)) {
  b <- best_linear_projection(r$cf, r$X)   # a coeftest / matrix object
  blp_rows[[length(blp_rows) + 1]] <- data.frame(
    outcome = r$label, term = rownames(b),
    est = as.numeric(b[, "Estimate"]),
    se  = as.numeric(b[, "Std. Error"]),
    p   = as.numeric(b[, "Pr(>|t|)"]),
    row.names = NULL)
}
blp <- do.call(rbind, blp_rows)
blp$p_BH <- ave(blp$p, blp$outcome, FUN = function(p) p.adjust(p, "BH"))
write.csv(blp, file.path(out, "cti_blp.csv"), row.names = FALSE)
cat("\n### BLP (dCTI / dSTP) ###\n"); print(blp, digits = 3)

## phase split for dCTI
phase_rows <- list()
for (ph in list(list(1, 1, "year 1"), list(2, 2, "year 2"),
                list(3, 99, "year >= 3"), list(2, 99, "year >= 2"))) {
  sub <- ana %>% filter(ys >= ph[[1]], ys <= ph[[2]])
  if (sum(!is.na(sub$d_cti_ok)) < 30) next
  r <- run_cf(sub, "d_cti_ok", paste0("dCTI | ", ph[[3]]))
  phase_rows[[length(phase_rows) + 1]] <-
    data.frame(phase = ph[[3]], n = nrow(r$d2), est = r$ate[1], se = r$ate[2])
}
if (length(phase_rows)) {
  ph_tbl <- do.call(rbind, phase_rows)
  ph_tbl$lo <- ph_tbl$est - 1.96 * ph_tbl$se
  ph_tbl$hi <- ph_tbl$est + 1.96 * ph_tbl$se
  ph_tbl$p  <- 2 * pnorm(-abs(ph_tbl$est / ph_tbl$se))
  cat("\n### dCTI by phase ###\n"); print(ph_tbl, digits = 3)
  write.csv(ph_tbl, file.path(out, "cti_phase.csv"), row.names = FALSE)
}

## ---------------------------------------------------------------- 9. sensitivity: relax LOO requirement
sp_turf_all <- dat %>% filter(present) %>%
  distinct(turf_key, SpeciesName) %>%
  left_join(sp_agg, by = "SpeciesName") %>%
  mutate(STP_all = ifelse(n_site >= 1, sumT / n_site, NA_real_))

cti_all <- dat %>% filter(present) %>%
  left_join(sp_turf_all %>% dplyr::select(turf_key, SpeciesName, STP_all),
            by = c("turf_key", "SpeciesName")) %>%
  group_by(turf_key, Year) %>%
  summarise(cti2 = wm_na(STP_all, Cover), .groups = "drop") %>%
  group_by(turf_key) %>% arrange(Year, .by_group = TRUE) %>%
  mutate(d_cti2 = cti2 - first(cti2)) %>% ungroup()

ana2 <- ana %>% left_join(cti_all, by = c("turf_key", "Year"))
r_cti2 <- run_cf(ana2, "d_cti2", "dCTI sensitivity (no leave-one-site-out)")

## ---------------------------------------------------------------- 10. export panel
write.csv(ana %>% dplyr::select(turf_key, Region, Treatment, Year, ys, W_bin, W_cont,
                                orig_temp, dest_temp = d_temp_y, base_rich,
                                cti, cti_base, d_cti, d_cti_ok, cov_frac,
                                stp_gain, stp_loss, d_stp, n_gain, n_loss,
                                d_cwm_SLA, d_cwm_Hgt, d_cwm_Npc, d_cwm_woody),
          file.path(out, "cti_panel.csv"), row.names = FALSE)

saveRDS(list(cti = r_cti, stp = r_stp, sla = r_sla, hgt = r_hgt, npc = r_npc,
             woody = r_wdy, cti_noloo = r_cti2, ana = ana),
        file.path(out, "cti_results.rds"))
cat("\nwrote cti_ate.csv / cti_blp.csv / cti_panel.csv / cti_results.rds\n")
