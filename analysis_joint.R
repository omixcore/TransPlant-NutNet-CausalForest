## ============================================================================
##  Joint inference for the gain/loss decomposition and the net effect
##
##  analysis_gainloss.R estimated colonisations, extinctions and total
##  turnover with three *separate* forests, and the net richness change with
##  a fourth. Each marginal ATE is valid, but quantities that combine them
##  (additivity, turnover minus net) require the *covariances* between the
##  four estimators, which separate forests do not provide. Because the four
##  forests are evaluated on the same 1,171 turf-years, the AIPW influence
##  scores (grf::get_scores) are row-aligned, and cluster-robust joint
##  covariance follows from clustering those scores by turf.
##
##  Outputs:
##   - joint_ate.csv          : ATEs with (unchanged) marginal SEs
##   - additivity_test.csv    : tests of the identities
##       (i)   colonisations - extinctions = net richness change
##       (ii)  turnover - net richness change = 0 (i.e. flux = imbalance)
##       (iii) colonisations = extinctions  (symmetric acceleration)
##   - joint_cov.csv          : cluster-robust covariance matrix of the ATEs
## ============================================================================

.libPaths(c("project/rlibs", .libPaths()))
suppressPackageStartupMessages({ library(dplyr); library(grf) })

out <- "project/output"
set.seed(20261021)

## ---------------------------------------------------------------- 1. data: the exact v3 analysis frame
res <- readRDS(file.path(out, "cf_results_v3.rds"))
d2  <- res$rich$d2

X_names <- c("orig_temp", "orig_prec", "d_temp_y", "d_prec_y", "d_elev",
             "base_rich", "cwm_SLA", "cwm_Hgt", "cwm_Npc", "prop_woody", "Year")
Xm <- as.matrix(d2[, X_names]); X <- scale(Xm)
X[, apply(X, 2, function(z) sd(z, na.rm = TRUE) == 0)] <- 0
X[is.na(X)] <- 0
cl <- as.numeric(factor(d2$turf_key))

gl <- read.csv(file.path(out, "gainloss_panel.csv"))
stopifnot(nrow(gl) == nrow(d2))
m <- match(paste(d2$turf_key, d2$Year), paste(gl$turf_key, gl$Year))
stopifnot(!any(is.na(m)))
Y_gains <- gl$gains[m]; Y_losses <- gl$losses[m]; Y_turn <- gl$turnover[m]
Y_net   <- d2$Y_rich
W       <- d2$W_bin; W_hat <- d2$W_hat_site

## ---------------------------------------------------------------- 2. four forests (identical spec)
fit <- function(Y) {
  cf <- causal_forest(X, Y, W, W.hat = W_hat, clusters = cl,
                      num.trees = 4000, min.node.size = 5)
  s <- as.numeric(get_scores(cf))
  list(ate = mean(s), scores = s, cf = cf)
}
## net first (reproduces analysis_causal_forest_v3.R exactly), then re-seed so
## that gains/losses/turnover follow the same random stream as analysis_gainloss.R
f_net <- fit(Y_net)
set.seed(20261021)
f_gain <- fit(Y_gains); f_loss <- fit(Y_losses); f_turn <- fit(Y_turn)
cat(sprintf("ATEs: net %.4f | gains %.4f | losses %.4f | turnover %.4f\n",
            f_net$ate, f_gain$ate, f_loss$ate, f_turn$ate))

## ---------------------------------------------------------------- 3. cluster-robust joint covariance
##    theta_j = mean of scores j. Cluster-robust variance of a mean:
##    Var(theta) = (1/n^2) * sum_c (sum_{i in c} e_i)(...)',  e_i = s_i - theta.
S  <- cbind(net = f_net$scores, gains = f_gain$scores,
            losses = f_loss$scores, turnover = f_turn$scores)
Sc <- sweep(S, 2, colMeans(S))       # centre the influence scores
Gc <- rowsum(Sc, group = cl)         # m x 4 cluster sums of centred scores
n_total <- nrow(S)
mm <- length(unique(cl))
V  <- (t(Gc) %*% Gc) / n_total^2     # cluster-robust cov of the four ATEs
V  <- V * mm / (mm - 1)              # small-sample correction, m clusters
se <- sqrt(diag(V))
cat("\n### Marginal SE comparison (this script vs original pipeline)###\n")
cat(sprintf("net:      joint %.4f | grf %.4f\ngains:    joint %.4f | grf %.4f\nlosses:   joint %.4f | grf %.4f\nturnover: joint %.4f | grf %.4f\n",
            se[1], res$rich$ate[2], se[2], 0.4654, se[3], 0.3007, se[4], 0.5995))

## ---------------------------------------------------------------- 4. identity tests (delta method)
lin <- function(w) {           # linear combination est + SE from V
  e <- sum(w * c(f_net$ate, f_gain$ate, f_loss$ate, f_turn$ate))
  v <- as.numeric(t(w) %*% V %*% w)
  c(est = e, se = sqrt(v))
}
t_add  <- lin(c(-1, 1, -1, 0))    # (gains - losses) - net  = 0 ?
t_flux <- lin(c(-1, 0, 0, 1))     # turnover - net          = 0 ?
t_sym  <- lin(c(0, 1, -1, 0))     # gains - losses          = 0 ?
z <- function(x) c(est = x[["est"]], se = x[["se"]],
                   z = x[["est"]] / x[["se"]],
                   p = 2 * pnorm(-abs(x[["est"]] / x[["se"]])))
tests <- rbind(
  "additivity: (colonisations - extinctions) - net = 0" = z(t_add),
  "flux identity: turnover - net = 0"                   = z(t_flux),
  "symmetry: colonisations - extinctions = 0"           = z(t_sym))
tests <- round(tests, 4)
cat("\n### Joint identity tests ###\n"); print(tests)

## ---------------------------------------------------------------- 5. export
ate_tbl <- data.frame(
  outcome = c("net_richness", "colonisations", "extinctions", "turnover"),
  ate = c(f_net$ate, f_gain$ate, f_loss$ate, f_turn$ate),
  se_joint = se, se_grf = c(res$rich$ate[2], 0.4654, 0.3007, 0.5995))
write.csv(ate_tbl, file.path(out, "joint_ate.csv"), row.names = FALSE)
write.csv(data.frame(test = rownames(tests), tests, row.names = NULL),
          file.path(out, "additivity_test.csv"), row.names = FALSE)
write.csv(round(V, 6), file.path(out, "joint_cov.csv"))
cat("\nwrote joint_ate.csv / additivity_test.csv / joint_cov.csv\n")
