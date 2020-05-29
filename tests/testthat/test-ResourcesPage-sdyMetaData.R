context("Process Study Meta-Data")

assays <- c("elisa", "elispot", "fcs", "gene_expression",
            "hai", "mbaa", "neut_ab_titer", "pcr")
sdyMetaData <- readRDS("datasets/2019-12-09_sdyMetaData.rds")

test_that("ensureAllIntegerValues", {
  tmp <- c(".00", ">30", "20", "8.00")
  new <- ImmuneSpaceLabKeyAPI:::ensureAllIntegerValues(tmp)
  expect_true(all(is.integer(newMinAge)))
  expect_true(all.equal(new, c(0,30,20,8)))
})

test_that("addConditionData", {
  conditions <- c("Dengue", "Dermatomyositis", "Ebola", "Healthy", "Hepatitis",
                  "HIV", "Influenza", "Malaria","Meningitis", "Smallpox", "Tuberculosis",
                  "Unknown", "Varicella_Zoster", "West_Nile","Yellow_Fever", "Zika", "CMV")
  res <- ImmuneSpaceLabKeyAPI:::addConditionData(sdyMetaData)
  expect_true(all(conditions %in% colnames(res)))
  res <- res[ , colnames(res) %in% conditions ]
  expect_true(sum(res$Influenza) == 38)
  expect_equivalent(range(res),c(0,1))
})

test_that("addAssayData", {
  res <- ImmuneSpaceLabKeyAPI:::addAssayData(sdyMetaData, assays)
  expectedColnames <- paste0("has_", assays)
  expect_true(all(expectedColnames %in% colnames(res)))
  res <- res[ , colnames(res) %in% expectedColnames ]
  expect_true(sum(res$has_hai) == 41)
  expect_equivalent(range(res),c(0,1))
})

test_that("calculateDistanceMatrix", {
  sdyMetaData$newMinAge <- ImmuneSpaceLabKeyAPI:::ensureAllIntegerValues(sdyMetaData$minimum_age)
  euclideanCols <- c("actual_enrollment", "newMinAge")
  categoricalCols <- c("elisa_0_Days", "gene_expression_files_0_Days")
  res <- sdyMetaData[, colnames(sdyMetaData) %in% c(euclideanCols, categoricalCols)]
  distMx <- ImmuneSpaceLabKeyAPI:::calculateDistanceMatrix(res)
  expect_equivalent(dim(distMx), c(nrow(res), nrow(res)))
  expect_equivalent(colnames(distMx), rownames(res))
  expect_equivalent(rownames(distMx), rownames(res))
  expect_equivalent(range(distMx), c(0, 0.5811834))
})

test_that("calculateDistanceMatrix", {
  studyAccessions <- rownames(sdyMetaData)
  res <- ImmuneSpaceLabKeyAPI:::prepareSdyMetaDataForService(sdyMetaData,
                                                             assays,
                                                             studyAccessions)
  assaysGrep <- paste(paste0("^", assays), collapse = "|")
  remainingAssayCols <- grep(assaysGrep, colnames(res), value = TRUE)
  expect_true(length(remainingAssayCols) == 0)
  expect_true("study" %in% colnames(res))
})

