e <- new.env()
load("project/data/TransPlantNetwork.RData", envir = e)
dat <- as.data.frame(e$dat); at <- as.data.frame(e$alltraits); mt <- as.data.frame(e$mergedtaxa)

cat("### dat SpeciesName by Region (samples) ###\n")
for (rg in c("NO_Ulvhaugen", "CH_Calanda", "CN_Gongga", "SE_Abisko", "US_Colorado")) {
  cat("--", rg, "--\n")
  print(head(unique(dat$SpeciesName[dat$Region == rg]), 6))
}
cat("\n### alltraits SpeciesName by Region (samples) ###\n")
for (rg in c("NO_Ulvhaugen", "CH_Calanda", "CN_Gongga", "SE_Abisko", "US_Colorado")) {
  cat("--", rg, "--\n")
  print(head(unique(at$SpeciesName[at$Region == rg]), 6))
}
cat("\n### join rate check ###\n")
cat("dat names in alltraits (raw):", mean(dat$SpeciesName %in% at$SpeciesName), "\n")
# After mergedtaxa mapping
map <- mt %>% distinct(Region, destSiteID, SpeciesName, taxa)
d2 <- dat %>% left_join(map, by = c("Region", "SpeciesName"))
cat("dat names in alltraits (via mergedtaxa taxa):", mean(d2$taxa %in% at$SpeciesName), "\n")
cat("dat SpeciesName directly in mergedtaxa:", mean(paste(dat$Region, dat$SpeciesName) %in% paste(mt$Region, mt$SpeciesName)), "\n")
