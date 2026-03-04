#' Write data to a CSV file and return the file path
#'
#' A thin wrapper around [readr::write_csv()] that writes `data` to `file` and
#' returns the file path. This is useful as a targets format function where the
#' target value should be the path to the written file.
#'
#' @param data A data frame to write.
#' @param file A string giving the file path to write to.
#' @param ... Additional arguments passed to [readr::write_csv()].
#'
#' @return The file path `file`, invisibly.
#' @export
#'
#' @examples
#' targets::tar_dir({
#'   create_csv(data.frame(x = 1:3), "test.csv")
#' })
create_csv <- function(data, file, ...) {
  readr::write_csv(data, file, ...)
  invisible(file)
}

#' Create a target with a companion date target
#'
#' Wraps [targets::tar_target_raw()] to create a primary target and a companion
#' `_date` target that records [Sys.Date()] whenever the primary target runs.
#'
#' @param name Symbol, name of the target.
#' @param command Expression, R command to run the target.
#' @param ... Additional arguments passed to [targets::tar_target_raw()].
#'
#' @return A list of two target objects: the primary target and the companion
#'   `_date` target.
#' @export
#'
#' @examples
#' if (identical(Sys.getenv("TAR_EXAMPLES"), "true")) {
#' targets::tar_dir({
#'   targets::tar_script({
#'     library(targets)
#'     list(
#'       epitargets::tar_target_date(x, 1 + 1)
#'     )
#'   })
#'   targets::tar_make()
#'   targets::tar_read(x)
#'   targets::tar_read(x_date)
#' })
#' }
tar_target_date <- function(name, command, ...) {
  name_str <- deparse(substitute(name))
  command_expr <- substitute(command)

  main_target <- targets::tar_target_raw(
    name = name_str,
    command = command_expr,
    ...
  )

  date_name <- paste0(name_str, "_date")
  date_command <- bquote({
    force(.(as.name(name_str)))
    Sys.Date()
  })

  date_target <- targets::tar_target_raw(
    name = date_name,
    command = date_command
  )

  list(main_target, date_target)
}

#' Create an age-cued target with a companion date target
#'
#' Like [tar_target_date()] but adds an age-based cue via
#' [tarchetypes::tar_cue_age_raw()] so the target automatically re-runs after
#' a configurable time period. Useful for targets that fetch data from APIs.
#'
#' @param name Symbol, name of the target.
#' @param command Expression, R command to run the target.
#' @param age A [difftime] object specifying the maximum age before the target
#'   re-runs. Defaults to 1 day.
#' @param ... Additional arguments passed to [targets::tar_target_raw()].
#'
#' @return A list of two target objects: the primary target (with an age cue)
#'   and the companion `_date` target.
#' @export
#'
#' @examples
#' if (identical(Sys.getenv("TAR_EXAMPLES"), "true")) {
#' targets::tar_dir({
#'   targets::tar_script({
#'     library(targets)
#'     list(
#'       epitargets::tar_age_date(x, 1 + 1, age = as.difftime(1, units = "days"))
#'     )
#'   })
#'   targets::tar_make()
#'   targets::tar_read(x)
#'   targets::tar_read(x_date)
#' })
#' }
tar_age_date <- function(name, command, age = as.difftime(1, units = "days"), ...) {
  name_str <- deparse(substitute(name))
  command_expr <- substitute(command)

  cue <- tarchetypes::tar_cue_age_raw(name = name_str, age = age)

  main_target <- targets::tar_target_raw(
    name = name_str,
    command = command_expr,
    cue = cue,
    ...
  )

  date_name <- paste0(name_str, "_date")
  date_command <- bquote({
    force(.(as.name(name_str)))
    Sys.Date()
  })

  date_target <- targets::tar_target_raw(
    name = date_name,
    command = date_command
  )

  list(main_target, date_target)
}

#' Collect date targets into a tibble
#'
#' Gathers the values of companion `_date` targets (created by
#' [tar_target_date()] or [tar_age_date()]) into a [tibble::tibble] with columns
#' `name` and `time`.
#'
#' @param ... Date values from `_date` targets. Pass each `_date` target by
#'   name (e.g., `x_date, y_date`).
#'
#' @return A [tibble::tibble] with columns `name` (character) and `time`.
#' @export
#'
#' @examples
#' collect_target_date(x_date = as.Date("2024-01-01"), y_date = as.Date("2024-06-15"))
collect_target_date <- function(...) {
  target_names <- as.character(match.call(expand.dots = FALSE)$...)
  target_names <- sub("_date$", "", target_names)
  tibble::tibble(
    name = target_names,
    time = c(...)
  )
}
