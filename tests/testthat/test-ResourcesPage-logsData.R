context("Process Logs Data")

logsData <- readRDS("datasets/2020-01-30_parsedLogs.rds")

test_that("mungeLogsbyStudy", {
  byStudy <- ImmuneSpaceLabKeyAPI:::mungeLogsToByStudy(logsData)
  expect_true(is.list(byStudy))
  expect_equivalent(names(byStudy[[1]]), c("studyId", "ISR", "UI", "total"))
  tmp <- data.table::rbindlist(byStudy)
  expect_true(all(sapply(tmp, typeof) == "double"))
  expect_equivalent(range(tmp$total), c(7, 668))
})

test_that("mungeLogsByMonth", {
  byMonth <- ImmuneSpaceLabKeyAPI:::mungeLogsToByMonth(logsData)
  expect_true(is.list(byMonth))
  expect_equivalent(names(byMonth[[1]]), c("Month", "ISR", "UI", "total"))
  tmp <- data.table::rbindlist(byMonth)
  expect_equivalent(sapply(tmp, typeof), c("character", "double", "double", "double"))
  expect_true(all(grepl("\\d{4}-(\\d{1,2}|NA)", tmp$Month)))
  expect_equivalent(range(tmp$total), c(30, 846))
})
