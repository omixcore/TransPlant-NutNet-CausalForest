# Check regional sample filtering and treatment design
.libPaths(c("project/rlibs", .libPaths()))
suppressPackageStartupMessages({library(dplyr)})
e <- new.env(); load("project/data/TransPlantNetwork.RData", envir=e)
dat <- as.data.frame(e$dat); clim <- as.data.frame(e$climdata)

cat("== Regions in source data ==\n"); print(table(dat$Region))
cat("\n== Sites covered by climate data ==\n")
cat("clim destSiteID unique count:", length(unique(clim$destSiteID)), "\n")
cat("dat destSiteID unique count:", length(unique(dat$destSiteID)), "\n")
inter <- intersect(unique(dat$destSiteID), unique(clim$destSiteID))
cat("intersection:", length(inter), "\n")
cat("sites with climate:", paste(sort(inter), collapse=", "), "\n")
cat("sites without climate:", paste(setdiff(unique(dat$destSiteID), inter), collapse=", "), "\n")

cat("\n== Treatment values ==\n"); print(table(dat$Treatment, useNA="ifany"))
cat("\n== Treatment × within-site transplant status ==\n")
d <- dat %>% mutate(same = originSiteID == destSiteID)
print(table(d$Treatment, d$same))

cat("\n== Elevation differences and regions by treatment ==\n")
print(d %>% group_by(Treatment) %>% summarise(
  n = n(), n_turf = n_distinct(turfID),
  same_frac = mean(same), .groups="drop") %>% as.data.frame())

cat("\n== Turfs by region × treatment ==\n")
print(d %>% distinct(Region, turfID, Treatment) %>% count(Region, Treatment) %>%
        tidyr::pivot_wider(names_from=Treatment, values_from=n) %>% as.data.frame())
