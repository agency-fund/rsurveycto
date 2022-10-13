# rsurveycto

[![R-CMD-check](https://github.com/agency-fund/rsurveycto/workflows/R-CMD-check/badge.svg)](https://github.com/agency-fund/rsurveycto/actions)
[![codecov](https://codecov.io/gh/agency-fund/rsurveycto/branch/main/graph/badge.svg)](https://codecov.io/gh/agency-fund/rsurveycto)
[![CRAN Status](https://www.r-pkg.org/badges/version/rsurveycto)](https://cran.r-project.org/package=rsurveycto)

## Overview

[SurveyCTO](https://www.surveycto.com) is a platform for mobile data collection in offline settings. The `rsurveycto` R package uses the [SurveyCTO REST API](https://docs.surveycto.com/05-exporting-and-publishing-data/05-api-access/01.api-access.html) to read datasets and forms from a SurveyCTO server into R as `data.table`s and to download file attachments. The package also has limited support to write datasets to a server.

## Installation

Install from CRAN:

```r
install.packages('rsurveycto')
```

Install the development version:

```r
if (!requireNamespace('remotes', quietly = TRUE))
  install.packages('remotes')
remotes::install_github('agency-fund/rsurveycto')
```

## Usage

A basic example:

```r
library('data.table')
library('rsurveycto')

# user must have permission to download data and
# "allow server API access" must be enabled
auth = scto_auth('PATH_TO_AUTH_FILE')

# read a single dataset or form
cases = scto_read(auth, 'cases')

# get a table of all datasets and forms
catalog = scto_catalog(auth)
```

For more details, see the [reference documentation](https://agency-fund.github.io/rsurveycto/reference/index.html).
