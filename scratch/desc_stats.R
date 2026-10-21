# Descriptive statistics for the manuscript
.libPaths(c("project/rlibs", .libPaths()))
suppressPackageStartupMessages({library(dplyr); library(tidyr)})
res <- readRDS("project/output/cf_results_v2.rds")
d2  <- res$rich$d2

cat("== Analysis sample description ==\n")
cat("n turf-years:", nrow(d2), "| turfs:", length(unique(d2$turfID)),
    "| dest sites:", length(unique(d2$destSiteID)),
    "| origin sites:", length(unique(d2$originSiteID)),
    "| regions:", length(unique(d2$Region)), "\n")
cat("regions:", paste(sort(unique(d2$Region)), collapse=", "), "\n")
cat("years:", min(d2$Year), "-", max(d2$Year), "\n")
cat("warm turfs:", sum(d2$W_bin==1), "| control:", sum(d2$W_bin==0), "\n")
cat(sprintf("warming (dest-orig) degC: median %.2f, range %.2f to %.2f\n",
            median(d2$W_cont), min(d2$W_cont), max(d2$W_cont)))
cat(sprintf("origin temp: %.1f - %.1f C (mean %.1f)\n",
            min(d2$orig_temp), max(d2$orig_temp), mean(d2$orig_temp)))
cat(sprintf("orig prec: %.0f - %.0f mm\n", min(d2$orig_prec), max(d2$orig_prec)))
cat(sprintf("elev shift: %.0f - %.0f m (median %.0f)\n",
            min(d2$d_elev), max(d2$d_elev), median(d2$d_elev)))
cat(sprintf("baseline richness: %.0f - %.0f (mean %.1f)\n",
            min(d2$base_rich), max(d2$base_rich), mean(d2$base_rich)))
cat(sprintf("cwm_SLA %.0f-%.0f | cwm_Hgt %.0f-%.0f | prop_woody %.2f-%.2f\n",
            min(d2$cwm_SLA,na.rm=T), max(d2$cwm_SLA,na.rm=T),
            min(d2$cwm_Hgt,na.rm=T), max(d2$cwm_Hgt,na.rm=T),
            min(d2$prop_woody,na.rm=T), max(d2$prop_woody,na.rm=T)))
cat(sprintf("CATE rich: mean %.2f, sd %.2f, range %.2f to %.2f\n",
            mean(d2$CATE_rich), sd(d2$CATE_rich), min(d2$CATE_rich), max(d2$CATE_rich)))
cat(sprintf("frac CATE<0: %.1f%%\n", 100*mean(d2$CATE_rich<0)))
cat(sprintf("Y_rich mean %.2f | Y_lrr mean %.3f\n", mean(d2$Y_rich), mean(d2$Y_lrr)))

# Observations per site
cat("\n== Site sample size ==\n")
print(d2 %>% count(destSiteID, Region) %>% arrange(desc(n)) %>% as.data.frame())

# Species pool
e <- new.env(); load("project/data/TransPlantNetwork.RData", envir=e)
cat("\nSource species count:", length(unique(e$dat$SpeciesName)), "| record count:", nrow(e$dat), "\n")

# NutNet
nn <- read.csv("project/output/nutnet_plot_cate.csv")
cat("\n== NutNet ==\n")
cat("rows:", nrow(nn), "| sites:", length(unique(nn$site)), "\n")
print(names(nn))
