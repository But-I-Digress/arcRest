

library(arcRest)

url <- "https://services1.arcgis.com/Wc9dp1aJDyYgFOH9/arcgis/rest/services/service_9d19ac4abbc84d639ce749114845377f/FeatureServer"
creds <- config::get("AGOL")


rest <- rest_service(url, creds$usr, creds$pwd)
rest
create_replica(rest, "data", 1:10)
