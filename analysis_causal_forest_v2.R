# =====================================================================
# Causal forest v2: repair taxon matching with mergedtaxa and re-estimate on the full sample
# Changes from v1:
#   1) map dat taxon names to full names via mergedtaxa before joining traits
#   2) trait fallback: site measurements, then TRY species means
#   3) add the _v2 suffix to output files
# =====================================================================

.libPaths(c("project/rlibs", .libPaths()))
library(grf)
library(dplyr)
library(tidyr)
library(ggplot2)
library(patchwork)

set.seed(20261021)

## ---------------------------------------------------------------- 1. Load data and repair taxonomy
e <- new.env()
load("project/data/TransPlantNetwork.RData", envir = e)
dat    <- as.data.frame(e$dat)
clim   <- as.data.frame(e$climdata)
traits <- as.data.frame(e$alltraits)
mt     <- as.data.frame(e$mergedtaxa)

n_raw <- mean(dat$SpeciesName %in% traits$SpeciesName)
mt2 <- mt %>%
  group_by(Region, destSiteID, SpeciesName) %>%
  summarise(taxa = first(taxa), .groups = "drop")
dat <- dat %>%
  left_join(mt2, by = c("Region", "destSiteID", "SpeciesName")) %>%
  mutate(SpeciesName = coalesce(taxa, SpeciesName)) %>%
  dplyr::select(-taxa) %>%
  distinct()
n_fixed <- mean(dat$SpeciesName %in% traits$SpeciesName)
cat(sprintf("Taxon match rate: before %.1f%% → after %.1f%%\n", 100 * n_raw, 100 * n_fixed))

## ---------------------------------------------------------------- 2. Climate variables
gs <- clim %>% filter(month %in% 5:9)
normals <- gs %>% filter(year <= 2010) %>%
  group_by(destSiteID, var) %>%
  summarise(
    temp_normal = mean(value[var == "temperature"], na.rm = TRUE),
    prec_normal = sum(value[var == "precipitation"], na.rm = TRUE) / length(unique(year[var == "precipitation"])),
    .groups = "drop"
  ) %>%
  group_by(destSiteID) %>%
  summarise(across(c(temp_normal, prec_normal), ~ mean(.x, na.rm = TRUE)), .groups = "drop")

yearly <- gs %>%
  group_by(destSiteID, var, year) %>%
  summarise(v = mean(value, na.rm = TRUE), .groups = "drop") %>%
  tidyr::pivot_wider(names_from = var, values_from = v) %>%
  rename(temp_y = temperature, prec_y = precipitation)

site_elev <- clim %>% group_by(destSiteID) %>%
  summarise(elev = mean(unique(elevation), na.rm = TRUE), .groups = "drop")

## ---------------------------------------------------------------- 3. Turf × year panel
panel0 <- dat %>%
  group_by(Region, originSiteID, destSiteID, Treatment, turfID, Year) %>%
  summarise(richness = n_distinct(SpeciesName), tot_cover = sum(Cover, na.rm = TRUE), .groups = "drop") %>%
  group_by(turfID) %>%
  arrange(Year, .by_group = TRUE) %>%
  mutate(base_year = first(Year)) %>%
  ungroup()

base_tbl <- panel0 %>% filter(Year == base_year) %>%
  dplyr::select(Region, originSiteID, destSiteID, turfID, base_rich = richness, base_cover = tot_cover)

panel <- panel0 %>%
  left_join(base_tbl, by = c("Region", "originSiteID", "destSiteID", "turfID")) %>%
  mutate(
    Y_rich = richness - base_rich,
    Y_lrr  = log((tot_cover + 1) / (base_cover + 1))
  )

## ---------------------------------------------------------------- 4. Traits: site measurements with TRY species-level fallback
sp_fallback <- traits %>%
  mutate(SLA_fb = TSLA_cm2_g, Hgt_fb = TPlant_Veg_Height_cm, Npc_fb = TN_percent) %>%
  group_by(SpeciesName) %>%
  summarise(across(c(SLA_fb, Hgt_fb, Npc_fb), ~ mean(.x, na.rm = TRUE)), .groups = "drop")

sp_traits <- traits %>%
  mutate(
    SLA = coalesce(SLA_cm2_g, TSLA_cm2_g),
    Hgt = coalesce(Plant_Veg_Height_cm, TPlant_Veg_Height_cm),
    Npc = coalesce(N_percent, TN_percent),
    woody_num = if (is.character(woodiness)) as.numeric(!grepl("non", woodiness, ignore.case = TRUE)) else as.numeric(woodiness)
  ) %>%
  dplyr::select(Region, destSiteID, SpeciesName, SLA, Hgt, Npc, woody_num) %>%
  left_join(sp_fallback, by = "SpeciesName") %>%
  mutate(
    SLA = coalesce(SLA, SLA_fb),
    Hgt = coalesce(Hgt, Hgt_fb),
    Npc = coalesce(Npc, Npc_fb)
  ) %>%
  dplyr::select(-ends_with("_fb")) %>%
  group_by(Region, destSiteID, SpeciesName) %>%
  summarise(across(everything(), ~ mean(.x, na.rm = TRUE)), .groups = "drop")

