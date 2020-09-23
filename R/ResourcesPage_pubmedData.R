#' Prepare pubmed data for serving
#'
#' @import data.table
#' @export
.pubmed_data <- function(){
  allIds <- loadLocalFile("pubmedInfo")

  # Get counts and order by count
  countByPubId <- getCountByPubId(allIds)

  # Setup for easy use in render named list with original_id
  # as key and value {citations, study, datePublished, studyNum, title}
  res <- preparePubMedDataForService(countByPubId)
}

###############################################
###               HELPERS                   ###
###############################################
getCountByPubId <- function(allIds){
  countByPubId <- allIds[, .(Citations = .N,
                             datePublished = unique(datePublished),
                             title = unique(original_title),
                             studyNum = unique(studyNum)),
                         by = .(original_id, study)]

  # For papers connected to multiple studies, take first listed
  for(id in unique(countByPubId$original_id)){
    loc <- which(countByPubId$original_id == id)
    if(length(loc) > 1){
      locToRemove <- loc[2:length(loc)]
      countByPubId <- countByPubId[ -locToRemove,]
    }
  }

  setorder(countByPubId, -Citations)
  return(countByPubId)
}

preparePubMedDataForService <- function(countByPubId){
  res <- list()
  for(i in seq(1:nrow(countByPubId))){
    tmp <- as.vector(countByPubId[i,])
    res[[i]] <- list(citations = tmp$Citations,
                     study = tmp$study,
                     datePublished = tmp$datePublished,
                     studyNum = tmp$studyNum,
                     title = tmp$title)
  }
  names(res) <- countByPubId$original_id
  return(res)
}
