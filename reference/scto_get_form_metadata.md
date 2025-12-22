# Fetch form metadata from a SurveyCTO server

This function fetches metadata, including form definitions, for deployed
and previous versions of one or more forms.

## Usage

``` r
scto_get_form_metadata(
  auth,
  form_ids = NULL,
  deployed_only = FALSE,
  get_defs = TRUE,
  def_dir = NULL
)
```

## Arguments

- auth:

  [`scto_auth()`](https://agency-fund.github.io/rsurveycto/reference/scto_auth.md)
  object.

- form_ids:

  Character vector indicating the form ids. `NULL` indicates all forms.

- deployed_only:

  Logical indicating whether to fetch metadata for all versions of each
  form, or only for the deployed version.

- get_defs:

  Logical indicating whether to fetch form definitions.

- def_dir:

  String indicating directory in which to save the form definitions as
  Excel files.

## Value

A `data.table` with one row per form (and per version, if
`deployed_only` is `FALSE`). Definitions are returned as nested
`data.table`s, which can be unnested using
[`scto_unnest_form_definitions()`](https://agency-fund.github.io/rsurveycto/reference/scto_unnest_form_definitions.md).

## Examples

``` r
if (FALSE) { # \dontrun{
auth = scto_auth('scto_auth.txt')
form_metadata = scto_get_form_metadata(auth, 'my_form')
form_defs = scto_unnest_form_definitions(form_metadata)
} # }
```
