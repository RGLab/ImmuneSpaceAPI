#' Retrieve artifacts on RServe machine mapped to the docker container
#'
#' @param fileName file name sub-string to use for search
#' @export
loadLocalFile <- function(fileName){
  # pull most recent file in case any old objects persist
  fl <- grep(paste0("\\d{4}-\\d{2}-\\d{2}_", fileName),
             list.files(path = "/app/"),
             value = TRUE)
  fl <- sort(fl, decreasing = TRUE)[[1]]
  ret <- readRDS(paste0("/app/", fl))
}
