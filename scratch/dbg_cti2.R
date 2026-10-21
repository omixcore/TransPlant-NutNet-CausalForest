.libPaths(c("C:/Users/asus/WorkBuddy/2026-10-21-00-57-16/project/rlibs", .libPaths()))
suppressPackageStartupMessages({library(dplyr); library(grf)})
r <- readRDS("C:/Users/asus/WorkBuddy/2026-10-21-00-57-16/project/output/cti_results.rds")
b <- best_linear_projection(r$cti$cf, r$cti$X)
cat("class:", class(b), "\n"); cat("dim:", dim(b), "\n")
if (is.matrix(b)) { print(colnames(b)); print(rownames(b)) } else { print(str(b)) }
print(b)
cat("\n--- 结局分布 ---\n")
a <- r$ana
for (v in c("d_cti_ok","d_stp","d_cwm_SLA","d_cwm_Hgt","d_cwm_Npc","d_cwm_woody")) {
  x <- a[[v]]
  cat(sprintf("%-12s n=%4d NA=%4d NaN=%3d Inf=%2d range=[%.4g, %.4g] sd=%.4g\n",
      v, sum(!is.na(x)), sum(is.na(x)), sum(is.nan(x)), sum(is.infinite(x)),
      suppressWarnings(min(x, na.rm=TRUE)), suppressWarnings(max(x, na.rm=TRUE)), sd(x, na.rm=TRUE)))
}
cat("\nd_cwm_SLA 分位:\n"); print(quantile(a$d_cwm_SLA, c(0,.01,.5,.99,1), na.rm=TRUE))
cat("d_cwm_Npc 分位:\n"); print(quantile(a$d_cwm_Npc, c(0,.01,.5,.99,1), na.rm=TRUE))
