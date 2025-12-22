# Fetch file attachments from a SurveyCTO server

This function can download encrypted and unencrypted files attached to
forms.

## Usage

``` r
scto_get_attachments(
  auth,
  urls,
  output_dir,
  private_key = NULL,
  overwrite = TRUE
)
```

## Arguments

- auth:

  [`scto_auth()`](https://agency-fund.github.io/rsurveycto/reference/scto_auth.md)
  object.

- urls:

  Character vector of API URLs for file attachments. Will typically be
  derived from a column of a `data.table` returned by
  [`scto_read()`](https://agency-fund.github.io/rsurveycto/reference/scto_read.md).
  Can contain missing values.

- output_dir:

  String indicating path to directory in which to save files.

- private_key:

  String indicating path to private key file. Only needs to be
  non-`NULL` to decrypt encrypted file attachments.

- overwrite:

  Logical indicating whether to overwrite existing files.

## Value

A character vector of file names of the same length as `urls`, with `NA`
for missing or invalid URLs.

## Examples

``` r
if (FALSE) { # \dontrun{
auth = scto_auth('scto_auth.txt')
form_data = scto_read(auth, 'my_form', 'form')
filenames = scto_get_attachments(auth, form_data[['my_attachment']], '.')
} # }
```
