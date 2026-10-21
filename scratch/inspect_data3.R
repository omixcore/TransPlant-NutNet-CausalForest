e <- new.env()
load("project/data/TransPlantNetwork.RData", envir = e)

d <- e$dat
cat("### Treatment levels ###\n")
print(table(d$Treatment, useNA = "ifany"))
cat("\n### Years ###\n")
print(summary(d$Year))
cat("\n### Sites ###\n")
print(table(d$destSiteID))
cat("\n### turfs ###\n")
cat("unique turfID:", length(unique(d$turfID)), "\n")

c1 <- e$climdata
cat("\n### climate vars ###\n")
print(table(c1$var))
cat("\n### climate years ###\n")
print(summary(c1$year))
