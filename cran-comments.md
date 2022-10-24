## R CMD check results

### Local

  0 errors ✓ | 0 warnings ✓ | 0 notes ✓

### R-hub

  0 errors ✓ | 0 warnings ✓ | 1 note x

❯ checking for detritus in the temp directory ... NOTE
  Found the following files/directories:
    'lastMiKTeXException'

## Changes from current CRAN release

* Fixed `drop_empties()` to return result invisibly.
* Added argument `validate` to `scto_auth()` for debugging.
* Added column `title` to output of `scto_catalog()`.
* Updated documentation.

## Additional information

The tests require login credentials for a SurveyCTO server, which is why they are skipped on CRAN. They pass locally, on GitHub Actions (using repository secrets), and on R-hub (using environmental variables).
