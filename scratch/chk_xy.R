.libPaths(c("project/rlibs", .libPaths()))
suppressPackageStartupMessages(library(dplyr))
e <- new.env(); load("project/data/TransPlantNetwork.RData", envir = e)
cl <- as.data.frame(e$climdata)
sus <- c("IT_MatschMazia1","IT_MatschMazia2","SE_Abisko")
sids <- cl %>% filter(gradient %in% sus) %>% distinct(destSiteID) %>% pull(destSiteID)
cat("sites:", paste(sids, collapse=", "), "\n")
print(cl %>% filter(destSiteID %in% sids) %>%
        group_by(destSiteID) %>%
        summarise(lat = paste(round(unique(lat),2), collapse="/"),
                  lon = paste(round(unique(lon),2), collapse="/"),
                  Country = paste(unique(Country), collapse="/")) %>% as.data.frame())
