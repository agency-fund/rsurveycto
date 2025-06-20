## R CMD check results

### Local

`devtools::check()`:

  0 errors ✓ | 0 warnings ✓ | 0 notes ✓

### R-hub

  0 errors ✓ | 0 warnings ✓ | 0 notes ✓

See results for Mac, Windows, and Linux [here](https://github.com/agency-fund/rsurveycto/actions/runs/15727606068).

### GitHub Actions

  0 errors ✓ | 0 warnings ✓ | 0 notes ✓

See results for Mac, Windows, and Ubuntu [here](https://github.com/agency-fund/rsurveycto/actions/runs/15727597426).

## Changes from current CRAN release

* Handle form definitions whose "choices" lack a `value` column.

## Additional information

The tests require login credentials for a SurveyCTO server, which is why they are skipped on CRAN. They pass locally, on R-hub, and on GitHub Actions.
