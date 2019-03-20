
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

#'@export
print.rest_service <- function (x, ...) {
	cat("<Arc REST ", x$url, ">\n", sep = "")
	str(x$content)
}


