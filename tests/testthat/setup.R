library('data.table')

if (Sys.getenv('SCTO_AUTH') == '') {
  auth_file = 'scto_auth.txt'
} else {
  auth_file = withr::local_tempfile(.local_envir = teardown_env())
  writeLines(Sys.getenv('SCTO_AUTH'), auth_file)}

auth_args = readLines(auth_file)
print(length(auth_args))
cache_dir = withr::local_tempdir(.local_envir = teardown_env())
