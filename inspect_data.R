e <- new.env()
load("project/data/TransPlantNetwork.RData", envir = e)
cat("Objects:\n")
print(ls(e))
for (nm in ls(e)) {
  obj <- e[[nm]]
  cat("\n===", nm, "=== class:", class(obj), "\n")
  if (is.data.frame(obj)) {
    cat("dim:", dim(obj), "\n")
    cat("columns:", paste(names(obj), collapse = ", "), "\n")
  }
}
