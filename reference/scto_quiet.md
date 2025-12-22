# Suppress or permit messages from rsurveycto

By default, rsurveycto prints messages to the console. To suppress them,
set the `rsurveycto_quiet` option to `TRUE` or use this function.

## Usage

``` r
scto_quiet(quiet = NULL)
```

## Arguments

- quiet:

  A logical indicating whether to suppress messages, or `NULL`.

## Value

If `quiet` is `NULL`, the current value of the `rsurveycto_quiet`
option. Otherwise, the previous value of the `rsurveycto_quiet` option
invisibly.

## Examples

``` r
options(rsurveycto_quiet = TRUE)
scto_quiet()
#> [1] TRUE
scto_quiet(FALSE)
```
