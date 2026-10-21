## ============================================================================
##  Robustness / reviewer-facing diagnostics for the TransPlant causal forest
##  (1) FDR correction on the best linear projection
##  (2) Calibration test (Chernozhukov et al.) reported explicitly
##  (3) Overlap / propensity-score diagnostics
##  (4) Cluster level sensitivity: turf vs destination site
##  (5) Leave-one-region-out ATE
##  (6) Hyperparameter sensitivity (num.trees, min.node.size)
##  (7) Minimum detectable effect at 80% power
## ============================================================================
.libPaths(c("project/rlibs", .libPaths()))
suppressPackageStartupMessages({ library(dplyr); library(grf) })

out <- "project/output"
res <- readRDS(file.path(out, "cf_results_v3.rds"))

X_names <- c("orig_temp", "orig_prec", "d_temp_y", "d_prec_y", "d_elev",
             "base_rich", "cwm_SLA", "cwm_Hgt", "cwm_Npc", "prop_woody", "Year")

make_X <- function(d) {
  X <- scale(as.matrix(d[, X_names]))
  X[, apply(X, 2, function(z) sd(z, na.rm = TRUE) == 0)] <- 0
  X[is.na(X)] <- 0
  X
}

## ------------------------------------------------ (1)+(2) BLP with BH-FDR
cat("\n############ (1) BLP + BH-FDR ############\n")
blp_all <- list()
for (nm in c("rich", "lrr")) {
  rr <- res[[nm]]
  X <- make_X(rr$d2)
  b <- best_linear_projection(rr$cf, X)
  df <- data.frame(outcome = nm, term = rownames(b),
                   est = b[, 1], se = b[, 2], p = b[, 4], row.names = NULL)
  df$p_BH <- p.adjust(df$p, method = "BH")
  blp_all[[nm]] <- df
  cat("\n--", nm, "--\n"); print(df, digits = 4)
}
blp_df <- bind_rows(blp_all)
write.csv(blp_df, file.path(out, "blp_fdr.csv"), row.names = FALSE)

cat("\n############ (2) Calibration test ############\n")
for (nm in c("rich", "lrr")) {
  cat("\n--", nm, "--\n")
  print(test_calibration(res[[nm]]$cf))
}

## ------------------------------------------------ (3) Overlap diagnostics
cat("\n############ (3) Overlap / propensity ############\n")
d2 <- res$rich$d2
cat(sprintf("W.hat (design) range: %.3f - %.3f | mean %.3f\n",
            min(d2$W_hat_site), max(d2$W_hat_site), mean(d2$W_hat_site)))
cat(sprintf("treated fraction: %.3f | n sites: %d | sites with both arms: %d\n",
            mean(d2$W_bin), n_distinct(d2$destSiteID),
            sum(tapply(d2$W_bin, d2$destSiteID, function(z) length(unique(z)) > 1))))
ov <- data.frame(W_hat = d2$W_hat_site)
write.csv(ov, file.path(out, "overlap_what.csv"), row.names = FALSE)

## ------------------------------------------------ (4) Cluster level
cat("\n############ (4) Cluster level: turf vs site ############\n")
Xr <- make_X(d2)
cf_site <- causal_forest(Xr, d2$Y_rich, d2$W_bin, W.hat = d2$W_hat_site,
                         clusters = as.numeric(factor(d2$destSiteID)),
                         num.trees = 4000, min.node.size = 5)
a_site <- average_treatment_effect(cf_site)
a_turf <- average_treatment_effect(res$rich$cf)
cat(sprintf("turf-clustered: ATE %.4f SE %.4f\nsite-clustered: ATE %.4f SE %.4f\n",
            a_turf[1], a_turf[2], a_site[1], a_site[2]))
mde <- (1.96 + 0.84) * a_site[2]
cat(sprintf("MDE (80%% power, site-clustered SE) = %.2f species\n", mde))

write.csv(data.frame(cluster = c("turf", "site"),
                     ate = c(a_turf[1], a_site[1]),
                     se  = c(a_turf[2], a_site[2])),
          file.path(out, "cluster_sensitivity.csv"), row.names = FALSE)

## ------------------------------------------------ (5) Leave-one-region-out
cat("\n############ (5) Leave-one-region-out ############\n")
regions <- sort(unique(d2$Region))
loo <- lapply(regions, function(rg) {
  sub <- d2 %>% filter(Region != rg)
  Xs <- make_X(sub)
  cf <- causal_forest(Xs, sub$Y_rich, sub$W_bin, W.hat = sub$W_hat_site,
                      clusters = as.numeric(factor(sub$turf_key)),
                      num.trees = 2000, min.node.size = 5)
  a <- average_treatment_effect(cf)
  data.frame(dropped = rg, n = nrow(sub), ate = a[1], se = a[2])
})
loo_df <- bind_rows(loo)
loo_df$lo <- loo_df$ate - 1.96 * loo_df$se
loo_df$hi <- loo_df$ate + 1.96 * loo_df$se
print(loo_df, digits = 3)
cat(sprintf("\nLOO ATE range: %.3f to %.3f | full-sample ATE: %.3f\n",
            min(loo_df$ate), max(loo_df$ate), a_turf[1]))
write.csv(loo_df, file.path(out, "leave_one_region_out.csv"), row.names = FALSE)

## ------------------------------------------------ (6) Hyperparameters
cat("\n############ (6) Hyperparameter sensitivity ############\n")
grid <- expand.grid(num.trees = c(2000, 4000), min.node.size = c(2, 5, 10))
hp <- lapply(seq_len(nrow(grid)), function(i) {
  cf <- causal_forest(Xr, d2$Y_rich, d2$W_bin, W.hat = d2$W_hat_site,
                      clusters = as.numeric(factor(d2$turf_key)),
                      num.trees = grid$num.trees[i],
                      min.node.size = grid$min.node.size[i])
  a <- average_treatment_effect(cf)
  data.frame(num.trees = grid$num.trees[i], min.node.size = grid$min.node.size[i],
             ate = a[1], se = a[2])
})
hp_df <- bind_rows(hp)
print(hp_df, digits = 3)
write.csv(hp_df, file.path(out, "hyperparameter_sensitivity.csv"), row.names = FALSE)

## ------------------------------------------------ session info
sink(file.path(out, "session_info.txt"))
cat("Run:", format(Sys.time()), "\n\n")
print(sessionInfo())
sink()
cat("\nwrote blp_fdr.csv / cluster_sensitivity.csv / leave_one_region_out.csv /\n",
    "     hyperparameter_sensitivity.csv / overlap_what.csv / session_info.txt\n")
