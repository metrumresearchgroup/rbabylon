
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rbabylon

<!-- badges: start -->

<!-- badges: end -->

`rbabylon` is an R interface for running `babylon`. `babylon` is (will
be) a complete solution for managing projects involving modeling and
simulation with a number of software solutions used in pharmaceutical
sciences. You can get more information on `babylon`
[here](https://github.com/metrumresearchgroup/babylon).

`rbabylon` is intended to help scientists manage the entire modeling
workflow from within R. Users can submit models, consume outputs and
diagnostics, and iterate on models. Furthermore, workflow tools–like
simple tagging of models and model inheritence trees–make
reproducibility and external review much more streamlined.

## Installation

You can install the latests released version of `rbabylon` via [MPN
snapshots](https://mpn.metworx.com/docs/snapshots) from any date *after*
2020-03-07.

You can also install development versions of `rbabylon` by downloading
the source files for the latest version from
`https://s3.amazonaws.com/mpn.metworx.dev/releases/rbabylon/<version>`. For example, to install the version 0.1.0.9002 you would use the url: `https://s3.amazonaws.com/mpn.metworx.dev/releases/rbabylon/0.1.0.9002`. You can also get the
latest development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("metrumresearchgroup/rbabylon", ref = "develop")
```

## Documentation

You can find documentation and a “Getting Started” vignette that shows
users how to set up `rbabylon` and demonstrates the basic modeling
workflow [here](http://metrumresearchgroup.github.io/rbabylon/).

More vignettes, demonstrating different modeling scenarios, will be
added soon.