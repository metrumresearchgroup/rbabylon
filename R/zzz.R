.onLoad <- function(libname, pkgname) {

  # if the option set before load, keep it, else look for an env var
  # if it isn't one of the false-y settings, then will set to true
  if (is.null(getOption("rbabylon.DEV_no_min_version")) &&
      !Sys.getenv("RBABYLON_DEV_NO_MIN_VERSION", unset = "FALSE") %in% c("0", "FALSE", "false")) {
    options("rbabylon.DEV_no_min_version" = TRUE)
  }
  # set bbi executable path
  if (is.null(getOption("bbr.bbi_exe_path"))) {
    options("bbr.bbi_exe_path" = BBI_DEFAULT_PATH)
  }

  # set bbi minimum version
  if (is.null(getOption("bbr.bbi_min_version"))) {
    options("bbr.bbi_min_version" = package_version("3.0.2"))
  }

  # by default turn on strict mode to check for malformed objects and classes, etc.
  if (is.null(getOption("bbr.strict"))) {
    options("bbr.strict" = TRUE)
  }
}

.onAttach <- function(libname, pkgname) {
  if (isTRUE(getOption("rbabylon.DEV_no_min_version"))) {
    packageStartupMessage("setting `rbabylon.DEV_no_min_version` to TRUE so no validation of bbi version will occur")
  }
}
