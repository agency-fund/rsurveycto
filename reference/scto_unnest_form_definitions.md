# Unnest previously fetched form definitions

This function unnests form definitions, e.g., from multiple versions of
a form, which can make it easier to map values to labels in a later
step.

## Usage

``` r
scto_unnest_form_definitions(form_metadata, by_form_id = TRUE)
```

## Arguments

- form_metadata:

  `data.table` returned by
  [`scto_get_form_metadata()`](https://agency-fund.github.io/rsurveycto/reference/scto_get_form_metadata.md).

- by_form_id:

  Logical indicating whether to unnest definitions of multiple versions
  of a given form (default), or to unnest definitions of all forms
  together.

## Value

If `by_form_id` is `TRUE`, a `data.table` of `data.table`s for the
survey, choices, and settings components of the form definitions.
Otherwise a list of `data.table`s.

## Examples

``` r
if (FALSE) { # \dontrun{
auth = scto_auth('scto_auth.txt')
form_metadata = scto_get_form_metadata(auth, 'my_form')
form_defs = scto_unnest_form_definitions(form_metadata)
} # }
```
