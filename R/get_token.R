#'@title Get Token
#'
#'@description Get an authentication token, reusing the last one if it hasn't expired.
#'
#' @return Character, the value of the token. 
#'
#' @examples 
#' \dontrun{get_token("user", "password")}
#'
#' @export 
get_token <- function (x, ...) UseMethod("get_token")

#' @describeIn get_token Get a token from a username and password.
#'
#' @param usr Character, the user name.
#' @param pwd Character, the password.
#'
#' @export
get_token.character <- function (usr, pwd) {
	if(is.null(usr)) stop("A username is required.", call. = FALSE)
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

#' @describeIn get_token Get a token from a rest_service object.
#'
#' @param res A rest_service object.
#'
#' @export
get_token.rest_service <- function (res) {
	get_token.character(res$usr, res$pwd)
}
