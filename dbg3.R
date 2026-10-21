.libPaths(c("project/rlibs", .libPaths()))
suppressPackageStartupMessages({library(dplyr); library(grf)})
res <- readRDS("project/output/cf_results_v3.rds")
cate <- predict(res$rich$cf)$predictions
d2 <- res$rich$d2
w <- d2 %>% filter(W_bin == 1)
cat("warm n:", nrow(w), "median dT:", median(w$W_cont), "IQR:", paste(round(quantile(w$W_cont, c(.25,.75)),2), collapse="-"), "\n")
cat("warm dT>0 frac:", round(mean(w$W_cont > 0),3), "\n")
cat("regions:", paste(sort(unique(d2$Region)), collapse=", "), "\n")
cat("countries:", length(unique(sub("_.*", "", unique(d2$Region)))), "\n")
cat("CATE frac<0:", round(mean(cate < 0),3), "\n")
