# =====================================================================
# 公共数据库 + 因果森林（角度 A 原型管线）
# 数据：TransPlant 网络（OSF: doi.org/10.17605/OSF.IO/9874T）
# 问题：群落移栽（变暖处理）对物种丰富度 / 总盖度的因果效应，
#       以及效应在基线气候与群落性状上的异质性（CATE）
# 运行：R >= 4.5, grf, dplyr, tidyr, ggplot2（已装于 project/rlibs）
# =====================================================================

.libPaths(c("project/rlibs", .libPaths()))
library(grf)
library(dplyr)
library(tidyr)
library(ggplot2)

dir.create("project/output", showWarnings = FALSE)
set.seed(20261021)

## ---------------------------------------------------------------- 1. 载入
e <- new.env()
load("project/data/TransPlantNetwork.RData", envir = e)
dat    <- as.data.frame(e$dat)        # 60,535 行：turf × 年 × 物种 盖度
clim   <- as.data.frame(e$climdata)   # 月度气候：温度 / 降水 / PET（1979-2019）
traits <- as.data.frame(e$alltraits)  # 物种 × 站点性状（实测 + TRY 兜底）

cat("== 原始数据：", nrow(dat), "行,", length(unique(dat$turfID)), "turf ==")

## ---------------------------------------------------------------- 2. 气候变量构建
# 生长季（5-9 月）站点气候：长期常态（1979-2010）与逐年实际值
gs <- clim %>% filter(month %in% 5:9)

normals <- gs %>% filter(year <= 2010) %>%
  group_by(destSiteID, var) %>%
  summarise(
    temp_normal = if (first(var) == "temperature") mean(value, na.rm = TRUE) else NA_real_,
    prec_normal = if (first(var) == "precipitation") sum(value, na.rm = TRUE) / length(unique(year)) else NA_real_,
    .groups = "drop"
  ) %>%
  group_by(destSiteID) %>%
  summarise(across(c(temp_normal, prec_normal), ~ mean(.x, na.rm = TRUE)), .groups = "drop")

yearly <- gs %>%
  group_by(destSiteID, var, year) %>%
  summarise(
    temp_y = if (first(var) == "temperature") mean(value, na.rm = TRUE) else NA_real_,
    prec_y = if (first(var) == "precipitation") sum(value, na.rm = TRUE) else NA_real_,
    .groups = "drop"
  ) %>%
  group_by(destSiteID, year) %>%
  summarise(across(c(temp_y, prec_y), ~ mean(.x, na.rm = TRUE)), .groups = "drop")

site_elev <- clim %>% distinct(destSiteID, elevation) %>%
  group_by(destSiteID) %>% summarise(elev = mean(elevation, na.rm = TRUE), .groups = "drop")

