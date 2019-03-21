#' @title REST Get
#'
#' @description Send an HTTP request to a REST service.
#'
#' @section Note:
#' These functions negotiate the authentication token, caching it in memory and fetching a new one when when necessary.
#' 
#' @param url The url of the resource being requested.
#' @param query A list of key value pairs to be sent with URL of the request.
#' @inheritParams rest_service
#'
#' @return A list of class \code{rest_response} with the members:
#' 
#' \describe{
#'	\item{url}{The URL of the request.}
#'	\item{query}{The key value pairs passed in the URL.}
#'	\item{body}{The key value pairs passed in the request headers.}
#'	\item{content}{The parsed content returned by the REST service.}
#' }
#'
#' @export
rest_GET <- function (url, usr, pwd, query = list()) {
	ua <- httr::user_agent("https://github.com/But-I-Digress/arcRest")
	
	query$token <- get_token(usr, pwd)
	query$f <- "pjson"
	
	res <- httr::GET(url, query = query, ua)
	if (httr::http_error(res)) stop(sprintf("HTTP error requesting data, %s.\n%s", httr::status_code(res), url), call. = FALSE)
	
	if (!httr::http_type(res) %in% c("text/plain", "application/json")) stop("API did not return JSON.", call. = FALSE)
	
	parsed <- jsonlite::fromJSON(httr::content(res, "text"))
	if (!is.null(parsed$error)) stop(sprintf("Data request failed, %s.", parsed$error$details), call. = FALSE)	
	
	structure(
		list(
			url = url,
			query = query,
			content = parsed
		),
		class = "rest_response"
	)
}

#' @describeIn rest_GET Send an HTTP put request to a REST service.
#"
#' @param body A list of key value pairs to be sent with HTTP request headers.
#' @inheritParams rest_GET
#'
#' @export
rest_POST <- function (url, usr, pwd, query = list(), body = list()) {
	ua <- httr::user_agent("https://github.com/But-I-Digress/arcRest")
	
	query$token <- get_token(usr, pwd)	
	query$f <- "pjson"
	
	res <- httr::POST(url, query = query, body = body, ua)
	if (httr::http_error(res)) stop(sprintf("HTTP error requesting data, %s.", httr::status_code(res)), call. = FALSE)
	
	if (!httr::http_type(res) %in% c("text/plain", "application/json")) stop("API did not return JSON.", call. = FALSE)
	
	parsed <- jsonlite::fromJSON(httr::content(res, "text"))
	if (!is.null(parsed$error)) stop(sprintf("Data request failed, %s.", parsed$error$details), call. = FALSE)	
	
	structure(
		list(
			url = url,
			query = query,
			body = body,
			content = parsed
		),
		class = "rest_response"
	)
}

#' @export
print.rest_response <- function (x, ...) {
	cat("<Arc REST ", x$url, ">\n", sep = "")
	str(x$content)
	invisible(x)
}