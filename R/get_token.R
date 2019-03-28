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
		query <- list(
			username = usr,
			password = pwd,
			referer = "https://www.arcgis.com",
			f = "json"
		)		
		res <- rest_response(url, params = query, post = TRUE) 
		
		parsed <- res$content	
		parsed$expires <- parsed$expires / 1000
		class(parsed$expires) <- "POSIXct"
		assign(usr, parsed, envir = arcRest)
	} 
	
	parsed$token
	
}
