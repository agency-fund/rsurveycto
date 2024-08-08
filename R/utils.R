#' @import checkmate
#' @import cli
#' @import data.table
#' @importFrom glue glue
#' @importFrom httr GET POST content add_headers headers cookies set_cookies
NULL


assert_form_ids = function(auth, form_ids) {
  assert_character(
    form_ids, any.missing = FALSE, min.len = 1L, unique = TRUE, null.ok = TRUE)
  if (!is.null(form_ids)) return(form_ids)
  catalog = scto_catalog(auth)
  ids = catalog[catalog$type == 'form']$id
  ids
}


get_api_response = function(auth, request_url) {
  res = GET(request_url, add_headers('x-csrf-token' = auth$csrf_token))
  status = res$status_code
  content = rawToChar(res$content)
  if (status != 200L) {
    cli_alert_warning('Response content:\n{content}')
    scto_abort('Non-200 response: {status}')
  }
  content
}


#' Suppress or permit messages from rsurveycto
#'
#' By default, rsurveycto prints messages to the console. To suppress them, set
#' the `rsurveycto_quiet` option to `TRUE` or use this function.
#'
#' @param quiet A logical indicating whether to suppress messages, or `NULL`.
#'
#' @return If `quiet` is `NULL`, the current value of the `rsurveycto_quiet`
#'   option. Otherwise, the previous value of the `rsurveycto_quiet` option
#'   invisibly.
#'
#' @examples
#' options(rsurveycto_quiet = TRUE)
#' scto_quiet()
#' scto_quiet(FALSE)
#'
#' @export
scto_quiet = function(quiet = NULL) {
  assert_flag(quiet, null.ok = TRUE)
  quiet_old = getOption('rsurveycto_quiet')
  if (is.null(quiet)) return(quiet_old)
  options(rsurveycto_quiet = quiet)
  invisible(quiet_old)
}


scto_theme = function() {
  common = list(before = '"', after = '"')
  # Okabe-Ito colors
  list(
    span.server = c(color = '#E69F00', common), # orange
    span.id = c(color = '#D55E00', common), # vermillion
    span.dataset = c(color = '#56B4E9', common), # skyblue
    span.form = c(color = '#009E73', common), # bluishgreen
    span.version = c(color = '#F5C710', common), # amber
    span.filename = c(color = '#CC79A7', common)) # reddishpurple
}


scto_bullets = function(text, .envir = parent.frame()) {
  if (isTRUE(scto_quiet()) || identical(Sys.getenv('TESTTHAT'), 'true')) {
    return(invisible())
  }
  cli_div(theme = scto_theme())
  cli_bullets(text, .envir = .envir)
}


scto_abort = function(message, ..., .envir = parent.frame()) {
  call = rlang::caller_env()
  cli_div(theme = scto_theme())
  cli_abort(message = message, ..., .envir = .envir, call = call)
}


is_empty = function(x) {
  i = is.na(x)
  if (is.character(x)) i = i | x == ''
  all(i)
}


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
#' @export
drop_empties = function(d) {
  assert_data_table(d)
  if (nrow(d) == 0) return(d)
  idx = sapply(d, is_empty)
  cols = colnames(d)[which(idx)]
  d[, c(cols) := NULL]
}
