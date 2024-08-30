# rsurveycto 0.2.1
* Improved handling of integer values in the choices sheet of form definitions.
* Clarified information in `scto_catalog()`.

# rsurveycto 0.2.0
* Added fetching of form metadata, including defintions, for previous and deployed versions using `scto_get_form_metadata()`.
* Added unnesting of form definitions using `scto_unnest_form_definitions()`.
* Added information provided by `scto_catalog()`.
* Fixed `scto_read()` to use and return timestamps in UTC.

# rsurveycto 0.1.6
* Added parsing of groups.

# rsurveycto 0.1.5
* Fixed linting issues.

# rsurveycto 0.1.4
* Enabled `scto_read()` to read from one, multiple, or all forms and datasets.
* Added `simplify` argument to `scto_read()` and `scto_get_form_definitions()`.

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
