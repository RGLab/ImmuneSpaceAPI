context("Process PubMed Data")

pubMedData <- readRDS("datasets/2020-01-15_pubmedInfo.rds")

test_that("countByPubId", {
  countByPubId <- ImmuneSpaceLabKeyAPI:::getCountByPubId(pubMedData)

  expectedCols <- c("original_id", "Citations", "study", "datePublished", "title", "studyNum")
  expect_equivalent(expectedCols, colnames(countByPubId))

  expect_true(all(grepl("SDY\\d{2,4}", countByPubId$study)))

  # Date published may have NA in month? TODO: figure out why!
  expect_true(all(grepl("\\d{4}-(\\d{1,2}|NA)", countByPubId$datePublished)))

  studyLessSDY <- as.numeric(gsub("SDY", "", countByPubId$study))
  expect_equivalent(studyLessSDY, countByPubId$studyNum)

  expect_true(all(is.integer(newMinAge)))
  expect_true(all.equal(new, c(0,30,20,8)))
})

test_that("preparePubMedDataForService", {
  countByPubId <- ImmuneSpaceLabKeyAPI:::getCountByPubId(pubMedData)

  res <- ImmuneSpaceLabKeyAPI:::preparePubMedDataForService(countByPubId)
  tmp <- data.table::rbindlist(res)

  expect_true(all(is.numeric(tmp$citations)))
  expect_equivalent(range(tmp$citations), c(2,80))

  expect_true(all(grepl("SDY\\d{2,4}", tmp$study)))

  expect_true(all(grepl("\\d{4}-(\\d{1,2}|NA)", tmp$datePublished)))

  expect_equivalent(as.double(gsub("SDY", "", tmp$study)), tmp$studyNum)

  expect_true(all(!is.na(tmp$title)))
})
