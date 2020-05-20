# Wrapper for easy use from Docker
# Not expecting library to have been loaded before call to `startAPI()`

#' Wrapper function for starting plumber service from within Docker
#'
#' @export
createPlumberScriptEnvVar <- function(filePath){
  pathToScript <- file.path(system.file(package = "ImmuneSpaceLabKeyAPI"),
                            "main.R")
  file.create(filePath)
  writeLines(pathToScript, filePath)
}
