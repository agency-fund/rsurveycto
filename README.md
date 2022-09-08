# rsurveycto

[![R-CMD-check](https://github.com/youth-impact/rsurveycto/workflows/R-CMD-check/badge.svg)](https://github.com/youth-impact/rsurveycto/actions)
[![codecov](https://codecov.io/gh/youth-impact/rsurveycto/branch/main/graph/badge.svg)](https://codecov.io/gh/youth-impact/rsurveycto)
[![CRAN Status](https://www.r-pkg.org/badges/version/rsurveycto)](https://cran.r-project.org/package=rsurveycto)

[SurveyCTO](https://www.surveycto.com) is a platform for mobile data collection in offline settings. The `rsurveycto` R package uses the [SurveyCTO REST API](https://docs.surveycto.com/05-exporting-and-publishing-data/05-api-access/01.api-access.html) to read datasets and forms from a SurveyCTO server into R as `data.table`s and to download file attachments. The package also has limited support to write datasets to a server.

## Installation

### CRAN

```r
install.packages('rsurveycto')
```

### Development version

```r
if (!requireNamespace('remotes', quietly = TRUE))
  install.packages('remotes')
remotes::install_github('youth-impact/rsurveycto')
```

## Usage

See the [reference documentation](https://youth-impact.github.io/rsurveycto/reference/index.html).
