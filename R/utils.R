#' @import checkmate
#' @importFrom data.table data.table := set fread fwrite
#' @importFrom glue glue
#' @importFrom httr GET POST
NULL


get_csrf_token = function(servername, username, password) {
  index_url = glue('https://{servername}.surveycto.com/index.html')
  index_res = GET(index_url)
  csrf_token = httr::headers(index_res)$`x-csrf-token`

  if (is.null(csrf_token)) {
    stop(glue('Unable to log in to SurveyCTO server `{servername}`.',
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

  return(csrf_token)}


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
