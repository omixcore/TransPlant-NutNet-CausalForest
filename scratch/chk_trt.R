d <- read.csv("project/data/e247_plant_soil.csv", sep = "\t", check.names = FALSE)
cat("Treatment levels:\n"); print(table(d$trt, useNA = "ifany"))
cat("Nonmissing ANPP by treatment:/n"); print(table(d$trt, !is.na(d$anpp)))
cat("Rows:", nrow(d), " sites:", length(unique(d$site)), "\n")
