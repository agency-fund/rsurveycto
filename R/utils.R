#' @import checkmate
#' @importFrom data.table data.table := set fread fwrite
#' @importFrom glue glue
#' @importFrom httr GET POST content add_headers headers cookies set_cookies
NULL


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
