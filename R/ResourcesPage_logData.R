#' Prepare logs data for serving
#'
#' @param from start date for filtering, YYYY-MM-DD
#' @param to end date for filtering, YYYY-MM-DD
#' @import data.table
#' @export
.log_data <- function(from, to) {
  format <- "%Y-%m-%d"

  if (is.null(from)) {
    from <- "2016-01-01"
  }
  from <- as.POSIXct(as.Date(from), format = format)

  if (is.null(to)) {
    to <- Sys.Date()
  }
  to <- as.POSIXct(as.Date(to), format = format)

  parsedLogs <- loadLocalFile("parsedLogs")

  parsedLogs <- parsedLogs[Date >= from & Date < to]

  byStudy <- mungeLogsToByStudy(parsedLogs)

  byMonth <- mungeLogsToByMonth(parsedLogs)

  res <- list(byStudy = byStudy, byMonth = byMonth)
}

###############################################
###               HELPERS                   ###
###############################################
mungeLogsToByStudy <- function(parsedLogs) {
  byStudy <- parsedLogs[, list(
    ISR = unique(sum(ISR_connections)),
    UI = unique(sum(UI_pageviews)),
    total = unique(sum(total_views))
  ),
  by = .(studyId)
  ]
  setorder(byStudy, "studyId")
  byStudy <- lapply(split(byStudy, seq_along(byStudy[, studyId])), as.list)
}

mungeLogsToByMonth <- function(parsedLogs) {
  parsedLogs[, Month := format(Date, format = "%Y-%m")]
  byMonth <- parsedLogs[, list(
    ISR = unique(sum(ISR_connections)),
    UI = unique(sum(UI_pageviews)),
    total = unique(sum(total_views))
  ),
  by = .(Month)
  ]
  setorder(byMonth, "Month")
  byMonth <- lapply(split(byMonth, seq_along(byMonth[, Month])), as.list)
}
