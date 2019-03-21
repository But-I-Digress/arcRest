

decode <- function (v, d) {
	for (i in 1:nrow(d)) v[v == d[i, "code"]] <- d[i, "name"]
	v
}

#' @describeIn get_layer Get information about a layer.
#'
#'@export
get_layer_info <- function (rest, layer_no) rest_GET(paste0(rest$url, "/FeatureServer/", layer_no), rest$usr, rest$pwd)

#' @title Get Layer
#'
#' @description Get a Layer from a REST Service
#'
#' @param rest A \code{\link{rest_service}} object.
#' @param layer_no Scalar, the number of the layer, 0 to n - 1.
#' 
#' @return \code{get_layer_info} returns a \code{rest_response} object. \code{get_layer}, the attribute table as a data frame.
#'
#'@export
get_layer <- function (rest, layer_no) {

	layer_no <- as.character(get_layer[[1]])
	
	info <- get_layer_info(rest, layer_no)
	info <- info$content
	fields <- info$fields
	
	url <- paste0(rest$url, "/FeatureServer/createReplica")
	
	body <- list(
		layers = layer_no,
		transportType = "esriTransportTypeEmbedded",
		returnAttachments = "true",
		syncModel = "none",
		dataFormat = "json"
	)
	
	res <- rest_POST(url, rest$usr,rest$pwd, body = body)
	
	print(res)
	
	layer <- res$content$layers[1, 2][[1]]
	.data <- layer$attributes
	
	# resolve coded values	
	
	for (i in which(fields$domain$type == "codedValue")) .data[, i] <- decode(.data[, i, drop = TRUE], fields$domain$codedValues[i][[1]])

	# convert dates
	
	for (i in which(fields$type == "esriFieldTypeDate")) {
		.data[, i] <- .data[, i, drop = TRUE] / 1000
		class(.data[, i]) <- "POSIXct"
	}
	
	# resolve aliases
	
	colnames(.data) <- fields$alias
	
	.data
}