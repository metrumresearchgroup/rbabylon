% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get-path-from-object.R
\name{get_path_from_log_df}
\alias{get_path_from_log_df}
\title{Private helper function to extract paths from bbi_log_df}
\usage{
get_path_from_log_df(.log_df, .get_func, .check_exists)
}
\arguments{
\item{.log_df}{The \code{bbi_log_df} object}

\item{.get_func}{The getter function to call}

\item{.check_exists}{If \code{TRUE}, the default, will throw an error if the file does not exist}
}
\description{
Private helper function to extract paths from bbi_log_df
}
\keyword{internal}
