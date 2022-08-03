#' @import checkmate
#' @importFrom data.table data.table := fread fwrite
#' @importFrom glue glue
#' @importFrom httr GET POST
NULL


get_auth = function(auth_file) {
  auth = readLines(auth_file)
  assert_character(auth, min.chars = 1L, any.missing = FALSE, len = 2L)
  return(auth)}


drop_empties = function(d) {
  idx = sapply(colnames(d), function(col) {
    all(is.na(d[[col]])) || isTRUE(all(d[[col]] == ''))})
  cols = colnames(d)[idx]
  d[, c(cols) := NULL]}


get_csrf_token = function(servername, auth_file) {
  index_url = glue('https://{servername}.surveycto.com/index.html')
  index_res = GET(index_url)
  csrf_token = httr::headers(index_res)$`x-csrf-token`
  auth = get_auth(auth_file)

  login_url = glue(
    'https://{servername}.surveycto.com/login?spring-security-redirect=%2F')
  login_res = POST(
    login_url,
    body = list(
      username = auth[1L],
      password = auth[2L],
      csrf_token = csrf_token),
    encode = 'form')

  return(csrf_token)}
