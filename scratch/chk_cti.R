.libPaths(c("C:/Users/asus/WorkBuddy/2026-10-21-00-57-16/project/rlibs", .libPaths()))
suppressPackageStartupMessages({library(dplyr); library(tidyr)})
e <- new.env(); load("C:/Users/asus/WorkBuddy/2026-10-21-00-57-16/project/data/TransPlantNetwork.RData", envir=e)
dat <- as.data.frame(e$dat); clim <- as.data.frame(e$climdata); traits <- as.data.frame(e$alltraits); mt <- as.data.frame(e$mergedtaxa)

cat("=== dat columns ===\n"); print(names(dat)); cat("\n")
cat("=== clim columns ===\n"); print(names(clim)); cat("\n")
cat("=== traits columns ===\n"); print(names(traits)[1:min(20,ncol(traits))]); cat("\n")

cat("n row dat:", nrow(dat), " species:", n_distinct(dat$SpeciesName), " regions:", n_distinct(dat$Region), "\n")
cat("origin sites:", n_distinct(dat$originSiteID), " dest sites:", n_distinct(dat$destSiteID), "\n")
cat("Origin coverage in clim$destSiteID:", n_distinct(intersect(dat$originSiteID, clim$destSiteID)), "/", n_distinct(dat$originSiteID), "\n")
cat("Origin in clim$originSiteID?", "originSiteID" %in% names(clim), "\n")

# Number of regions per species
sp_reg <- dat %>% distinct(SpeciesName, Region) %>% count(SpeciesName, name="n_region") %>% arrange(desc(n_region))
cat("\nDistribution of regions per species:\n"); print(table(sp_reg$n_region))
cat("Share of species in one region:", round(100*mean(sp_reg$n_region==1),1), "%\n")

# Number of sites per species
sp_site <- dat %>% distinct(SpeciesName, originSiteID) %>% count(SpeciesName, name="n_site")
cat("\nDistribution of origin sites per species:\n"); print(table(sp_site$n_site))
cat("median:", median(sp_site$n_site), "\n")
