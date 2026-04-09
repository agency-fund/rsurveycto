## R CMD check results

### Local

`devtools::check()`:

  0 errors ✓ | 0 warnings ✓ | 0 notes ✓

## Changes from current CRAN release

* Fixed bug in `scto_get_form_responses()` when the same choices are used by multiple fields.

## Additional information

The tests require login credentials for a SurveyCTO server, which is why they are skipped on CRAN. They pass locally, on R-hub, and on GitHub Actions.
