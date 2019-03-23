#' @title Extract Layer
#'
#' @description Extracts a data frame from the layers returned by \code{\link{get_layers}}. Optionally, downloads the layer's attachments.
#'
#' @param res A rest_response object returned by \code{\link{get_layers}}.
#' @param layer_no A single integer, 0 to n - 1, describing the layer to extract.
#' @param folder_path An optional path to a directory. If it exists, any attachments will be downloaded there. 
#'
#' @return A data frame. If there were attachments, the URLs for each record will be aggregated in to a list and then added to the data frame as an ``url'' field. If the \code{folder_path} was specified, then instead, the paths of the attachments will be added as a ``path'' field.
#'
#' @export
extract_layer <- function (res, layer_no = 0, folder_path = NULL) {
	features <- res$content$layers$features[[layer_no + 1]]$attributes
	attachments <- res$content$layers$attachments[[layer_no + 1]]
	if (is.null(attachments)) return(features)
	
	if (missing(folder_path)) {
		attachments <- aggregate(url ~ parentGlobalId, data = attachments, FUN = list, simplify = FALSE)
	} else {
		attachments$path <- file.path(folder_path, attachments$name)
		for (i in 1:nrow(attachments)) if (!file.exists(attachments[i, "path"])) rest_download(res$rest, url = attachments[i, "url"], destfile = attachments[i, "path"])
		attachments <- aggregate(path ~ parentGlobalId, data = attachments, FUN = list, simplify = FALSE)
	}
	merge(features, attachments, by.x = "GlobalID", by.y = "parentGlobalId", all = TRUE)
}