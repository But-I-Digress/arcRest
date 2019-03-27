

all_layers <- function (rest) {
	n <- -1
	if (!is.null(rest$content$layers)) n <- n + nrow(rest$content$layers)
	if (!is.null(rest$content$tables)) n <- n + nrow(rest$content$tables)
	0:n
}

decode <- function (v, d) {
	for (i in 1:nrow(d)) v[v == d[i, "code"]] <- d[i, "name"]
	v
}

normalize_layer <- function (res, layer) {
	info <- get_layer_info(res$rest, layer)
	fields <- info$content$fields
	layer <- layer + 1
		
	# resolve coded values		
	if (class(fields$domain) == "data.frame") for (i in which(fields$domain$type == "codedValue")) res$content$layers$features[[layer]]$attributes[, i] <- decode(res$content$layers$features[[layer]]$attributes[, i, drop = TRUE], fields$domain$codedValues[i][[1]])
	
	# convert dates	
	for (i in which(fields$type == "esriFieldTypeDate")) {
		res$content$layers$features[[layer]]$attributes[, i] <- res$content$layers$features[[layer]]$attributes[, i, drop = TRUE] / 1000
		class(res$content$layers$features[[layer]]$attributes[, i]) <- "POSIXct"
	}
	
	# resolve aliases	
	colnames(res$content$layers$features[[layer]]$attributes) <- fields$alias
	
	res	
}

#' @describeIn get_layers Get information about a layer.
#'
#'@export
get_layer_info <- function (rest, layer_no) rest_GET(rest, paste0("FeatureServer/", layer_no))

#' @title Get Layers
#'
#' @description Get one or more layers from a REST Service
#'
#' @param rest A \code{\link{rest_service}} object.
#' @param layers A character vector, the numbers of the layers, 0 to n - 1. Defaults to all of them.
#' 
#' @return A \code{rest_response} object with the content normalized.
#'
#'@export
get_layers <- function (rest, layers = all_layers(rest)) {	
	body <- list(
		layers = paste(layers, collapse = ","),
		transportType = "esriTransportTypeEmbedded",
		returnAttachments = "true",
		returnAttachmentsDataByUrl = "true",
		async = "false",
		syncModel = "none",
		syncDirection = "bidirectional",
		attachmentsSyncDirection = "bidirectional",
		dataFormat = "json"
	)
	
	res <- rest_POST(rest, "FeatureServer/createReplica", params = body)
	
	for (i in layers) res <- normalize_layer(res, i)
	
	res
}