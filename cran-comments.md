## R CMD check results

### Local

`devtools::check()`:

  0 errors ✓ | 0 warnings ✓ | 0 notes ✓

## Changes from current CRAN release

* Added function `scto_get_form_responses()` to get form data in long format.

## Additional information

The tests require login credentials for a SurveyCTO server, which is why they are skipped on CRAN. They pass locally, on R-hub, and on GitHub Actions.
