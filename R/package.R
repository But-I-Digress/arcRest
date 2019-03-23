#'@title The arcRest Package
#'
#'@description An Interface to the Ersi Arc Collector REST Service
#'
#'@details
#' 
#' This package exports three types of functions. At the deepest level is the \code{\link{get_token}} function. This negotiates the Ersi authentication and saves the response in memory, in an environment as an object named for the ``usr''. Subsequent calls to the function reuse the token if it has not expired. For most uses, this can be ignored. 
#'
#' Two workhorse function are provided to communicate with the REST service, \code{\link{rest_GET}} and \code{\link{rest_POST}}. These each take a URL, user name and password and they negotiate the authentication using \code{get_token}. They both return a useful object. These are exported for debugging purposes. 
#'
#' The functions that users will find most helpful, \code{get_layer_info}, \code{get_layers} and \code{extract_layer}, call the functions above. One creates a \code{rest_service} object and then passes it to \code{get_layers} along with a designation of the layers in question. Then one can use \code{extract_layer} to fetch the data as a data frame.
#'
#' @examples
#' \dontrun{
#' url <- "https://services1.arcgis.com/Wc9dp1aJDyYgFOH9/arcgis/rest/services/service_9d19ac4abbc84d639ce749114845377f"
#' rest <- rest_service(url, "username", "password")
#' get_layers(rest, 0)
#' }
"_PACKAGE"
#> [1] "_PACKAGE"