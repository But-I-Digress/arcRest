
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

#' @export
print.rest_response <- function (x, ...) {
	cat("<Arc REST ", x$url, ">\n", sep = "")
	str(x$content)
	invisible(x)
}