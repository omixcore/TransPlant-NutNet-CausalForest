.libPaths(c("C:/Users/asus/WorkBuddy/2026-10-21-00-57-16/project/rlibs", .libPaths()))
suppressPackageStartupMessages({library(dplyr); library(tidyr)})
e <- new.env(); load("C:/Users/asus/WorkBuddy/2026-10-21-00-57-16/project/data/TransPlantNetwork.RData", envir=e)
dat <- as.data.frame(e$dat); clim <- as.data.frame(e$climdata); traits <- as.data.frame(e$alltraits); mt <- as.data.frame(e$mergedtaxa)

cat("=== dat 字段 ===\n"); print(names(dat)); cat("\n")
cat("=== clim 字段 ===\n"); print(names(clim)); cat("\n")
cat("=== traits 字段 ===\n"); print(names(traits)[1:min(20,ncol(traits))]); cat("\n")

cat("n row dat:", nrow(dat), " species:", n_distinct(dat$SpeciesName), " regions:", n_distinct(dat$Region), "\n")
cat("origin sites:", n_distinct(dat$originSiteID), " dest sites:", n_distinct(dat$destSiteID), "\n")
cat("origin 在 clim$destSiteID 中的覆盖:", n_distinct(intersect(dat$originSiteID, clim$destSiteID)), "/", n_distinct(dat$originSiteID), "\n")
cat("origin 在 clim$originSiteID 中?", "originSiteID" %in% names(clim), "\n")

# 每个物种出现的 region 数
sp_reg <- dat %>% distinct(SpeciesName, Region) %>% count(SpeciesName, name="n_region") %>% arrange(desc(n_region))
cat("\n物种跨 region 数分布:\n"); print(table(sp_reg$n_region))
cat("单 region 物种占比:", round(100*mean(sp_reg$n_region==1),1), "%\n")

# 每物种出现的 site 数
sp_site <- dat %>% distinct(SpeciesName, originSiteID) %>% count(SpeciesName, name="n_site")
cat("\n物种跨 origin site 数分布:\n"); print(table(sp_site$n_site))
cat("中位:", median(sp_site$n_site), "\n")
