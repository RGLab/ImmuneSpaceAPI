# ---- REST API for ResourcesPage data processing ----
# ResourcesPage/API/cronjob.R should do major pre-processing.
# This script does any parameterized processing work and
# serves the endpoints via the R utility Plumber.
library(ImmuneSpaceLabKeyAPI)

#############################################
###               ENDPOINTS               ###
#############################################

#* Most commonly downloaded (via ImmuneSpaceR) and viewed (via UI) Studies
#* @param from The start date
#* @param to The end date
#* @get /log_data
function(from = NULL, to = NULL){
  res <- .log_data(from, to)
  return(res)
}

#* Studies with most citations (for use also to show most recently published papers)
#* @get /pubmed_data
function(){
  res <- .pubmed_data()
  return(res)
}

#* Get study clusters using UMAP
#* @get /sdy_metadata
function(){
  res <- .sdy_metadata()
  return(res)
}
