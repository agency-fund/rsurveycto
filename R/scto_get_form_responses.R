rename_cols = \(x) gsub('[^a-zA-Z0-9]', '_', tolower(x))

#' Read form data from a SurveyCTO server and convert to long format
#'
#' This function converts data from [scto_read()] to long format, then joins
#' the data with the "survey" and "choices" components of the form metadata.
#'
#' @param auth [scto_auth()] object.
#' @param form_id String indicating id of the form.
#' @param id_cols Character vector of data columns to keep in the result, will
#'   be passed as `id.vars` to [data.table::melt()].
#' @param exclude_cols Character vector of data columns to exclude from the
#'   result.
#' @param ... Additional arguments passed to [scto_read()].
#'
#' @return A `data.table` with one row per response, i.e., one row per form
#'   submission per field. If necessary to avoid ambiguity, columns from the
#'   "survey" part of the form definition are prefixed with `field_`, while
#'   columns from the "choices" part of the form definition are prefixed with
#'   `choice_`. Original column names from data returned by [scto_read()] are
#'   in the `submission_field_name` column, while corresponding values are in
#'   the `field_value` column. Data can be converted back to wide format as
#'   desired using [data.table::dcast()] or [tidyr::pivot_wider()].
#'
#' @examples
#' \dontrun{
#' auth = scto_auth('scto_auth.txt')
#' responses = scto_get_form_responses(auth, 'my_form')
#' }
#'
#' @export
scto_get_form_responses = \(
  auth, form_id,
  id_cols = c(
    'KEY', 'formdef_version', 'CompletionDate', 'SubmissionDate',
    'starttime', 'endtime', 'review_status', 'review_quality'),
  exclude_cols = 'instanceID', ...) {

  . = ..field_cols = ..response_cols = `_form_version` = choice_value =
    field_name = field_type = field_value = list_name = submission_field_name =
    type = value = NULL

  meta = scto_get_form_metadata(auth, form_id)
  subs = scto_read(auth, form_id, ...)
  defs = scto_unnest_form_definitions(meta)

  assert_character(id_cols)
  assert_character(exclude_cols)

  fields = copy(defs$survey[[1L]])
  fields = fields[type %notin% c('begin group', 'end group')]
  setnames(fields, rename_cols)
  setnames(fields, c('name', '_row_num'), c('field_name', 'field_row_num'))
  setnames(
    fields, which(startsWith(colnames(fields), 'label')),
    \(x) paste0('field_', x))
  fields[, field_type := sub(' .+$', '', type)]
  fields[
    grepl('^select_(one|multiple) ', type), list_name := gsub('^.+ ', '', type)]

  choices = copy(defs$choices[[1L]])
  choices = choices[, .SD[1L], by = .(`_form_version`, list_name, value)]
  setnames(choices, rename_cols)
  setnames(choices, c('value', '_row_num'), c('choice_value', 'choice_row_num'))
  setnames(
    choices, which(startsWith(colnames(choices), 'label')),
    \(x) paste0('choice_', x))

  fields_choices = merge(
    fields[field_type %in% c('select_one', 'select_multiple')],
    choices, by = c('_form_version', 'list_name'), sort = FALSE)

  fields_choices[, submission_field_name := fifelse(
    field_type == 'select_one', field_name,
    paste0(field_name, '_', choice_value))]

  measure_cols = setdiff(colnames(subs), c(id_cols, exclude_cols))
  responses = melt(
    subs, id.vars = id_cols, measure.vars = measure_cols,
    variable.name = 'submission_field_name', value.name = 'field_value')
  setnames(responses, rename_cols)

  by_x = c('formdef_version', 'submission_field_name')
  by_y = c('_form_version', 'submission_field_name')

  responses_fields = merge(
    responses, copy(fields)[, submission_field_name := field_name],
    by.x = by_x, by.y = by_y, all.x = TRUE, sort = FALSE)

  # field type would not be select_multiple
  x1 = merge(
    responses_fields[!is.na(field_name)],
    copy(choices)[, field_value := choice_value],
    by.x = c('formdef_version', 'list_name', 'field_value'),
    by.y = c('_form_version', 'list_name', 'field_value'),
    all.x = TRUE, sort = FALSE)

  # field type would be select_multiple, field value not NA
  withr::local_options(list(warn = -1)) # hide data.table warning
  response_cols = colnames(responses)
  x2 = merge(
    responses_fields[is.na(field_name) & !is.na(field_value), ..response_cols],
    fields_choices,
    by.x = by_x, by.y = by_y, all.x = TRUE, sort = FALSE)

  # field type would be select_multiple, field value NA
  field_cols = c(colnames(fields), 'submission_field_name')
  x3 = merge(
    responses_fields[is.na(field_name) & is.na(field_value), ..response_cols],
    unique(fields_choices[, ..field_cols]),
    by.x = by_x, by.y = by_y, all.x = TRUE, sort = FALSE)

  responses_fields_choices = rbind(x1, x2, x3, fill = TRUE) |>
    setcolorder(
      c('key', 'submission_field_name', 'field_value', 'formdef_version'))
  responses_fields_choices
}
