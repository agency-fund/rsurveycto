## R CMD check results

### Local

`devtools::check()`:

  0 errors ✓ | 0 warnings ✓ | 0 notes ✓

### R-hub

  0 errors ✓ | 0 warnings ✓ | 0 notes ✓

See results for Mac, Windows, and Linux [here](https://github.com/agency-fund/rsurveycto/actions/runs/10399161149).

### GitHub Actions

  0 errors ✓ | 0 warnings ✓ | 0 notes ✓

See results for Mac, Windows, and Ubuntu [here](https://github.com/agency-fund/rsurveycto/actions/runs/10399151723).

## Changes from current CRAN release

* Added fetching of form metadata, including defintions, for previous and deployed versions using `scto_get_form_metadata()`.
* Added unnesting of form definitions using `scto_unnest_form_definitions()`.
* Added information provided by `scto_catalog()`.
* Fixed `scto_read()` to use and return timestamps in UTC.

## Additional information

The tests require login credentials for a SurveyCTO server, which is why they are skipped on CRAN. They pass locally, on R-hub, and on GitHub Actions.
