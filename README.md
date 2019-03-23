# arcRest

An Interface to the Ersi Arc Collector REST Service

This package exports three types of functions. At the deepest level is the `get_token` function. This negotiates the Ersi authentication and saves the response in memory, in an environment as an object named for the ``usr''. Subsequent calls to the function reuse the token if it has not expired. For most uses, this can be ignored. 

Two workhorse function are provided to communicate with the REST service, `rest_GET` and `rest_POST`. These each take a URL, user name and password and they negotiate the authentication using `get_token`. They both return a useful object. These are exported for debugging purposes. 

The functions that users will find most helpful, `get_layer_info`, `get_layers` and `extract_layer`, call the functions above. One creates a `rest_service` object and then passes it to `get_layers` along with a designation of the layers in question. Then one can use `extract_layer` to fetch the data as a data frame.

## Installation

```r
devtools::install_github("But-I-Digress/arcRest")
```