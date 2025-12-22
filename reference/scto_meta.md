# Read metadata from a SurveyCTO server

These functions read metadata from a SurveyCTO server.

## Usage

``` r
scto_meta(auth)

scto_catalog(auth)
```

## Arguments

- auth:

  [`scto_auth()`](https://agency-fund.github.io/rsurveycto/reference/scto_auth.md)
  object.

## Value

`scto_meta()` returns a nested list of metadata related to forms,
datasets, groups, and publishing information. `scto_catalog()` returns a
`data.table` with one row per form or dataset.

## Examples

``` r
if (FALSE) { # \dontrun{
auth = scto_auth('scto_auth.txt')
metadata = scto_meta(auth)
catalog = scto_catalog(auth)
} # }
```
