# ---- REST API for ResourcesPage data processing ----
# ResourcesPage/API/cronjob.R should do major pre-processing.
# This script does any parameterized processing work and
# serves the endpoints via the R utility Plumber.
library(ImmuneSpaceAPI)

#############################################
###               ENDPOINTS               ###
#############################################

#* Most commonly downloaded (via ImmuneSpaceR) and viewed (via UI) Studies
#* @param from The start date
#* @param to The end date
#* @get /log_data
function(from = NULL, to = NULL) {
  .log_data(from, to)
}

#* Studies with most citations (for use also to show most recently published papers)
#* @get /pubmed_data
function(){
  .pubmed_data()
}

#* Get study clusters using UMAP
#* @get /sdy_metadata
function(){
  .sdy_metadata()
}
