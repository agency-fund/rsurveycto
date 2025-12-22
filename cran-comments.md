## R CMD check results

### Local

`devtools::check()`:

  0 errors ✓ | 0 warnings ✓ | 0 notes ✓

## Changes from current CRAN release

* Ensured `scto_catalog()` works even if no datasets or no forms.
* Clarified requirements for `scto_write()`.

## Additional information

The tests require login credentials for a SurveyCTO server, which is why they are skipped on CRAN. They pass locally, on R-hub, and on GitHub Actions.
