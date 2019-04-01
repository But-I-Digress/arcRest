	
date <- function () {
	date <- integer()
	class(date) <- "POSIXct"
	date
}

#' @title Extract Layer
#'
#' @description Extracts a data frame from the layers returned by \code{\link{get_layers}}. Optionally, downloads the layer's attachments.
#'
#' @param res A rest_response object returned by \code{\link{get_layers}}.
#' @param layer_no A single integer, 0 to n - 1, describing the layer to extract.
#' @param folder_path An optional path to a directory. If it exists, any attachments will be downloaded there. 
#' @param return_geometry Logical, should the geometry be returned. 
#'
#' @return A data frame or an Simple Feature (SF) object if the geometry is returned.. If there were attachments, the URLs for each record will be aggregated in to a list and then added to the data frame as an ``url'' field. If the \code{folder_path} was specified, then instead, the paths of the attachments will be added as a ``path'' field.
#'
#' @export
extract_layer <- function (res, layer_no = 0, folder_path = NULL, return_geometry = FALSE) {
	features <- res$content$layers$features[[layer_no + 1]]$attributes
	
	if(length(res$content$layers$features[[layer_no + 1]]) == 0)  {
		get_layer_info(layers$rest, layer_no) -> info
		info$content$fields -> fields
		
		d <- data.frame()
		
		types <- list(esriFieldTypeSmallInteger = integer(), esriFieldTypeInteger = integer(), esriFieldTypeSingle = numeric(), esriFieldTypeDouble = numeric(), esriFieldTypeString = character(), esriFieldTypeDate = date(), esriFieldTypeOID = integer(), esriFieldTypeGUID = character(), esriFieldTypeGlobalID = character())
		
		for (i in 1:nrow(fields)) d[fields[i, "alias"]] <- if(is.null(unlist(types[fields[i, "type"]]))) logical() else types[fields[i, "type"]]
		
		return(d)	
	}

	if (return_geometry) if (!is.null(geometry <- res$content$layers$features[[layer_no +  1]]$geometry)) {
		features <- cbind(features, geometry)
		features <- sf::st_as_sf(features, coords = c("x", "y"), crs = 4326)
	}

	if (!is.null(attachments <- res$content$layers$attachments[[layer_no +  1]])) {              
		if (missing(folder_path)) {
			attachments <- aggregate(url ~ parentGlobalId, data = attachments, FUN = list, simplify = FALSE)
		}  else {
			attachments$path <- file.path(folder_path, attachments$name)
			for (i in 1:nrow(attachments)) if (!file.exists(attachments[i, "path"])) rest_download(res$rest, url = attachments[i, "url"], destfile = attachments[i, "path"])
			attachments <- aggregate(path ~ parentGlobalId, data = attachments, FUN = list, simplify = FALSE)
		}
		features <- merge(features, attachments, by.x = "GlobalID", by.y = "parentGlobalId", all = TRUE)
	}

	features
}
