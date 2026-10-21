d <- read.csv("project/data/e247_plant_soil.csv", sep = "\t", check.names = FALSE)
cat("trt 水平:\n"); print(table(d$trt, useNA = "ifany"))
cat("anpp 非缺失 x trt:/n"); print(table(d$trt, !is.na(d$anpp)))
cat("行数:", nrow(d), " 站点:", length(unique(d$site)), "\n")
