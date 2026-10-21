# =====================================================================
# Network 2 prototype: NutNet-derived data (EDI knb-lter-cdr.692.1, e247)
# Nine grassland sites × four treatments (Ctrl/N/P/NP) × 9–10 years, with climate and soil covariates
# Question: causal effects of nutrient addition on productivity and heterogeneity across climate
# Note: n=120 is a pipeline demonstration; full global data require the nutnet.org agreement
#       Rerun on core data (~200 sites) using the same column names
# =====================================================================

.libPaths(c("project/rlibs", .libPaths()))
library(grf)
library(dplyr)
library(ggplot2)
library(patchwork)

set.seed(20261021)

d <- read.csv("project/data/e247_plant_soil.csv", sep = "\t", check.names = FALSE)
names(d) <- gsub("[ .]", "_", names(d))

d2 <- d %>%
  mutate(
    W = as.integer(trt %in% c("N", "NP")),   # nitrogen vs control (P handled separately)
    Y = anpp                                  # aboveground net primary productivity, g/m2/yr
  ) %>%
  filter(!is.na(Y), trt %in% c("Ctrl", "N", "NP"))

X_names <- c("MAT_v2", "MAP_v2", "PET", "AI", "N_Dep", "elevation", "pH", "soilC_0015", "year_trt")
d2 <- d2 %>% mutate(across(all_of(X_names), ~ coalesce(.x, median(.x, na.rm = TRUE))))

cat(sprintf("n=%d sites=%d treated=%d\n", nrow(d2), length(unique(d2$site)), sum(d2$W)))

X <- scale(as.matrix(d2[, X_names])); X[is.na(X)] <- 0
W_hat <- pmin(pmax(ave(d2$W, d2$site), 0.15), 0.85)   # within-site design propensity

cf <- causal_forest(X, d2$Y, d2$W, W.hat = W_hat,
                    clusters = as.numeric(factor(d2$site)),
                    num.trees = 4000, min.node.size = 5)
ate <- average_treatment_effect(cf)
cat(sprintf("\n==== NutNet e247: causal effect of nitrogen addition on ANPP ====\n"))
cat(sprintf("ATE = %.1f g/m2 (SE %.1f) 95%%CI [%.1f, %.1f]\n",
            ate[1], ate[2], ate[1] - 1.96 * ate[2], ate[1] + 1.96 * ate[2]))
cat("\nbest linear projection:\n")
print(best_linear_projection(cf, X))

cate <- predict(cf)$predictions
tb <- tibble(MAP = d2$MAP_v2, cate) %>%
  mutate(bin = ntile(MAP, 3)) %>%
  group_by(bin) %>% summarise(MAP = mean(MAP), m = mean(cate), se = sd(cate)/sqrt(n()), .groups="drop") %>%
  mutate(lo = m - 1.96*se, hi = m + 1.96*se)

p4 <- ggplot(tb, aes(MAP, m)) +
  geom_errorbar(aes(ymin=lo, ymax=hi), width=40, color="#0F6E56") +
  geom_point(size=3, color="#0F6E56") +
  geom_hline(yintercept=0, linetype=2, color="grey40") +
  labs(x="Mean annual precipitation (mm)", y="CATE: N effect on ANPP (g/m2)",
       title="NutNet e247 prototype: fertilization effect heterogeneity",
       subtitle=sprintf("ATE = %.0f g/m2; n=%d plots, %d sites", ate[1], nrow(d2), length(unique(d2$site))))
ggsave("project/output/fig4_nutnet.png", p4, width=7, height=4.2, dpi=200)

write.csv(d2 %>% mutate(CATE = cate), "project/output/nutnet_plot_cate.csv", row.names=FALSE)
saveRDS(cf, "project/output/cf_nutnet.rds")

# Control check: P-only effect (multi-treatment illustration)
dP <- d %>% filter(trt %in% c("Ctrl", "P"), !is.na(anpp)) %>%
  mutate(W = as.integer(trt == "P")) %>%
  mutate(across(all_of(X_names), ~ coalesce(.x, median(.x, na.rm = TRUE))))
XP <- scale(as.matrix(dP[, X_names])); XP[is.na(XP)] <- 0
cfP <- causal_forest(XP, dP$anpp, dP$W, W.hat = pmin(pmax(ave(dP$W, dP$site), .15), .85),
                     clusters = as.numeric(factor(dP$site)), num.trees = 4000)
ateP <- average_treatment_effect(cfP)
cat(sprintf("\nP-only ATE = %.1f g/m2 (SE %.1f)\n", ateP[1], ateP[2]))
cat("== NutNet prototype complete ==\n")
