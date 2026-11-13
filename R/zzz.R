.onAttach <- function(libname, pkgname) {
  version <- as.character(
    utils::packageVersion(pkgname, lib.loc = libname)
  )

  packageStartupMessage(
    pkgname,
    " ",
    version,
    "\nManagement and analysis of vegetation data.",
    "\nUse browseVignettes(\"iPastoralist\") to explore the tutorials."
  )
}
