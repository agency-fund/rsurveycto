## R CMD check results

### Local

`devtools::check()`:

  0 errors ✓ | 0 warnings ✓ | 0 notes ✓

### R-hub

  0 errors ✓ | 0 warnings ✓ | 2 notes x

❯ checking for non-standard things in the check directory ... NOTE
  Found the following files/directories:
    ''NULL''

❯ checking for detritus in the temp directory ... NOTE
  Found the following files/directories:
    'lastMiKTeXException'

See results for [Windows](), [Ubuntu](), and [Fedora]().

### GitHub Actions

  0 errors ✓ | 0 warnings ✓ | 0 notes ✓

See results for Mac, Windows, and Ubuntu [here]().

## Changes from current CRAN release

* Added fetching of form metadata, including defintions, for previous and deployed versions using `scto_get_form_metadata()`.
* Added unnesting of form definitions using `scto_unnest_form_definitions()`.
* Added information provided by `scto_catalog()`.

## Additional information

The tests require login credentials for a SurveyCTO server, which is why they are skipped on CRAN. They pass locally, on GitHub Actions (using repository secrets), and on R-hub (using environmental variables).
