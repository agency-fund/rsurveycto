library('data.table')

if (Sys.getenv('SCTO_AUTH') == '') {
  message('Environment variable SCTO_AUTH not found.')
  auth_file = 'scto_auth.txt'
} else {
  message('Environment variable SCTO_AUTH found.')
  auth_file = withr::local_tempfile(.local_envir = teardown_env())
  writeLines(Sys.getenv('SCTO_AUTH'), auth_file)}

auth_args = readLines(auth_file)
cache_dir = withr::local_tempdir(.local_envir = teardown_env())
