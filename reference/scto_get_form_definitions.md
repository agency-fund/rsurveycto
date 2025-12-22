# Fetch deployed form definitions from a SurveyCTO server

**\[superseded\]**

This function fetches definitions for currently deployed forms. It has
been superseded in favor of
[`scto_get_form_metadata()`](https://agency-fund.github.io/rsurveycto/reference/scto_get_form_metadata.md),
which fetches metadata, including defintions, for deployed and previous
versions of forms.

## Usage

``` r
scto_get_form_definitions(auth, form_ids = NULL, simplify = TRUE)
```

## Arguments

- auth:

  [`scto_auth()`](https://agency-fund.github.io/rsurveycto/reference/scto_auth.md)
  object.

- form_ids:

  Character vector indicating the form ids. `NULL` indicates all forms.

- simplify:

  Logical indicating whether to return the definition for one form as a
  simple list instead of a named, nested list.

## Value

If `simplify` is `TRUE` and getting one form definition, a list.
Otherwise a named list of lists containing the definition for each form.

## Examples

``` r
if (FALSE) { # \dontrun{
auth = scto_auth('scto_auth.txt')
form_def = scto_get_form_definitions(auth, 'my_form')
form_defs = scto_get_form_definitions(auth)
} # }
```
