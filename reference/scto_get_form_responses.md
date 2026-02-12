# Read form data from a SurveyCTO server and convert to long format

This function converts data from
[`scto_read()`](https://agency-fund.github.io/rsurveycto/reference/scto_read.md)
to long format, then joins the data with the "survey" and "choices"
components of the form metadata.

## Usage

``` r
scto_get_form_responses(
  auth,
  form_id,
  id_cols = c("KEY", "formdef_version", "CompletionDate", "SubmissionDate", "starttime",
    "endtime", "review_status", "review_quality"),
  exclude_cols = "instanceID",
  ...
)
```

## Arguments

- auth:

  [`scto_auth()`](https://agency-fund.github.io/rsurveycto/reference/scto_auth.md)
  object.

- form_id:

  String indicating id of the form.

- id_cols:

  Character vector of data columns to keep in the result, will be passed
  as `id.vars` to
  [`data.table::melt()`](https://rdrr.io/pkg/data.table/man/melt.data.table.html).

- exclude_cols:

  Character vector of data columns to exclude from the result.

- ...:

  Additional arguments passed to
  [`scto_read()`](https://agency-fund.github.io/rsurveycto/reference/scto_read.md).

## Value

A `data.table` with one row per response, i.e., one row per form
submission per field. If necessary to avoid ambiguity, columns from the
"survey" part of the form definition are prefixed with `field_`, while
columns from the "choices" part of the form definition are prefixed with
`choice_`. Original column names from data returned by
[`scto_read()`](https://agency-fund.github.io/rsurveycto/reference/scto_read.md)
are in the `submission_field_name` column, while corresponding values
are in the `field_value` column. Data can be converted back to wide
format as desired using
[`data.table::dcast()`](https://rdrr.io/pkg/data.table/man/dcast.data.table.html)
or `tidyr::pivot_wider()`.

## Examples

``` r
if (FALSE) { # \dontrun{
auth = scto_auth('scto_auth.txt')
responses = scto_get_form_responses(auth, 'my_form')
} # }
```
