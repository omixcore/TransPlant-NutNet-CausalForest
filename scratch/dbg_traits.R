.libPaths(c("C:/Users/asus/WorkBuddy/2026-10-21-00-57-16/project/rlibs", .libPaths()))
suppressPackageStartupMessages({library(dplyr)})
e <- new.env(); load("C:/Users/asus/WorkBuddy/2026-10-21-00-57-16/project/data/TransPlantNetwork.RData", envir=e)
t <- as.data.frame(e$alltraits)
for (v in c("SLA_cm2_g","TSLA_cm2_g","Plant_Veg_Height_cm","TPlant_Veg_Height_cm","N_percent","TN_percent")) {
  x <- suppressWarnings(as.numeric(t[[v]]))
  cat(sprintf("%-22s n=%4d NA=%4d  q01=%.3g q50=%.3g q99=%.3g max=%.4g  <=0:%d\n",
      v, sum(!is.na(x)), sum(is.na(x)),
      quantile(x, .01, na.rm=TRUE), quantile(x, .5, na.rm=TRUE), quantile(x, .99, na.rm=TRUE),
      max(x, na.rm=TRUE), sum(x <= 0, na.rm=TRUE)))
}
