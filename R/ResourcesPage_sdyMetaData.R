#' Prepare study meta-data for serving
#'
#' @import data.table uwot
#' @export
.sdy_metadata <- function() {
  sdyMetaData <- loadLocalFile("sdyMetaData")
  assays <- c("elisa", "elispot", "fcs", "gene_expression", "hai", "mbaa", "neut_ab_titer", "pcr")

  # ---- Feature Engineering -----
  studyAccessions <- rownames(sdyMetaData)
  colsToRm <- which(colnames(sdyMetaData) %in% c(
    "person_accession",
    "sponsoring_organization",
    "initial_data_release_date"
  ))
  sdyMetaData <- sdyMetaData[, -(colsToRm)]

  sdyMetaData$newMinAge <- ensureAllIntegerValues(sdyMetaData$minimum_age)
  sdyMetaData$newMaxAge <- ensureAllIntegerValues(sdyMetaData$maximum_age)
  sdyMetaData <- sdyMetaData[, -(grep("(min|max)imum", colnames(sdyMetaData)))]

  sdyMetaData <- addConditionData(sdyMetaData)

  sdyMetaData$clinical_trial <- ifelse(sdyMetaData$clinical_trial == "Y", 1, 0)

  sdyMetaData <- addAssayData(sdyMetaData, assays)

  # ------- Distance Calculations ---
  totalDistMx <- calculateDistanceMatrix(sdyMetaData)

  # ------- Dimension Reduction ----
  # Use UMAP to embed distance matrix in 2d space - https://github.com/jlmelville/uwot/issues/22
  set.seed(8)
  umap <- uwot::umap(
    X = totalDistMx,
    n_neighbors = 50,
    n_components = 2
  )
  sdyMetaData$x <- umap[, 1]
  sdyMetaData$y <- umap[, 2]

  # ----- prepare for serving ----
  sdyMetaData <- prepareSdyMetaDataForService(sdyMetaData, assays, studyAccessions)

  # Convert to list of lists for parsing
  res <- lapply(split(sdyMetaData, seq_along(sdyMetaData[, 1])), as.list)
}


###############################################
###               HELPERS                   ###
###############################################

ensureAllIntegerValues <- function(originalValues) {
  tmp <- suppressWarnings(as.integer(originalValues))
  if (any(is.na(tmp))) {
    tmp[is.na(tmp)] <- extractIntegerFromString(originalValues[is.na(tmp)])
  }
  return(tmp)
}

extractIntegerFromString <- function(string) {
  hasInteger <- grepl("\\d", string)
  if (hasInteger) {
    int <- as.numeric(regmatches(string, regexpr("(\\d+)", string, perl = TRUE)))
    return(int)
  } else {
    return(NA)
  }
}

#' @importFrom stats model.matrix
addConditionData <- function(sdyMetaData) {
  mapToNewCondition <- function(x) {
    if (grepl("healthy|normal|naive", x, ignore.case = TRUE)) {
      return("Healthy")
    } else if (grepl("influenza|H1N1", x, ignore.case = TRUE)) {
      return("Influenza")
    } else if (grepl("CMV", x, ignore.case = TRUE)) {
      return("CMV")
    } else if (grepl("TB|tuberculosis", x, ignore.case = TRUE)) {
      return("Tuberculosis")
    } else if (grepl("Yellow Fever", x, ignore.case = TRUE)) {
      return("Yellow_Fever")
    } else if (grepl("Mening", x, ignore.case = TRUE)) {
      return("Meningitis")
    } else if (grepl("Malaria", x, ignore.case = TRUE)) {
      return("Malaria")
    } else if (grepl("HIV", x, ignore.case = TRUE)) {
      return("HIV")
    } else if (grepl("Dengue", x, ignore.case = TRUE)) {
      return("Dengue")
    } else if (grepl("ZEBOV", x, ignore.case = TRUE)) {
      return("Ebola")
    } else if (grepl("Hepatitis", x, ignore.case = TRUE)) {
      return("Hepatitis")
    } else if (grepl("Smallpox|vaccinia", x, ignore.case = TRUE)) {
      return("Smallpox")
    } else if (grepl("JDM|Dermatomyositis", x, ignore.case = TRUE)) {
      return("Dermatomyositis")
    } else if (grepl("West Nile", x, ignore.case = TRUE)) {
      return("West_Nile")
    } else if (grepl("Zika", x, ignore.case = TRUE)) {
      return("Zika")
    } else if (grepl("Varicella", x, ignore.case = TRUE)) {
      return("Varicella_Zoster")
    } else {
      return("Unknown")
    }
  }

  sdyMetaData$newCondition <- sapply(sdyMetaData$condition_studied, mapToNewCondition)
  sdyMetaData <- sdyMetaData[, -grep("condition_studied", colnames(sdyMetaData))]

  tmp <- model.matrix(~condition, data.frame(
    study = rownames(sdyMetaData),
    condition = sdyMetaData$newCondition
  ))
  tmp <- data.frame(tmp[, -1])
  colnames(tmp) <- gsub("condition", "", colnames(tmp))
  cmv <- unname(unlist(rowSums(tmp)))
  tmp$CMV <- ifelse(cmv == 0, 1, 0)
  tmp$study <- sdyMetaData$study <- rownames(sdyMetaData)

  sdyMetaData <- merge(sdyMetaData, tmp, by = "study")
  sdyMetaData <- sdyMetaData[, -grep("newCondition", colnames(sdyMetaData))]
}

addAssayData <- function(sdyMetaData, assays) {
  for (assay in assays) {
    relevantCols <- grep(assay, colnames(sdyMetaData))
    sdyMetaData[paste0("has_", assay)] <- apply(sdyMetaData, 1, function(x) {
      if (any(x[relevantCols] == 1)) {
        return(1)
      } else {
        return(0)
      }
    })
  }
  return(sdyMetaData)
}

#' @importFrom stats dist
calculateDistanceMatrix <- function(sdyMetaData) {
  # Distance type to use
  euclideanCols <- c("newMinAge", "newMaxAge", "actual_enrollment")
  useEuclidean <- which(colnames(sdyMetaData) %in% euclideanCols)
  useCategorical <- which(!colnames(sdyMetaData) %in% euclideanCols)

  # Calculate distances matrix using just euclidean and scale to 0 to 1
  eucMx <- sdyMetaData[, useEuclidean]
  eucMx <- scale(eucMx, center = FALSE, scale = colSums(eucMx))
  eucDistMx <- suppressWarnings(as.matrix(dist(eucMx, method = "euclidean")))

  # Calculate distance for categoricals using jaccard distance
  catMx <- sdyMetaData[, useCategorical]
  catDistMx <- suppressWarnings(as.matrix(dist(catMx, method = "binary")))

  # combine distance metrics in proportion to info
  totalDistMx <- eucDistMx * (length(useEuclidean) / length(colnames(sdyMetaData))) +
    catDistMx * (length(useCategorical) / length(colnames(sdyMetaData)))
}

prepareSdyMetaDataForService <- function(sdyMetaData, assays, studyAccessions) {
  # Remove columns not needed for labeling: individual assay*timepoint
  assaysGrep <- paste(paste0("^", assays), collapse = "|")
  assayColsToRm <- grep(assaysGrep, colnames(sdyMetaData))
  sdyMetaData <- sdyMetaData[, -assayColsToRm]

  # Add back study for use in plotting
  sdyMetaData$study <- studyAccessions

  return(sdyMetaData)
}
