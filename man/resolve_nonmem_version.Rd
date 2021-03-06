% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/config-log.R
\name{resolve_nonmem_version}
\alias{resolve_nonmem_version}
\title{Determine the NONMEM version used}
\usage{
resolve_nonmem_version(x)
}
\arguments{
\item{x}{A list representing \code{bbi_config.json}.}
}
\value{
A string giving the version of NONMEM used.
}
\description{
The version of NONMEM used to run a model is represented in \code{bbi_config.json}
as either the field \code{nm_version}, or the version in the \code{nonmem} object with
\code{default: true}.
}
\keyword{internal}
