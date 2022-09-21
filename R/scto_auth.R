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


#' Get a SurveyCTO authentication session object
#'
#' Authenticates with SurveyCTO and fetches corresponding credentials.
#'
#' @param auth_file String indicating path to file containing authorization
#'   information, which should have servername on the first line, username on
#'   the second, and password on the third. If `auth_file` is not `NULL`, other
#'   arguments are ignored. If `auth_file` is `NULL`, other arguments must be
#'   provided.
#' @param servername String indicating name of the SurveyCTO server.
#' @param username String indicating username for the SurveyCTO account.
#' @param password String indicating password for the SurveyCTO account.
#'
#' @return `scto_auth` object for an authenticated SurveyCTO session.
#'
#' @examples
#' \dontrun{
#' # preferred approach, avoids storing any credentials in code
#' auth = scto_auth('scto_auth.txt')
#'
#' # alternate approach
#' auth = scto_auth('my_server', 'my_user', 'my_pw', auth_file = NULL)
#' }
#'
#' @seealso [scto_read()], [scto_meta()], [scto_get_attachments()],
#'   [scto_write()]
#'
#' @export
scto_auth = function(
    auth_file = NULL, servername = NULL, username = NULL, password = NULL) {

  if (is.null(auth_file)) {
    assert_string(servername)
    assert_string(username)
    assert_string(password)
  } else {
    assert_string(auth_file)
    assert_file_exists(auth_file)
    auth_char = readLines(auth_file, warn = FALSE)
    if (!test_character(auth_char, any.missing = FALSE, len = 3L)) {
      stop(paste(
        'auth_file must have exactly three lines:',
        'servername, username, and password.'))}
    servername = auth_char[1L]
    username = auth_char[2L]
    password = auth_char[3L]}

  handle = curl::new_handle()
  curl::handle_setopt(
    handle = handle,
    httpauth = 1,
    userpwd = glue('{username}:{password}'))

  session_auth = get_session_auth(servername, username, password)

  auth = list(servername = servername, handle = handle,
              csrf_token = session_auth$csrf_token,
              session_id = session_auth$session_id)
  class(auth) = 'scto_auth'

  m = scto_meta(auth) # check for valid username and password
  return(auth)}
