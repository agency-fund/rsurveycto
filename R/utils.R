#' @import checkmate
#' @importFrom data.table data.table := set fread fwrite
#' @importFrom glue glue
#' @importFrom httr GET POST content add_headers headers cookies set_cookies
NULL


get_session_auth = function(servername, username, password) {
  index_url = glue('https://{servername}.surveycto.com/index.html')
  index_res = GET(index_url)
  csrf_token = headers(index_res)$`x-csrf-token`

  if (is.null(csrf_token)) {
    stop(glue('Unable to access SurveyCTO server `{servername}`.',
              ' Please check that server is running.'))}

  login_url = glue(
    'https://{servername}.surveycto.com/login?spring-security-redirect=%2F')
  login_res = POST(
    login_url,
    body = list(
      username = username,
      password = password,
      csrf_token = csrf_token),
    encode = 'form')

  scto_cookies = cookies(login_res)
  session_id = scto_cookies$value[scto_cookies$name == 'JSESSIONID']

  return(list(csrf_token = csrf_token, session_id = session_id))}


get_resource = function(type, private_key, request_url, auth) {
  res = if (type == 'form' && !is.null(private_key)) {
    POST(request_url, body = list(private_key = httr::upload_file(private_key)))
  } else {
    curl::curl_fetch_memory(request_url, handle = auth$handle)}
  return(res)}


is_empty = function(x) {
  i = is.na(x)
  if (is.character(x)) i = i | x == ''
  return(all(i))}


#' Drop empty columns from a data.table
#'
#' An empty column is one whose only values are `NA` or "".
#'
#' @param d `data.table`.
#'
#' @return `d` modified by reference, invisibly.
#'
#' @examples
#' library('data.table')
#' d = data.table(w = 3:4, x = c('', 'foo'), y = c(NA, NA), z = c(NA, ''))
#' drop_empties(d)
#'
#' @seealso [scto_write()]
#'
#' @export
drop_empties = function(d) {
  assert_data_table(d)
  if (nrow(d) == 0) return(d)
  idx = sapply(d, is_empty)
  cols = colnames(d)[which(idx)]
  d[, c(cols) := NULL][]}