base_rows <- panel %>% filter(Year == base_year) %>%
  dplyr::select(Region, originSiteID, destSiteID, turfID, base_year)
sp_base <- dat %>%
  left_join(base_rows, by = c("Region", "originSiteID", "destSiteID", "turfID")) %>%
  filter(Year == base_year) %>%
  left_join(sp_traits, by = c("Region", "destSiteID", "SpeciesName"))

cwm <- sp_base %>%
  group_by(Region, destSiteID, turfID) %>%
  summarise(
    cwm_SLA    = weighted.mean(SLA, Cover, na.rm = TRUE),
    cwm_Hgt    = weighted.mean(Hgt, Cover, na.rm = TRUE),
    cwm_Npc    = weighted.mean(Npc, Cover, na.rm = TRUE),
    prop_woody = weighted.mean(woody_num, Cover, na.rm = TRUE),
    .groups = "drop"
  )

## ---------------------------------------------------------------- 5. Merge covariates
ana <- panel %>%
  left_join(normals, by = c("originSiteID" = "destSiteID")) %>%
  rename(orig_temp = temp_normal, orig_prec = prec_normal) %>%
  left_join(normals, by = c("destSiteID" = "destSiteID")) %>%
  rename(dest_temp = temp_normal, dest_prec = prec_normal) %>%
  left_join(rename(yearly, orig_temp_y = temp_y, orig_prec_y = prec_y),
            by = c("originSiteID" = "destSiteID", "Year" = "year")) %>%
  left_join(rename(yearly, dest_temp_y = temp_y, dest_prec_y = prec_y),
            by = c("destSiteID" = "destSiteID", "Year" = "year")) %>%
  left_join(site_elev, by = c("originSiteID" = "destSiteID")) %>%
  rename(orig_elev = elev) %>%
  left_join(site_elev, by = c("destSiteID" = "destSiteID")) %>%
  rename(dest_elev = elev) %>%
  left_join(cwm, by = c("Region", "destSiteID", "turfID")) %>%
  mutate(
    W_bin   = as.integer(Treatment == "Warm"),
    W_cont  = dest_temp - orig_temp,
    d_temp_y = coalesce(dest_temp_y - orig_temp, dest_temp - orig_temp),
    d_prec_y = coalesce(dest_prec_y - orig_prec, 0),
    d_elev   = dest_elev - orig_elev
  )

X_names <- c("orig_temp", "orig_prec", "d_temp_y", "d_prec_y", "d_elev",
             "base_rich", "cwm_SLA", "cwm_Hgt", "cwm_Npc", "prop_woody", "Year")

# Design propensity: treatment assigned at site level; clip empirical within-site rates to avoid extreme weights
ana <- ana %>%
  group_by(destSiteID) %>%
  mutate(W_hat_site = pmin(pmax(mean(W_bin), 0.1), 0.9)) %>%
  ungroup()

cat("\n### Missing values by covariate(n =", nrow(ana), ")###\n")
for (v in X_names) cat(sprintf("%-12s NA=%d\n", v, sum(is.na(ana[[v]]))))

## ---------------------------------------------------------------- 6. Causal forest
run_cf <- function(Yname, label) {
  d2 <- ana %>% drop_na(all_of(c(Yname, X_names, "turfID")))
  Xm <- as.matrix(d2[, X_names])
  X <- scale(Xm)
  X[, apply(X, 2, function(z) sd(z, na.rm = TRUE) == 0)] <- 0
  X[is.na(X)] <- 0
  cf <- causal_forest(X, d2[[Yname]], d2$W_bin, W.hat = d2$W_hat_site,
                      clusters = as.numeric(factor(d2$turfID)),
                      num.trees = 4000, min.node.size = 5)
  ate <- average_treatment_effect(cf)
  cat("\n====", label, "====\n")
  cat(sprintf("n=%d clusters=%d ATE=%.4f SE=%.4f 95%%CI=[%.4f, %.4f]\n",
              nrow(d2), length(unique(d2$turfID)), ate[1], ate[2],
              ate[1] - 1.96 * ate[2], ate[1] + 1.96 * ate[2]))
  cat("best linear projection:\n"); print(best_linear_projection(cf, X))
  cat("calibration:\n"); print(test_calibration(cf))
  list(cf = cf, d2 = d2, ate = ate, label = label)
}

res_rich <- run_cf("Y_rich", "v2 outcome 1: richness change (full sample)")
res_lrr  <- run_cf("Y_lrr",  "v2 outcome 2: total cover LRR (full sample)")

## ---------------------------------------------------------------- 7. Figures (English labels)
theme_set(theme_minimal(base_size = 12))
plot_dir <- "project/output"

p1 <- bind_rows(
  tibble(CATE = predict(res_rich$cf)$predictions, Outcome = "Species richness change"),
  tibble(CATE = predict(res_lrr$cf)$predictions,  Outcome = "Cover log response ratio")
) %>%
  ggplot(aes(CATE, fill = Outcome)) +
  geom_histogram(bins = 40, color = "white", linewidth = 0.1, alpha = .85, position = "identity") +
  facet_wrap(~Outcome, scales = "free_x") +
  labs(x = "Estimated CATE", y = "Number of turf-years",
       title = "Heterogeneity of warming effects (TransPlant network, full sample)") +
  theme(legend.position = "none")
