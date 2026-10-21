e <- new.env()
load("project/data/TransPlantNetwork.RData", envir = e)

c1 <- e$climdata
d <- e$dat

cat("### gradient values ###\n")
print(table(c1$gradient))
cat("\n### yeartp values ###\n")
print(table(c1$yeartp, useNA = "ifany"))
cat("\n### destSiteID in climdata ###\n")
print(sort(unique(as.character(c1$destSiteID))))
cat("\n### originSiteID in dat ###\n")
print(sort(unique(as.character(d$originSiteID))))
cat("\n### Region values ###\n")
print(table(d$Region))

cat("\n### months ###\n")
print(table(c1$month))

cat("\n### sample climdata rows ###\n")
print(head(c1[, c("destSiteID", "var", "month", "year", "value")], 10))

cat("\n### per-turf first years (dat) ###\n")
fy <- aggregate(Year ~ turfID, data = d, FUN = min)
print(summary(fy$Year))
cat("n turf-year combos:", nrow(unique(d[, c("turfID", "Year")])), "\n")
