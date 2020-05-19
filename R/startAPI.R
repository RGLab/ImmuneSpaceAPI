# Wrapper for easy use from Docker
# Not expecting library to have been loaded before call to `startAPI()`

#' Wrapper function for starting plumber service from within Docker
#'
#' @import plumber
#' @export
startAPI <- function(){
  library(ImmuneSpaceLabKeyAPI)
  pathToScript <- file.path(system.file(package = "ImmuneSpaceCronjobs"),
                            "main.R")
  plumber::plumb(pathToScript)
}
