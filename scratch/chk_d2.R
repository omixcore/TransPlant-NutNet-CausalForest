.libPaths(c("project/rlibs", .libPaths()))
suppressPackageStartupMessages({library(dplyr); library(grf)})
res <- readRDS("project/output/cf_results_v3.rds"); d2 <- res$rich$d2
cat("d2 cols:", paste(names(d2), collapse=", "), "\n")
cat("n:", nrow(d2), " regions:", length(unique(d2$Region)), "\n")
cat("has turf_key:", "turf_key" %in% names(d2), " base_year:", "base_year" %in% names(d2), "\n")
e <- new.env(); load("project/data/TransPlantNetwork.RData", envir=e)
dat <- as.data.frame(e$dat)
cat("dat cols:", paste(names(dat), collapse=", "), "\n")
