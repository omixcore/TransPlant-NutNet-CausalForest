e <- new.env()
load("project/data/TransPlantNetwork.RData", envir = e)

cat("### mergedtaxa ###\n")
mt <- e$mergedtaxa
cat("class:", class(mt), "\n")
if (is.data.frame(mt)) { cat("dim:", dim(mt), "\n"); print(names(mt)); print(head(mt, 5)) }

cat("\n### cleanedspecies ###\n")
cs <- e$cleanedspecies
cat("class:", class(cs), "\n")
if (is.data.frame(cs)) { cat("dim:", dim(cs), "\n"); print(names(cs)); print(head(cs, 5)) }
if (is.vector(cs) || is.character(cs)) { cat("len:", length(cs), "\n"); print(head(cs, 10)) }

cat("\n### spcodes ###\n")
sc <- e$spcodes
cat("class:", class(sc), "\n")
if (is.data.frame(sc)) { cat("dim:", dim(sc), "\n"); print(names(sc)); print(head(sc, 5)) }
if (is.vector(sc)) { cat("len:", length(sc), "\n"); print(head(sc, 10)) }

cat("\n### sitetaxa ###\n")
st <- e$sitetaxa
cat("class:", class(st), "\n")
if (is.data.frame(st)) { cat("dim:", dim(st), "\n"); print(names(st)); print(head(st, 3)) }

cat("\n### alltraits name columns sample ###\n")
at <- e$alltraits
print(head(at[, c("Region", "destSiteID", "SpeciesName", "original_name", "submitted_name", "try_name")], 8))
cat("\nSpeciesName unique in dat:", length(unique(e$dat$SpeciesName)), "\n")
cat("SpeciesName unique in alltraits:", length(unique(at$SpeciesName)), "\n")
