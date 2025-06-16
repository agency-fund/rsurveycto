## R CMD check results

### Local

`devtools::check()`:

  0 errors ✓ | 0 warnings ✓ | 0 notes ✓

### R-hub

  0 errors ✓ | 0 warnings ✓ | 0 notes ✓

See results for Mac, Windows, and Linux [here](https://github.com/agency-fund/rsurveycto/actions/runs/10691311650).

### GitHub Actions

  0 errors ✓ | 0 warnings ✓ | 0 notes ✓

See results for Mac, Windows, and Ubuntu [here](https://github.com/agency-fund/rsurveycto/actions/runs/10645170317).

## Changes from current CRAN release

* Improved handling of integer values in the choices sheet of form definitions.
* Clarified information in `scto_catalog()`.
* Changed `is_deployed` in `scto_get_form_metadata()` to logical.

## Additional information

The tests require login credentials for a SurveyCTO server, which is why they are skipped on CRAN. They pass locally, on R-hub, and on GitHub Actions.
