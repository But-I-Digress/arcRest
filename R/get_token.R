#'@title Get Token
#'
#'@description Get an authentication token, reusing the last one if it hasn't expired.
#'
#' @param usr Character, the user name.
#' @param pwd Character, the password.
#'
#' @return Character, the value of the token. 
#'
#' @examples 
#' \dontrun{get_token("user", "password")}
#'
#'@export 
get_token <- function (usr, pwd) {

	parsed <- get0(usr, envir = arcRest)
	if (is.null(parsed) || parsed$expires < Sys.time()) {	
		url <- "https://www.arcgis.com/sharing/rest/generateToken"
		body <- list(
			username = usr,
			password = pwd,
			referer = "https://www.arcgis.com",
			f = "json"
		)
		
		res <- httr::POST(url, body = body, get0("ua", envir = arcRest))
		
		if (httr::http_error(res)) stop(sprintf("HTTP error requesting a token, %s.", httr::status_code(res)), call. = FALSE)
		
		if (!httr::http_type(res) %in% c("text/plain", "application/json")) stop("API did not return a token in JSON.", call. = FALSE)
		
		parsed <- jsonlite::fromJSON(httr::content(res))
		if (!is.null(parsed$error)) stop(sprintf("Token request failed, %s.", parsed$error$message), call. = FALSE)	
		
		parsed$expires <- parsed$expires / 1000
		class(parsed$expires) <- "POSIXct"
		assign(usr, parsed, envir = arcRest)
	} 
	
	parsed$token
	
}
