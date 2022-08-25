library('data.table')

cache_dir = withr::local_tempdir(.local_envir = teardown_env())

if (Sys.getenv('SCTO_AUTH') == '') {
  auth_file = 'scto_auth.txt'
} else {
  auth_file = withr::local_tempfile(.local_envir = teardown_env())
  writeLines(Sys.getenv('SCTO_AUTH'), auth_file)}

auth_args = readLines(auth_file)

if (Sys.getenv('SCTO_PRIVATE_KEY') == '') {
  private_key = 'rsurveycto-private-key.pem'
} else {
  private_key = withr::local_tempfile(.local_envir = teardown_env())
  writeLines(Sys.getenv('SCTO_PRIVATE_KEY'), private_key)}

print(private_key)
