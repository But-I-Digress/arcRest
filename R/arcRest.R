#' @title Create a Rest Service object. 
#'
#" @description Creates an Rest Service object that contains the connection details and the returned description of the service.
#'
#' @param url The URL of the service.
#' @param usr Character, optional, the user name.
#' @param pwd Character, optional, the password.
#' @param params List, optional, named paramaters to pass to the service.
#'
#' @return A list of class \code{rest_service} with the members:
#' 
#' \describe{
#'	\item{url}{The URL of the service. This may be a truncated version of what was used to construct the object.}
#'	\item{usr}{The user name for the REST service.}
#'	\item{pwd}{The password for the REST service.}
#'	\item{content}{The parsed content returned by the REST service.}
#' }
#'
#'@export
rest_service <- function (url, usr = NULL, pwd = NULL, params = list()) {	

	url <- httr::parse_url(url)
	url$path <- strsplit(url$path, "/", fixed = TRUE)[[1]]
	url$path <- url$path[1:(which(url$path == "arcgis") + 3)]
	name <- url$path[length(url$path)]
	url$path <- paste(url$path, collapse = "/")
	url <- httr::build_url(url)
	
	out <- list(url = url, usr = usr, pwd = pwd)
	
	if (!is.null(usr)) params$token <- get_token(usr, pwd)
	params$f <- "pjson"
	
	res <- rest_response(paste0(url, "/.."), params)
	
	services <- res$content$services
	services <- services[services$name == name, ]
	
	for (i in 1:nrow(services)) {
		l <- services[i, , drop=TRUE]
		res <- rest_response(l$url, params)
		out[[l$type]] <- res$content
	}
	
	structure(out, class = "rest_service")
}

#' @title Print a Rest Service
#'
#' @description S3 method to print a \code{rest_service} object.
#'
#' @param The object.
#' @param ... Ignored.
#'
#" @return x invisibly.
#'
#'@export
print.rest_service <- function (x, ...) {
	cat("<Arc REST ", x$url, ">\n", sep = "")
	str(x)
}


