.libPaths(c("C:/Users/asus/WorkBuddy/2026-10-21-00-57-16/project/rlibs", .libPaths()))
suppressPackageStartupMessages({library(dplyr)})
r <- readRDS("C:/Users/asus/WorkBuddy/2026-10-21-00-57-16/project/output/cti_results.rds")
a <- r$ana
for (v in c("d_cti_ok","d_stp","d_cwm_SLA","d_cwm_Hgt","d_cwm_Npc","d_cwm_woody")) {
  x <- a[[v]]
  cat(sprintf("%-12s n=%4d  NA=%4d NaN=%3d  range=[%.4g, %.4g]  sd=%.4g\n",
      v, sum(!is.na(x)), sum(is.na(x)), sum(is.nan(x)),
      suppressWarnings(min(x, na.rm=TRUE)), suppressWarnings(max(x, na.rm=TRUE)),
      sd(x, na.rm=TRUE)))
}
cat("\n--- d_cwm_SLA 分位 ---\n"); print(quantile(a$d_cwm_SLA, c(0,.01,.25,.5,.75,.99,1), na.rm=TRUE))
cat("\nd_cwm_SLA 中 Inf 数:", sum(is.infinite(a$d_cwm_SLA)), "\n")
cat("d_cwm_Npc 分位:\n"); print(quantile(a$d_cwm_Npc, c(0,.01,.5,.99,1), na.rm=TRUE))
cat("\nd_cti 描述: mean", round(mean(a$d_cti,na.rm=TRUE),4), " sd", round(sd(a$d_cti,na.rm=TRUE),4), "\n")
cat("d_cti_ok 描述: mean", round(mean(a$d_cti_ok,na.rm=TRUE),4), "\n")