ggsave(file.path(plot_dir, "fig1_cate_dist_v2.png"), p1, width = 8, height = 4, dpi = 200)

mk_bin <- function(res, xv, xlab) {
  d2 <- res$d2; cate <- predict(res$cf)$predictions
  tb <- tibble(x = d2[[xv]], cate) %>%
    mutate(bin = ntile(x, 6)) %>%
    group_by(bin) %>%
    summarise(x = mean(x), m = mean(cate), se = sd(cate) / sqrt(n()), n = n(), .groups = "drop") %>%
    mutate(lo = m - 1.96 * se, hi = m + 1.96 * se)
  ggplot(tb, aes(x, m)) +
    geom_hline(yintercept = 0, linetype = 2, color = "grey40") +
    geom_errorbar(aes(ymin = lo, ymax = hi), width = 0.15, color = "#185FA5") +
    geom_point(size = 2.4, color = "#185FA5") +
    labs(x = xlab, y = "CATE (richness change)",
         subtitle = paste0("n per bin = ", round(mean(tb$n))))
}
p2a <- mk_bin(res_rich, "orig_temp", "Origin growing-season temperature (C)") +
  labs(title = "Heterogeneity by baseline temperature")
p2b <- mk_bin(res_rich, "base_rich", "Baseline species richness") +
  labs(title = "Heterogeneity by baseline diversity", y = NULL)
ggsave(file.path(plot_dir, "fig2_cate_moderators_v2.png"), p2a + p2b, width = 9, height = 4, dpi = 200)

blp_tbl <- function(res, lab) {
  Xm2 <- scale(as.matrix(res$d2[, X_names])); Xm2[is.na(Xm2)] <- 0
  b <- best_linear_projection(res$cf, Xm2)
  tibble(var = names(b[, 1]), est = as.numeric(b[, 1]), se = as.numeric(b[, 2]), Outcome = lab)
}
p3 <- bind_rows(blp_tbl(res_rich, "Richness change"), blp_tbl(res_lrr, "Cover LRR")) %>%
  ggplot(aes(est, reorder(var, est))) +
  geom_vline(xintercept = 0, linetype = 2, color = "grey40") +
  geom_errorbarh(aes(xmin = est - 1.96 * se, xmax = est + 1.96 * se), height = .25, color = "#534AB7") +
  geom_point(color = "#534AB7", size = 2) +
  facet_wrap(~Outcome, scales = "free_x") +
  labs(x = "Standardized moderator coefficient (BLP)", y = NULL,
       title = "Best linear projection of CATE (full sample)")
ggsave(file.path(plot_dir, "fig3_blp_v2.png"), p3, width = 9, height = 4.5, dpi = 200)

## ---------------------------------------------------------------- 8. Placebo and continuous treatment dose
placebo_ate <- replicate(100, {
  d2 <- res_rich$d2
  wp <- ave(d2$W_bin, d2$destSiteID, d2$Year, FUN = function(z) sample(z))
  Xp <- scale(d2[, X_names]); Xp[is.na(Xp)] <- 0
  cf_p <- causal_forest(Xp, d2$Y_rich, wp, W.hat = d2$W_hat_site,
                        clusters = as.numeric(factor(d2$turfID)),
                        num.trees = 1000, min.node.size = 5)
  average_treatment_effect(cf_p)[1]
})
cat("\n== Placebo test (100 permutations)==\n")
cat(sprintf("placebo ATE mean=%.4f sd=%.4f | Observed ATE=%.4f\n",
            mean(placebo_ate), sd(placebo_ate), res_rich$ate[1]))

d2c <- ana %>% drop_na(all_of(c("Y_rich", X_names, "turfID")))
Xc <- scale(as.matrix(d2c[, X_names])); Xc[is.na(Xc)] <- 0
cf_c <- causal_forest(Xc, d2c$Y_rich, d2c$W_cont, W.hat = d2c$W_hat_site,
                      clusters = as.numeric(factor(d2c$turfID)), num.trees = 4000)
ate_c <- average_treatment_effect(cf_c)
cat("\n== Continuous treatment (per +1 °C transplantation temperature difference)==\n")
cat(sprintf("n=%d ATE per C=%.4f SE=%.4f\n", nrow(d2c), ate_c[1], ate_c[2]))

## ---------------------------------------------------------------- 9. Save outputs
write.csv(res_rich$d2 %>% mutate(CATE_rich = predict(res_rich$cf)$predictions,
                                 CATE_lrr  = predict(res_lrr$cf)$predictions),
          file.path(plot_dir, "turf_year_cate_v2.csv"), row.names = FALSE)
saveRDS(list(rich = res_rich, lrr = res_lrr, cont = cf_c),
        file.path(plot_dir, "cf_results_v2.rds"))
cat("\n== v2 complete ==\n")