## ---------------------------------------------------------------- 3. turf × 年 面板
panel0 <- dat %>%
  group_by(Region, originSiteID, destSiteID, Treatment, turfID, Year) %>%
  summarise(
    richness = n_distinct(SpeciesName),
    tot_cover = sum(Cover, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  group_by(turfID) %>%
  arrange(Year, .by_group = TRUE) %>%
  mutate(base_year = first(Year)) %>%
  ungroup()

base_tbl <- panel0 %>% filter(Year == base_year) %>%
  dplyr::select(Region, originSiteID, destSiteID, turfID, base_rich = richness, base_cover = tot_cover)

panel <- panel0 %>%
  left_join(base_tbl, by = c("Region", "originSiteID", "destSiteID", "turfID")) %>%
  mutate(
    Y_rich = richness - base_rich,                       # 结果 1：丰富度变化
    Y_lrr  = log((tot_cover + 1) / (base_cover + 1))     # 结果 2：盖度对数响应比
  )
## ---------------------------------------------------------------- 4. 基线群落性状 CWM
# 物种性状：实测优先，TRY 值兜底
# 物种性状：实测优先，站点内物种均值次之，跨区域物种级 TRY 均值兜底
sp_fallback <- traits %>%
  mutate(
    SLA_fb  = TSLA_cm2_g,
    Hgt_fb  = TPlant_Veg_Height_cm,
    Npc_fb  = TN_percent
  ) %>%
  group_by(SpeciesName) %>%
  summarise(across(c(SLA_fb, Hgt_fb, Npc_fb), ~ mean(.x, na.rm = TRUE)), .groups = "drop")

sp_traits <- traits %>%
  mutate(
    SLA  = coalesce(SLA_cm2_g, TSLA_cm2_g),
    Hgt  = coalesce(Plant_Veg_Height_cm, TPlant_Veg_Height_cm),
    Npc  = coalesce(N_percent, TN_percent),
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

base_rows <- panel %>% filter(Year == base_year) %>% dplyr::select(Region, originSiteID, destSiteID, turfID, base_year)
sp_base   <- dat %>%
  left_join(base_rows, by = c("Region", "originSiteID", "destSiteID", "turfID")) %>%
  filter(Year == base_year) %>%   # 基线年记录
  left_join(sp_traits, by = c("Region", "destSiteID", "SpeciesName"))

cwm <- sp_base %>%
  group_by(Region, destSiteID, turfID) %>%
  summarise(
    cwm_SLA   = weighted.mean(SLA,  Cover, na.rm = TRUE),
    cwm_Hgt   = weighted.mean(Hgt,  Cover, na.rm = TRUE),
    cwm_Npc   = weighted.mean(Npc,  Cover, na.rm = TRUE),
    prop_woody = weighted.mean(woody_num, Cover, na.rm = TRUE),
    .groups = "drop"
  )

## ---------------------------------------------------------------- 5. 合并协变量
ana <- panel %>%
  left_join(normals, by = c("originSiteID" = "destSiteID")) %>%   # 来源地常态
  rename(orig_temp = temp_normal, orig_prec = prec_normal) %>%
  left_join(normals, by = c("destSiteID" = "destSiteID")) %>%     # 目的地常态
  rename(dest_temp = temp_normal, dest_prec = prec_normal) %>%
  left_join(rename(yearly, orig_temp_y = temp_y, orig_prec_y = prec_y),
            by = c("originSiteID" = "destSiteID", "Year" = "year")) %>%
  left_join(rename(yearly, dest_temp_y = temp_y, dest_prec_y = prec_y),
            by = c("destSiteID" = "destSiteID", "Year" = "year")) %>%
  left_join(cwm, by = c("Region", "destSiteID", "turfID")) %>%
  left_join(site_elev, by = c("originSiteID" = "destSiteID")) %>%
  rename(orig_elev = elev) %>%
  left_join(site_elev, by = c("destSiteID" = "destSiteID")) %>%
  rename(dest_elev = elev) %>%
  mutate(
    W_bin = as.integer(Treatment == "Warm"),
    W_cont = dest_temp - orig_temp,                 # 处理强度：目的地-来源地生长季温差
    d_temp_y  = coalesce(dest_temp_y - orig_temp, dest_temp - orig_temp),  # 气候数据缺失年份用常态替代
    d_prec_y  = coalesce(dest_prec_y - orig_prec, 0),
    d_elev    = dest_elev - orig_elev
  ) %>%
  filter(complete.cases(W_cont, orig_temp, orig_prec, d_elev))

cat("\n== 分析面板：", nrow(ana), "turf-年，", length(unique(ana$turfID)), "turf ==")
cat("\n处理强度分布（Warm 组）:\n"); print(summary(ana$W_cont[ana$W_bin == 1]))
cat("\n处理强度分布（Control 组）:\n"); print(summary(ana$W_cont[ana$W_bin == 0]))

## ---------------------------------------------------------------- 6. 因果森林
X_names <- c("orig_temp", "orig_prec", "d_temp_y", "d_prec_y", "d_elev",
             "base_rich", "cwm_SLA", "cwm_Hgt", "cwm_Npc", "prop_woody", "Year")

run_cf <- function(ana, Yname, Wname = "W_bin", label) {
  d2 <- ana %>% drop_na(all_of(c(Yname, X_names, Wname, "turfID")))
  X <- as.matrix(d2[, X_names])
  X <- scale(X)
  W <- d2[[Wname]]
  Y <- d2[[Yname]]
  cf <- causal_forest(X, Y, W,
                      clusters = as.numeric(factor(d2$turfID)),
                      num.trees = 4000, min.node.size = 5)
  ate <- average_treatment_effect(cf)
  cat("\n====", label, "====\n")
  cat("n =", nrow(d2), " clusters =", length(unique(d2$turfID)), "\n")
  cat("ATE =", round(ate[1], 4), " SE =", round(ate[2], 4),
      " 95%CI = [", round(ate[1] - 1.96 * ate[2], 4), ",", round(ate[1] + 1.96 * ate[2], 4), "]\n")
  cat("best linear projection:\n"); print(best_linear_projection(cf, X))
  cat("balance / calibration:\n"); print(test_calibration(cf))
  list(cf = cf, d2 = d2, ate = ate, label = label)
}

res_rich <- run_cf(ana, "Y_rich", "W_bin", "结果 1：物种丰富度变化（Warm vs Control）")
res_lrr  <- run_cf(ana, "Y_lrr",  "W_bin", "结果 2：总盖度 LRR（Warm vs Control）")

## ---------------------------------------------------------------- 7. 图
theme_set(theme_minimal(base_size = 12))
plot_dir <- "project/output"

# 图 1：CATE 分布
p1 <- bind_rows(
  tibble(CATE = predict(res_rich$cf)$predictions, Outcome = "Species richness change"),
  tibble(CATE = predict(res_lrr$cf)$predictions,  Outcome = "log response ratio of cover")
) %>%
  ggplot(aes(CATE, fill = Outcome)) +
  geom_histogram(bins = 40, color = "white", linewidth = 0.1, alpha = .85, position = "identity") +
  facet_wrap(~Outcome, scales = "free_x") +
  labs(x = "Estimated CATE", y = "Number of turf-years",
       title = "Heterogeneity of warming effects (TransPlant network)") +
  theme(legend.position = "none")
ggsave(file.path(plot_dir, "fig1_cate_dist.png"), p1, width = 8, height = 4, dpi = 200)

# 图 2：CATE 随关键调节变量的变化（分位分箱均值 + 95%CI，ntile 处理并列值）
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
    labs(x = xlab, y = "CATE (richness change)", subtitle = paste0("n per bin ≈ ", round(mean(tb$n))))
}
p2a <- mk_bin(res_rich, "orig_temp", "Origin growing-season temperature (C)") +
  labs(title = "Heterogeneity by baseline temperature")
p2b <- mk_bin(res_rich, "base_rich", "Baseline species richness") +
  labs(title = "Heterogeneity by baseline diversity", y = NULL)
library(patchwork)
p2 <- p2a + p2b
ggsave(file.path(plot_dir, "fig2_cate_moderators.png"), p2, width = 9, height = 4, dpi = 200)

# 图 3：best linear projection 系数
blp_tbl <- function(res, lab) {
  b <- best_linear_projection(res$cf, as.matrix(scale(res$d2[, X_names])))
  tibble(var = names(b[, 1]), est = as.numeric(b[, 1]), se = as.numeric(b[, 2]), Outcome = lab)
}
p3 <- bind_rows(blp_tbl(res_rich, "Richness change"), blp_tbl(res_lrr, "Cover LRR")) %>%
  ggplot(aes(est, reorder(var, est))) +
  geom_vline(xintercept = 0, linetype = 2, color = "grey40") +
  geom_errorbarh(aes(xmin = est - 1.96 * se, xmax = est + 1.96 * se), height = .25, color = "#534AB7") +
  geom_point(color = "#534AB7", size = 2) +
  facet_wrap(~Outcome, scales = "free_x") +
  labs(x = "Standardized moderator coefficient (BLP)", y = NULL, title = "Best linear projection of CATE")
ggsave(file.path(plot_dir, "fig3_blp.png"), p3, width = 9, height = 4.5, dpi = 200)

## ---------------------------------------------------------------- 8. 安慰剂检验
placebo_ate <- replicate(100, {
  d2 <- res_rich$d2
  wp <- ave(d2$W_bin, d2$destSiteID, d2$Year, FUN = function(z) sample(z))
  X <- scale(d2[, X_names])
  cf_p <- causal_forest(X, d2$Y_rich, wp,
                        clusters = as.numeric(factor(d2$turfID)),
                        num.trees = 1000, min.node.size = 5)
  average_treatment_effect(cf_p)[1]
})
cat("\n== 安慰剂检验（组内置换处理，100 次）==\n")
cat("placebo ATE mean =", round(mean(placebo_ate), 4),
    " sd =", round(sd(placebo_ate), 4),
    " | 真实 ATE =", round(res_rich$ate[1], 4), "\n")

## ---------------------------------------------------------------- 9. 保存
write.csv(res_rich$d2 %>% mutate(CATE_rich = predict(res_rich$cf)$predictions,
                                 CATE_lrr  = predict(res_lrr$cf)$predictions),
          file.path(plot_dir, "turf_year_cate.csv"), row.names = FALSE)
saveRDS(list(rich = res_rich, lrr = res_lrr), file.path(plot_dir, "cf_results.rds"))
cat("\n== 完成：图表与 CATE 已输出至 project/output ==\n")
