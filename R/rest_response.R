rest_response <- function (url, params = list(), post = FALSE) {
	ua <- httr::user_agent("https://github.com/But-I-Digress/arcRest")
	
	res <- if (post) httr::POST(url, body = params, ua) else httr::GET(url, query = params, ua)
	if (httr::http_error(res)) stop(sprintf("HTTP error requesting data, %s.\n%s", httr::status_code(res), url), call. = FALSE)
	
	if (!httr::http_type(res) %in% c("text/plain", "application/json")) stop("API did not return JSON.", call. = FALSE)
	
	parsed <- jsonlite::fromJSON(httr::content(res, "text"))
	if (!is.null(parsed$error)) stop(sprintf("Data request failed, %s.", parsed$error$details), call. = FALSE)	
	
	structure(
		list(
			rest = NULL,
			path = url,
			params = params,
			content = parsed
		),
		class = "rest_response"
	)
}

#' @title REST Get
#'
#' @description Send an HTTP request to a REST service.
#'
#' @section Note:
#' These functions negotiate the authentication token, caching it in memory and fetching a new one when when necessary.
#' 
#' @param rest A rest_service object returned by \code{\link{rest_service}}.
#' @param path The path of the resource being requested, relative to the URL of the rest service.
#' @param params A list of key value pairs to be sent with the request.
#'
#' @return A list of class \code{rest_response} with the members:
#' 
#' \describe{
#'	\item{rest}{The \code{rest_service} object associated with the request.}
#'	\item{path}{The path of the request.}
#'	\item{params}{The key value pairs passed in the request.}
#'	\item{content}{The parsed content returned by the REST service. Or in the case of \code{rest_download}, the response form \code{file.info} but with the file path appended.}
#' }
#'
#' @export
rest_GET <- function (rest, path, params = list()) {	
	url <- paste(rest$url, path, sep = "/")
	
	params$token <- get_token(rest$usr, rest$pwd)
	params$f <- "pjson"
	
	res <- rest_response(url, params, post = FALSE)
	res$rest <- rest
	res
}

#' @describeIn rest_GET Send an HTTP put request to a REST service.
#'
#' @export
rest_POST <- function (rest, path, params = list()) {
	url <- paste(rest$url, path, sep = "/")
	
	params$token <- get_token(rest$usr, rest$pwd)
	params$f <- "pjson"
	
	res <- rest_response(url, params, post = TRUE)
	res$rest <- rest
	res
}

#' @describeIn rest_GET Send an HTTP put request to a REST service.
#"
#' @param url The full URL of the file being requested, absent of the query part. 
#'
#' @export
rest_download <- function (rest, path = NULL, url = NULL, destfile, params = list()) {
	if (!missing(path)) url <- paste(rest$url, path, sep = "/")
	url <- httr::parse_url(url)
	url$query <- params
	url$query$token <- get_token(rest$usr, rest$pwd)
	url <- httr::build_url(url)

	if (download.file(url, destfile, mode="wb") != 0) stop("Error downloading ", url, call. = FALSE)
	
	info <- file.info(destfile)
	info$path <- destfile
	
	structure(
		list(
			rest = rest,
			path = path,
			params = params,
			content = info[1, , drop = TRUE]
		),
		class = "rest_response"
	)
}

#' @title Print a Rest Response
#'
#' @description S3 method to print a \code{rest_response} object.
#'
#' @param The object.
#' @param ... Ignored.
#'
#" @return x invisibly.
#'
#' @export
print.rest_response <- function (x, ...) {
	cat("<Arc REST ", x$path, ">\n", sep = "")
	str(x$content)
	invisible(x)
}