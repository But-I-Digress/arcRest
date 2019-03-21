#' @title Create a Rest Service object. 
#'
#" @description Creates an Rest Service object that contains the connection details and the returned description of the service.
#'
#' @param url The URL of the service.
#' @param usr Character, the user name.
#' @param pwd Character, the password.
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
rest_service <- function (url, usr, pwd) {	

	url <- httr::parse_url(url)
	url$path <- paste(strsplit(url$path, "/", fixed = TRUE)[[1]][1:5], collapse = "/")
	url <- httr::build_url(url)
	
	res <- rest_GET(paste0(url, "/FeatureServer"), usr, pwd)
	
	structure(
		list(
			url = url,
			usr = usr,
			pwd = pwd,
			content = res$content
		),
		class = "rest_service"
	)
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
	str(x$content)
}


