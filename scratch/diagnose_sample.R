# 检查分析样本的区域筛选来源与处理设计
.libPaths(c("project/rlibs", .libPaths()))
suppressPackageStartupMessages({library(dplyr)})
e <- new.env(); load("project/data/TransPlantNetwork.RData", envir=e)
dat <- as.data.frame(e$dat); clim <- as.data.frame(e$climdata)

cat("== 原始数据区域 ==\n"); print(table(dat$Region))
cat("\n== 气候数据覆盖的站点数 ==\n")
cat("clim destSiteID 唯一数:", length(unique(clim$destSiteID)), "\n")
cat("dat destSiteID 唯一数:", length(unique(dat$destSiteID)), "\n")
inter <- intersect(unique(dat$destSiteID), unique(clim$destSiteID))
cat("交集:", length(inter), "\n")
cat("有气候的站点:", paste(sort(inter), collapse=", "), "\n")
cat("无气候的站点:", paste(setdiff(unique(dat$destSiteID), inter), collapse=", "), "\n")

cat("\n== Treatment 取值 ==\n"); print(table(dat$Treatment, useNA="ifany"))
cat("\n== 处理 x 是否同站移栽 ==\n")
d <- dat %>% mutate(same = originSiteID == destSiteID)
print(table(d$Treatment, d$same))

cat("\n== 各处理下的海拔差与区域 ==\n")
print(d %>% group_by(Treatment) %>% summarise(
  n = n(), n_turf = n_distinct(turfID),
  same_frac = mean(same), .groups="drop") %>% as.data.frame())

cat("\n== 区域 x 处理 的 turf 数 ==\n")
print(d %>% distinct(Region, turfID, Treatment) %>% count(Region, Treatment) %>% 
        tidyr::pivot_wider(names_from=Treatment, values_from=n) %>% as.data.frame())
