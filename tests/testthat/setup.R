library('data.table')

if (Sys.getenv('SCTO_AUTH') == '') {
  auth_file = 'scto_auth.txt'
} else {
  auth_file = withr::local_tempfile()
  writeLines(Sys.getenv('SCTO_AUTH'), auth_file)}

auth_args = readLines(auth_file)
cache_dir = withr::local_tempdir()
