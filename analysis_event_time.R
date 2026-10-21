# v3b：事件时间分析（移栽后年数）+ 期内 OLS 交叉验证
.libPaths(c("project/rlibs", .libPaths()))
suppressPackageStartupMessages({library(grf); library(dplyr); library(ggplot2)})
set.seed(20261021)

res <- readRDS("project/output/cf_results_v3.rds")
rich <- res$rich
d2 <- rich$d2
X_names <- c("orig_temp", "orig_prec", "d_temp_y", "d_prec_y", "d_elev",
             "base_rich", "cwm_SLA", "cwm_Hgt", "cwm_Npc", "prop_woody", "Year")

## 基线年已在 v3 面板中按复合键算出
d2 <- d2 %>% mutate(ys = Year - base_year)

cat("== 移栽后年数分布 ==\n"); print(table(d2$ys))

## ---- 1) 分年段的森林 ATE
run_sub <- function(sub, lab) {
  X <- scale(as.matrix(sub[, X_names])); X[is.na(X)] <- 0
  cf <- causal_forest(X, sub$Y_rich, sub$W_bin, W.hat = sub$W_hat_site,
                      clusters = as.numeric(factor(sub$turf_key)),
                      num.trees = 4000, min.node.size = 5)
  a <- average_treatment_effect(cf)
  cat(sprintf("%-22s n=%4d  ATE=%+.3f  SE=%.3f  95%%CI=[%+.3f, %+.3f]\n",
              lab, nrow(sub), a[1], a[2], a[1]-1.96*a[2], a[1]+1.96*a[2]))
  invisible(c(a[1], a[2], nrow(sub)))
}

cat("\n== 分移栽后年段的 ATE（丰富度变化）==\n")
run_sub(d2 %>% filter(ys == 1), "year 1")
run_sub(d2 %>% filter(ys == 2), "year 2")
run_sub(d2 %>% filter(ys >= 3), "year >= 3")
run_sub(d2 %>% filter(ys >= 2), "year >= 2 (established)")

## ---- 2) 事件时间曲线：CATE 均值
cate <- predict(rich$cf)$predictions
d2$CATE <- cate
ev <- d2 %>% group_by(ys) %>%
  summarise(m = mean(CATE), se = sd(CATE)/sqrt(n()), n = n(), .groups = "drop") %>%
  filter(n >= 20)
p <- ggplot(ev, aes(ys, m)) +
  geom_hline(yintercept = 0, linetype = 2, colour = "grey40") +
  geom_ribbon(aes(ymin = m-1.96*se, ymax = m+1.96*se), alpha = .18, fill = "#185FA5") +
  geom_line(colour = "#185FA5", linewidth = .8) +
  geom_point(colour = "#185FA5", size = 2) +
  labs(x = "Years since transplant", y = "Estimated CATE (richness change)",
       subtitle = "Bins with n >= 20 turf-years") +
  theme_minimal(base_size = 12)
ggsave("project/output/fig5_event_time_v3.png", p, width = 6, height = 4, dpi = 200)

## ---- 3) OLS 交互项 + 样方聚类稳健标准误
ols_cluster <- function(formula, data, cluster) {
  m <- lm(formula, data = data)
  X <- model.matrix(m); y <- model.response(model.frame(m))
  u <- resid(m)
  bread <- solve(crossprod(X))
  cl <- factor(cluster)
  meat <- Reduce(`+`, lapply(split(seq_len(nrow(X)), cl), function(ix) {
    s <- crossprod(X[ix, , drop = FALSE], u[ix]); tcrossprod(s)
  }))
  G <- nlevels(cl); n <- nrow(X); k <- ncol(X)
  V <- bread %*% meat %*% bread * (G/(G-1)) * ((n-1)/(n-k))
  se <- sqrt(diag(V))
  data.frame(term = rownames(summary(m)$coefficients),
             est = coef(m), se = se, t = coef(m)/se,
             p = 2*pt(-abs(coef(m)/se), df = G-1))
}

cat("\n== OLS：Y_rich ~ W_bin * years_since + region FE（样方聚类 SE）==\n")
o <- ols_cluster(Y_rich ~ W_bin * ys + factor(Region), d2, d2$turf_key)
print(o %>% filter(grepl("W_bin|ys", term)) %>% mutate(across(c(est, se, t, p), ~round(.x, 3))))

cat("\n== 同规格：仅挪威+Gongga 子集（v2 曾用的区域）==\n")
sub5 <- d2 %>% filter(Region %in% c("CN_Gongga","NO_Gudmedalen","NO_Lavisdalen",
                                    "NO_Skjellingahaugen","NO_Ulvhaugen"))
o5 <- ols_cluster(Y_rich ~ W_bin * ys + factor(Region), sub5, sub5$turf_key)
print(o5 %>% filter(grepl("W_bin|ys", term)) %>% mutate(across(c(est, se, t, p), ~round(.x, 3))))
cat("子集 n =", nrow(sub5), "| turfs =", n_distinct(sub5$turf_key), "\n")

cat("\n== 亚组 ATE（按区域）==\n")
for (r in sort(unique(d2$Region))) {
  s <- d2 %>% filter(Region == r)
  if (n_distinct(s$turf_key) < 8) next
  X <- scale(as.matrix(s[, X_names])); X[is.na(X)] <- 0
  cf <- causal_forest(X, s$Y_rich, s$W_bin, W.hat = s$W_hat_site,
                      clusters = as.numeric(factor(s$turf_key)),
                      num.trees = 2000, min.node.size = 5)
  a <- average_treatment_effect(cf)
  cat(sprintf("%-20s n=%4d turfs=%3d ATE=%+.2f (SE %.2f)\n",
              r, nrow(s), n_distinct(s$turf_key), a[1], a[2]))
}
