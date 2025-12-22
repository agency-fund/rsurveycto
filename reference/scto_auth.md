# Authenticate with a SurveyCTO server

SurveyCTO's API supports basic authentication using a username and
password. Make sure the user is assigned a role with permission to
download data ("data manager" or greater) and "Allow server API access"
is enabled.

## Usage

``` r
scto_auth(
  auth_file = NULL,
  servername = NULL,
  username = NULL,
  password = NULL,
  validate = TRUE
)
```

## Arguments

- auth_file:

  String indicating path to a text file containing the server name on
  the first line, username on the second, and password on the third.
  Other arguments are only used if `auth_file` is `NULL`.

- servername:

  String indicating name of the SurveyCTO server.

- username:

  String indicating username for the SurveyCTO account.

- password:

  String indicating password for the SurveyCTO account.

- validate:

  Logical indicating whether to validate credentials by calling
  [`scto_meta()`](https://agency-fund.github.io/rsurveycto/reference/scto_meta.md).
  Should only be set to `FALSE` for debugging.

## Value

`scto_auth` object for an authenticated SurveyCTO session.

## Examples

``` r
if (FALSE) { # \dontrun{
# preferred approach
auth = scto_auth('scto_auth.txt')

# alternate approach
auth = scto_auth('my_server', 'my_user', 'my_pw', auth_file = NULL)
} # }
```
