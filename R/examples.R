#' Example function and concise title
#'
#' Concise, non-redundant description of function.
#'
#' @param a First numeric value to add.
#' @param b Second numeric value to add.
#'
#' @return A `data.table` with columns for `a`, `b`, and the result `r`.
#'
#' @examples
#' d = exampleFunction(3, 6)
#'
#' @export
exampleFunction = function(a, b) {
  d = data.table(a = a, b = b, r = addUtil(a, b))
  return(d)}
