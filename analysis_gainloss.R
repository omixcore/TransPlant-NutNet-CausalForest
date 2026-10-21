## ============================================================================
##  Gain / loss decomposition: what drives the net richness change?
##  For each turf-year: colonisations (species absent at baseline, present now)
##  and extinctions (baseline species now absent). Net = gains - losses.
##  This is the mechanism evidence behind the "turnover not biomass" claim.
## ============================================================================
.libPaths(c("project/rlibs", .libPaths()))
suppressPackageStartupMessages({ library(dplyr); library(tidyr); library(grf) })
set.seed(20261021)   # fixed so the joint-inference script reproduces these forests exactly

out <- "project/output"
dir.create(out, showWarnings = FALSE, recursive = TRUE)

e <- new.env(); load("project/data/TransPlantNetwork.RData", envir = e)
dat <- as.data.frame(e$dat) %>%
  mutate(turf_key = paste(Region, originSiteID, destSiteID, turfID, sep = "|"),
         present  = !is.na(Cover) & Cover > 0)

## species sets per turf-year
sets <- dat %>% filter(present) %>%
  distinct(turf_key, Year, SpeciesName)

base <- sets %>%
  group_by(turf_key) %>%
  filter(Year == min(Year)) %>%
  ungroup() %>%
  rename(base_year = Year) %>%
  distinct(turf_key, base_year)

base_sp <- sets %>% inner_join(base, by = c("turf_key", "Year" = "base_year")) %>%
  distinct(turf_key, SpeciesName) %>%
  mutate(in_base = TRUE)

## per turf-year counts
gl <- sets %>%
  left_join(base_sp, by = c("turf_key", "SpeciesName")) %>%
  group_by(turf_key, Year) %>%
  summarise(n_now = n_distinct(SpeciesName),
            gains = sum(is.na(in_base)),
            .groups = "drop")

base_n <- base_sp %>% count(turf_key, name = "n_base")
gl <- gl %>% left_join(base_n, by = "turf_key") %>%
  mutate(losses = n_base - (n_now - gains),
         net    = gains - losses,
         turnover = gains + losses)

cat("### 定殖/灭绝分解 ###\n")
cat("turf-years:", nrow(gl), "\n")
cat(sprintf("mean gains %.3f | mean losses %.3f | mean net %.3f | mean turnover %.3f\n",
            mean(gl$gains), mean(gl$losses), mean(gl$net), mean(gl$turnover)))

res <- readRDS(file.path(out, "cf_results_v3.rds"))
d2  <- res$rich$d2
chk <- d2 %>% left_join(gl %>% dplyr::select(turf_key, Year, gains, losses, net, turnover),
                        by = c("turf_key", "Year"))
cat("merge rate:", round(mean(!is.na(chk$gains)), 4), "\n")
cat("cor(net, Y_rich) =", round(cor(chk$net, chk$Y_rich, use = "complete.obs"), 4),
    " | max |net - Y_rich| =", max(abs(chk$net - chk$Y_rich), na.rm = TRUE), "\n")

X_names <- c("orig_temp", "orig_prec", "d_temp_y", "d_prec_y", "d_elev",
             "base_rich", "cwm_SLA", "cwm_Hgt", "cwm_Npc", "prop_woody", "Year")

run_cf <- function(data, Yname, label) {
  dd <- data %>% drop_na(all_of(c(Yname, X_names, "turf_key")))
  Xm <- as.matrix(dd[, X_names]); X <- scale(Xm)
  X[, apply(X, 2, function(z) sd(z, na.rm = TRUE) == 0)] <- 0
  X[is.na(X)] <- 0
  cf <- causal_forest(X, dd[[Yname]], dd$W_bin, W.hat = dd$W_hat_site,
                      clusters = as.numeric(factor(dd$turf_key)),
                      num.trees = 4000, min.node.size = 5)
  ate <- average_treatment_effect(cf)
  cat(sprintf("\n== %s ==\nn=%d ATE=%.4f SE=%.4f 95%%CI=[%.4f, %.4f] p=%.4f\n",
              label, nrow(dd), ate[1], ate[2],
              ate[1] - 1.96 * ate[2], ate[1] + 1.96 * ate[2],
              2 * pnorm(-abs(ate[1] / ate[2]))))
  blp <- best_linear_projection(cf, X)
  print(round(blp, 4))
  list(cf = cf, d2 = dd, ate = ate, blp = blp)
}

r_gain <- run_cf(chk, "gains",    "定殖数（colonisations）")
r_loss <- run_cf(chk, "losses",   "灭绝数（extinctions）")
r_turn <- run_cf(chk, "turnover", "总周转（gains + losses）")

## phase split for turnover (ys = 0 is the baseline year itself and is excluded)
chk <- chk %>% mutate(ys = Year - base_year)
phases <- list(list(1, 1, "year 1"), list(2, 2, "year 2"),
               list(3, 99, "year >= 3"), list(2, 99, "year >= 2"))
phase_rows <- list()
for (ph in phases) {
  sub <- chk %>% filter(ys >= ph[[1]], ys <= ph[[2]])
  if (nrow(sub) < 30) next
  r <- run_cf(sub, "turnover", paste0("turnover | ", ph[[3]]))
  phase_rows[[length(phase_rows) + 1]] <-
    data.frame(phase = ph[[3]], n = nrow(sub), est = r$ate[1], se = r$ate[2])
}

## tidy ATE table
ate_tbl <- bind_rows(
  data.frame(outcome = c("colonisations", "extinctions", "turnover"),
             est = c(r_gain$ate[1], r_loss$ate[1], r_turn$ate[1]),
             se  = c(r_gain$ate[2], r_loss$ate[2], r_turn$ate[2]))
) %>% mutate(lo = est - 1.96 * se, hi = est + 1.96 * se,
             p  = 2 * pnorm(-abs(est / se)))
write.csv(ate_tbl, file.path(out, "gainloss_ate.csv"), row.names = FALSE)
if (length(phase_rows)) {
  ph_tbl <- bind_rows(phase_rows)
  ph_tbl$lo <- ph_tbl$est - 1.96 * ph_tbl$se
  ph_tbl$hi <- ph_tbl$est + 1.96 * ph_tbl$se
  ph_tbl$p  <- 2 * pnorm(-abs(ph_tbl$est / ph_tbl$se))
  write.csv(ph_tbl, file.path(out, "gainloss_turnover_phase.csv"), row.names = FALSE)
  cat("\nphase-specific turnover:\n"); print(ph_tbl, digits = 3)
}
write.csv(chk %>% dplyr::select(turf_key, Region, Treatment, Year, ys, W_bin, W_cont,
                                gains, losses, net, turnover, base_rich, orig_temp),
          file.path(out, "gainloss_panel.csv"), row.names = FALSE)
cat("\nwrote gainloss_ate.csv / gainloss_panel.csv\n")
