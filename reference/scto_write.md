# Write data to a SurveyCTO server

**\[experimental\]**

This function updates an existing dataset using an unofficial API
endpoint. For this to work, the SurveyCTO user must have permissions
"Can edit server datasets" and "Can modify or delete server dataset
data".

## Usage

``` r
scto_write(
  auth,
  data,
  dataset_id,
  dataset_title = dataset_id,
  append = FALSE,
  fill = FALSE
)
```

## Arguments

- auth:

  [`scto_auth()`](https://agency-fund.github.io/rsurveycto/reference/scto_auth.md)
  object.

- data:

  `data.frame` to upload.

- dataset_id:

  String indicating id of existing dataset.

- dataset_title:

  String indicating title of dataset. Will replace the existing title,
  regardless of `append`.

- append:

  Logical indicating whether to append or replace the dataset.

- fill:

  Logical indicating whether to implicitly fill missing columns with
  `NA`, i.e., whether to allow a mismatch between columns of the
  existing dataset and columns of `data`. Only used if `append` is
  `TRUE`.

## Value

A list with elements:

- `data_old`: A `data.table` of the previous version of the dataset.

- `response`: An object of class
  [`httr::response()`](https://httr.r-lib.org/reference/response.html)
  from the API call.

## Examples

``` r
if (FALSE) { # \dontrun{
auth = scto_auth('scto_auth.txt')
r = scto_write(auth, data, 'my_dataset', 'My Dataset')
} # }
```
