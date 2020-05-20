# Wrapper for easy use from Docker
# Not expecting library to have been loaded before call to `startAPI()`

#' Wrapper function for copying plumber script to specified location
#'
#' @export
copyPlumberScriptToLocation <- function(outputPath){
  pathToScript <- file.path(system.file(package = "ImmuneSpaceLabKeyAPI"), "main.R")
  file.copy(pathToScript, outputPath)
}
