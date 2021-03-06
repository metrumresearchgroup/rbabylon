% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/helpers-for-tests.R
\name{skip_if_not_drone_or_metworx}
\alias{skip_if_not_drone_or_metworx}
\title{Skip test if not on Metworx or Drone}
\usage{
skip_if_not_drone_or_metworx(.test_name)
}
\arguments{
\item{.test_name}{Character scalar to identify the test being potentially skipped.
This is printed in the skip message}
}
\description{
Checks for Metworx and Drone environment variables and skips the test if neither are found.
This is primarily used for tests that require \code{bbi} to be installed.
}
\keyword{internal}
