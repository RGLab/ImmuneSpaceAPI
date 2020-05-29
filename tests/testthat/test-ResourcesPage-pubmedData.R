context("Process PubMed Data")

pubMedData <- readRDS("datasets/2020-01-15_pubmedInfo.rds")

testPubMedData <- function(data){
  loc <- grep("(C|c)itations", colnames(data))
  expect_true(all(is.numeric(data[[loc]])))
  expect_equivalent(range(data[[loc]]), c(2,80))

  expect_true(all(grepl("SDY\\d{2,4}", data$study)))

  expect_true(all(grepl("\\d{4}-(\\d{1,2}|NA)", data$datePublished)))

  expect_equivalent(as.double(gsub("SDY", "", data$study)), data$studyNum)

  expect_true(all(!is.na(data$title)))
}

test_that("countByPubId", {
  countByPubId <- ImmuneSpaceLabKeyAPI:::getCountByPubId(pubMedData)

  expectedCols <- c("original_id", "Citations", "study", "datePublished", "title", "studyNum")
  expect_equivalent(expectedCols, colnames(countByPubId))

  testPubMedData(countByPubId)

})

test_that("preparePubMedDataForService", {
  countByPubId <- ImmuneSpaceLabKeyAPI:::getCountByPubId(pubMedData)

  res <- ImmuneSpaceLabKeyAPI:::preparePubMedDataForService(countByPubId)

  expect_true(is.list(res))
  expect_equivalent(names(res[[1]]), c("citations", "study", "datePublished", "studyNum", "title"))

  tmp <- data.table::rbindlist(res)

  testPubMedData(tmp)
})
