.libPaths(c("C:/Users/asus/WorkBuddy/2026-10-21-00-57-16/project/rlibs", .libPaths()))
suppressPackageStartupMessages({library(dplyr); library(grf)})
cat("grf version:", as.character(packageVersion("grf")), "\n")
cat("get_scores exported:", "get_scores" %in% getNamespaceExports("grf"), "\n")
r <- readRDS("C:/Users/asus/WorkBuddy/2026-10-21-00-57-16/project/output/cf_results_v3.rds")
d_rich <- r$rich$d2
cat("rich d2 rows:", nrow(d_rich), "\n")
# gainloss panel rows
gl <- read.csv("C:/Users/asus/WorkBuddy/2026-10-21-00-57-16/project/output/gainloss_panel.csv")
cat("gainloss panel rows:", nrow(gl), "\n")
key_r <- paste(d_rich$turf_key, d_rich$Year)
key_g <- paste(gl$turf_key, gl$Year)
cat("aligned:", all(key_r %in% key_g) && all(key_g %in% key_r), " | n both:", sum(key_r %in% key_g), "\n")
# scores sanity
s <- get_scores(r$rich$cf)
cat("scores dim:", paste(dim(s), collapse="x"), " | mean(scores):", round(mean(s),4), " | ATE:", round(r$rich$ate[1],4), "\n")
