#' Skip test if over Github API rate limit
#'
#' This is based on a function of the same name from the `remotes` package.
#' Note, this uses no token, so it is checking the public rate limit.
#' This is appropriate because this package has no interface for passing in a token, so it will always be hitting the public API.
#' @importFrom utils download.file
#' @importFrom jsonlite fromJSON
#' @param by if less than this number of requests are left before hitting the rate limit, skip the test
#' @keywords internal
skip_if_over_rate_limit <- function(by = 5) {

  tmp <- tempfile(fileext = '.json')

  on.exit(unlink(tmp),add = TRUE)

  download.file("https://api.github.com/rate_limit", destfile = tmp, quiet = TRUE)

  res <- jsonlite::fromJSON(tmp, simplifyDataFrame = FALSE)

  res <- res$rate$remaining

  if (is.null(res) || res <= by) testthat::skip("Over the GitHub rate limit")
}