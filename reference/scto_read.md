# Read data from a SurveyCTO server

This function can read datasets and forms.

## Usage

``` r
scto_read(
  auth,
  ids = NULL,
  start_date = as.POSIXct("1900-01-01", tz = "UTC"),
  review_status = "approved",
  private_key = NULL,
  drop_empty_cols = FALSE,
  convert_datetime = c("CompletionDate", "SubmissionDate", "starttime", "endtime"),
  datetime_format = "%b %e, %Y %I:%M:%S %p",
  simplify = TRUE
)
```

## Arguments

- auth:

  [`scto_auth()`](https://agency-fund.github.io/rsurveycto/reference/scto_auth.md)
  object.

- ids:

  Character vector indicating ids of the datasets and/or forms. `NULL`
  indicates all datasets and forms.

- start_date:

  Date-time or something coercible to a date-time indicating the
  earliest date-time (UTC timezone) for which to fetch data. Only used
  for forms. Use with caution, because fields that are deleted prior to
  `start_date` will not show up, even if submissions prior to
  `start_date` have data for those fields.

- review_status:

  String or character vector indicating which submissions to fetch.
  Possible values are "approved", "pending", "rejected", or any
  combination of the three. Only used for forms.

- private_key:

  String indicating path to private key file. Only needs to be
  non-`NULL` to read encrypted form data.

- drop_empty_cols:

  Logical indicating whether to drop columns that contain only `NA` or
  only an empty string.

- convert_datetime:

  Character vector of column names in the data for which to convert
  strings to datetimes (POSIXct). Use `NULL` to not convert any columns
  to datetimes.

- datetime_format:

  String indicating format of datetimes from SurveyCTO. See
  [`strptime()`](https://rdrr.io/r/base/strptime.html).

- simplify:

  Logical indicating whether to return only a `data.table` instead of a
  list of `data.table`s if reading one form or dataset.

## Value

If `simplify` is `TRUE` and reading one form or dataset, a `data.table`.
Otherwise a named list of `data.table`s, one for each form and dataset,
along with a `data.table` named ".catalog" from
[`scto_catalog()`](https://agency-fund.github.io/rsurveycto/reference/scto_meta.md).

## Examples

``` r
if (FALSE) { # \dontrun{
auth = scto_auth('scto_auth.txt')
form_data = scto_read(auth, 'my_form')
all_data = scto_read(auth)
} # }
```
