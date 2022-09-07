## R CMD check results

### Local

  0 errors ✓ | 0 warnings ✓ | 0 notes ✓

### R-hub

  0 errors ✓ | 0 warnings ✓ | 2 notes x

❯ checking CRAN incoming feasibility ... [13s] NOTE
  Maintainer: 'Jake Hughey <jakejhughey@gmail.com>'
  
  New submission

❯ checking for detritus in the temp directory ... NOTE
  Found the following files/directories:
    'lastMiKTeXException'
    
## Additional information

Per CRAN feedback:

- Software names in the title and description are in single quotes.
- The description includes a link to the API's documentation (the only link that does not require a login).
- The description field has more detail about the package's functionality.
- The functions do not write by default.

The tests require login credentials for a SurveyCTO server, which is why they are skipped on CRAN. They pass locally, on GitHub Actions (using repository secrets), and on R-hub (using environmental variables).
