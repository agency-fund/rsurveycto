#' @import checkmate
#' @importFrom data.table data.table := fread fwrite
#' @importFrom glue glue
#' @importFrom httr GET POST
NULL


get_csrf_token = function(servername, username, password) {
  index_url = glue('https://{servername}.surveycto.com/index.html')
  index_res = GET(index_url)
  csrf_token = httr::headers(index_res)$`x-csrf-token`

  login_url = glue(
    'https://{servername}.surveycto.com/login?spring-security-redirect=%2F')
  login_res = POST(
    login_url,
    body = list(
      username = username,
      password = password,
      csrf_token = csrf_token),
    encode = 'form')

  return(csrf_token)}


drop_empties = function(d) {
  idx = sapply(colnames(d), function(col) {
    all(is.na(d[[col]]) | d[[col]] == '')})
    # all(is.na(d[[col]])) || isTRUE(all(d[[col]] == ''))})
  cols = colnames(d)[idx]
  d[, c(cols) := NULL]}
