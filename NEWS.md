# rsurveycto 0.1.3
* Fixed `scto_read()` to not return result invisibly.
* Added column `version` to output of `scto_catalog()`.
* Added `scto_get_form_definitions()` to do just that.

# rsurveycto 0.1.2
* Fixed `drop_empties()` to return result invisibly.

# rsurveycto 0.1.1
* Added argument `validate` to `scto_auth()` for debugging.
* Added column `title` to output of `scto_catalog()`.
* Updated documentation.

# rsurveycto 0.1.0
* `scto_read()` no longer requires user to provide argument `type`.
* Added `scto_read_all()` and `scto_catalog()` functions to read all datasets and forms.

# rsurveycto 0.0.9
* Added handling of parallel requests.

# rsurveycto 0.0.8
* Added check for valid username and password.

# rsurveycto 0.0.7
* Added `scto_meta()` function to fetch SurveyCTO metadata.

# rsurveycto 0.0.6
* Added more options to `scto_write()`.

# rsurveycto 0.0.5
* Removed default output directory per CRAN requirements.
* Removed caching for simplicity in meeting CRAN requirements.

# rsurveycto 0.0.4
* Ready for CRAN submission.
