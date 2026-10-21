e <- new.env()
load("project/data/TransPlantNetwork.RData", envir = e)

cat("### dat structure ###\n")
d <- e$dat
cat("class:", class(d), " dim:", dim(d), "\n")
if (is.data.frame(d)) print(names(d))

cat("\n### climdata ###\n")
c1 <- e$climdata
cat("class:", class(c1), "\n")
if (is.data.frame(c1)) { cat("dim:", dim(c1), "\n"); print(names(c1)) }

cat("\n### alltraits ###\n")
t1 <- e$alltraits
cat("class:", class(t1), "\n")
if (is.data.frame(t1)) { cat("dim:", dim(t1), "\n"); print(names(t1)) }

cat("\n### one site list (NO_Ulvhaugen) ###\n")
s1 <- e$NO_Ulvhaugen
cat("names:", paste(names(s1), collapse = ", "), "\n")
for (nm in names(s1)) {
  cat("-", nm, ":", class(s1[[nm]]), if (is.data.frame(s1[[nm]])) paste0(" dim:", dim(s1[[nm]])) else "", "\n")
}

cat("\n### sitetraits ###\n")
st <- e$sitetraits
cat("class:", class(st), "\n")
if (is.data.frame(st)) { cat("dim:", dim(st), "\n"); print(names(st)) }

cat("\n### trytraits ###\n")
tt <- e$trytraits
if (is.data.frame(tt)) { cat("dim:", dim(tt), "\n"); print(names(tt)) }
