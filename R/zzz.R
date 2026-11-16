.onAttach <- function(libname, pkgname) {
  version <- as.character(
    utils::packageVersion(pkgname, lib.loc = libname)
  )

  packageStartupMessage(
    pkgname,
    " ",
    version,
    "\nsee https://marcopittarello.github.io/iPastoralist/ for documentation and examples"
  )
}
