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

See results for [Windows](https://builder.r-hub.io/status/rsurveycto_0.1.6.tar.gz-42161acda0d64b199d9bb3e76a144f10), [Ubuntu](https://builder.r-hub.io/status/rsurveycto_0.1.6.tar.gz-86bc4851876f4992b0cc9db016d829b2), and [Fedora](https://builder.r-hub.io/status/rsurveycto_0.1.6.tar.gz-56c640260c564f8ca708b9cbc3732458).

### GitHub Actions

  0 errors ✓ | 0 warnings ✓ | 0 notes ✓

See results for Mac, Windows, and Ubuntu [here](https://github.com/agency-fund/rsurveycto/actions/runs/6152623719).

## Changes from current CRAN release

* Added parsing of surveycto groups.
* Fixed linting issues.

## Additional information

The tests require login credentials for a SurveyCTO server, which is why they are skipped on CRAN. They pass locally, on GitHub Actions (using repository secrets), and on R-hub (using environmental variables).
