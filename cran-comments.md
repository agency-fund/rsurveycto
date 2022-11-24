## R CMD check results

### Local

  0 errors ✓ | 0 warnings ✓ | 0 notes ✓

### R-hub

  0 errors ✓ | 0 warnings ✓ | 2 notes x

❯ checking CRAN incoming feasibility ... NOTE
  Maintainer: 'Jake Hughey <jake@agency.fund>'
  
  New maintainer:
    Jake Hughey <jake@agency.fund>
  Old maintainer(s):
    Jake Hughey <jakejhughey@gmail.com>

❯ checking for detritus in the temp directory ... NOTE
  Found the following files/directories:
    'lastMiKTeXException'

## Changes from current CRAN release

* Changed maintainer email address.
* Enabled `scto_read()` to read from one, multiple, or all forms and datasets.
* Added `simplify` argument to `scto_read()` and `scto_get_form_definitions()`.
* Fixed `scto_read()` to not return result invisibly.
* Added column `version` to output of `scto_catalog()`.
* Added `scto_get_form_definitions()` to do just that.

## Additional information

The tests require login credentials for a SurveyCTO server, which is why they are skipped on CRAN. They pass locally, on GitHub Actions (using repository secrets), and on R-hub (using environmental variables).
