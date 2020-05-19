#' Retrieve artifacts on RServe machine mapped to the docker container
#'
#' @param fileName file name sub-string to use for search
#' @export
loadLocalFile <- function(fileName){
  # check for localPath if doing local testing
  localPath <- tryCatch({
    get("localPath")
    }, error = function(e){
      return("")
    })

  pathToUse <- ifelse(nchar(localPath) > 0,
                      localPath,
                      "/app/")

  # pull most recent file in case any old objects persist
  fls <- grep(paste0("\\d{4}-\\d{2}-\\d{2}_", fileName),
             list.files(path = pathToUse),
             value = TRUE)
  fl <- sort(fls, decreasing = TRUE)[[1]]
  ret <- readRDS(paste0(pathToUse, fl))
}
