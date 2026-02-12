# Changelog

## rsurveycto 0.2.5

- Added function
  [`scto_get_form_responses()`](https://agency-fund.github.io/rsurveycto/reference/scto_get_form_responses.md)
  to get form data in long format.

## rsurveycto 0.2.4

CRAN release: 2025-12-22

- Ensured
  [`scto_catalog()`](https://agency-fund.github.io/rsurveycto/reference/scto_meta.md)
  works even if no datasets or no forms.
- Clarified requirements for
  [`scto_write()`](https://agency-fund.github.io/rsurveycto/reference/scto_write.md).

## rsurveycto 0.2.3

- Added ability to download form definitions to a directory of choice.

## rsurveycto 0.2.2

CRAN release: 2025-06-18

- Handle form definitions whose “choices” lack a `value` column.

## rsurveycto 0.2.1

CRAN release: 2024-09-03

- Improved handling of integer values in the choices sheet of form
  definitions.
- Clarified information in
  [`scto_catalog()`](https://agency-fund.github.io/rsurveycto/reference/scto_meta.md).
- Changed `is_deployed` in
  [`scto_get_form_metadata()`](https://agency-fund.github.io/rsurveycto/reference/scto_get_form_metadata.md)
  to logical.

## rsurveycto 0.2.0

CRAN release: 2024-08-17

- Added fetching of form metadata, including defintions, for previous
  and deployed versions using
  [`scto_get_form_metadata()`](https://agency-fund.github.io/rsurveycto/reference/scto_get_form_metadata.md).
- Added unnesting of form definitions using
  [`scto_unnest_form_definitions()`](https://agency-fund.github.io/rsurveycto/reference/scto_unnest_form_definitions.md).
- Added information provided by
  [`scto_catalog()`](https://agency-fund.github.io/rsurveycto/reference/scto_meta.md).
- Fixed
  [`scto_read()`](https://agency-fund.github.io/rsurveycto/reference/scto_read.md)
  to use and return timestamps in UTC.

## rsurveycto 0.1.6

CRAN release: 2023-09-13

- Added parsing of groups.

## rsurveycto 0.1.5

- Fixed linting issues.

## rsurveycto 0.1.4

CRAN release: 2022-11-24

- Enabled
  [`scto_read()`](https://agency-fund.github.io/rsurveycto/reference/scto_read.md)
  to read from one, multiple, or all forms and datasets.
- Added `simplify` argument to
  [`scto_read()`](https://agency-fund.github.io/rsurveycto/reference/scto_read.md)
  and
  [`scto_get_form_definitions()`](https://agency-fund.github.io/rsurveycto/reference/scto_get_form_definitions.md).

## rsurveycto 0.1.3

- Fixed
  [`scto_read()`](https://agency-fund.github.io/rsurveycto/reference/scto_read.md)
  to not return result invisibly.
- Added column `version` to output of
  [`scto_catalog()`](https://agency-fund.github.io/rsurveycto/reference/scto_meta.md).
- Added
  [`scto_get_form_definitions()`](https://agency-fund.github.io/rsurveycto/reference/scto_get_form_definitions.md)
  to do just that.

## rsurveycto 0.1.2

CRAN release: 2022-10-24

- Fixed
  [`drop_empties()`](https://agency-fund.github.io/rsurveycto/reference/drop_empties.md)
  to return result invisibly.

## rsurveycto 0.1.1

- Added argument `validate` to
  [`scto_auth()`](https://agency-fund.github.io/rsurveycto/reference/scto_auth.md)
  for debugging.
- Added column `title` to output of
  [`scto_catalog()`](https://agency-fund.github.io/rsurveycto/reference/scto_meta.md).
- Updated documentation.

## rsurveycto 0.1.0

CRAN release: 2022-09-27

- [`scto_read()`](https://agency-fund.github.io/rsurveycto/reference/scto_read.md)
  no longer requires user to provide argument `type`.
- Added `scto_read_all()` and
  [`scto_catalog()`](https://agency-fund.github.io/rsurveycto/reference/scto_meta.md)
  functions to read all datasets and forms.

## rsurveycto 0.0.9

- Added handling of parallel requests.

## rsurveycto 0.0.8

- Added check for valid username and password.

## rsurveycto 0.0.7

- Added
  [`scto_meta()`](https://agency-fund.github.io/rsurveycto/reference/scto_meta.md)
  function to fetch SurveyCTO metadata.

## rsurveycto 0.0.6

- Added more options to
  [`scto_write()`](https://agency-fund.github.io/rsurveycto/reference/scto_write.md).

## rsurveycto 0.0.5

CRAN release: 2022-09-08

- Removed default output directory per CRAN requirements.
- Removed caching for simplicity in meeting CRAN requirements.

## rsurveycto 0.0.4

- Ready for CRAN submission.
