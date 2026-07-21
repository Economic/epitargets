#' Read a CSV file as a target
#'
#' A convenience wrapper around [tarchetypes::tar_file_read()] for CSV files.
#' Creates a pair of targets: one to track the file with `format = "file"`,
#' and another to read the file with [readr::read_csv()].
#'
#' @param name Symbol, name of the target.
#' @param command Expression, R code that returns the file path to the CSV.
#' @param .read_csv_args A named list of additional arguments passed to
#'   [readr::read_csv()]. Defaults to `list(show_col_types = FALSE)`.
#'   Supplying this argument replaces the defaults entirely.
#' @param ... Additional arguments passed to [targets::tar_target_raw()]
#'   for the read target.
#'
#' @details The storage format of the read target is inherited from
#'   `targets::tar_option_get("format")` (by default `"rds"`). Callers can
#'   override it by passing e.g. `format = "qs"` via `...`.
#'
#' @return A list of two target objects: a file-tracking target
#'   (`name_file`) and a CSV-reading target (`name`).
#' @export
#'
#' @examples
#' if (identical(Sys.getenv("TAR_EXAMPLES"), "true")) {
#' targets::tar_dir({
#'   targets::tar_script({
#'     library(targets)
#'     list(
#'       epitargets::tar_csv_read(my_data, "data.csv")
#'     )
#'   })
#'   targets::tar_manifest()
#' })
#' }
tar_csv_read <- function(
  name,
  command,
  .read_csv_args = list(show_col_types = FALSE),
  ...
) {
  name_str <- deparse(substitute(name))
  command_expr <- substitute(command)
  name_file <- paste0(name_str, "_file")

  read_call <- as.call(c(
    list(quote(readr::read_csv), file = as.name(name_file)),
    .read_csv_args
  ))

  list(
    targets::tar_target_raw(
      name = name_file,
      command = command_expr,
      format = "file"
    ),
    targets::tar_target_raw(
      name = name_str,
      command = read_call,
      ...
    )
  )
}

#' Read a Parquet file as a target
#'
#' A convenience wrapper around [tarchetypes::tar_file_read()] for Parquet
#' files. Creates a pair of targets: one to track the file with
#' `format = "file"`, and another to read the file with [arrow::read_parquet()].
#'
#' @param name Symbol, name of the target.
#' @param command Expression, R code that returns the file path to the Parquet
#'   file.
#' @param .read_parquet_args A named list of additional arguments passed to
#'   [arrow::read_parquet()].
#' @param ... Additional arguments passed to [targets::tar_target_raw()]
#'   for the read target.
#'
#' @details The read target's storage format defaults to `"parquet"` (overriding
#'   the usual `targets::tar_option_get("format")` inheritance), so the cached
#'   object is written as a Parquet file in `_targets/objects/`. Callers can
#'   override this by passing e.g. `format = "rds"` via `...`.
#'
#' @return A list of two target objects: a file-tracking target
#'   (`name_file`) and a Parquet-reading target (`name`).
#' @export
#'
#' @examples
#' if (identical(Sys.getenv("TAR_EXAMPLES"), "true")) {
#' targets::tar_dir({
#'   targets::tar_script({
#'     library(targets)
#'     list(
#'       epitargets::tar_parquet_read(my_data, "data.parquet")
#'     )
#'   })
#'   targets::tar_manifest()
#' })
#' }
tar_parquet_read <- function(
  name,
  command,
  .read_parquet_args,
  ...
) {
  name_str <- deparse(substitute(name))
  command_expr <- substitute(command)
  name_file <- paste0(name_str, "_file")

  read_args <- if (missing(.read_parquet_args)) list() else .read_parquet_args
  read_call <- as.call(c(
    list(quote(arrow::read_parquet), file = as.name(name_file)),
    read_args
  ))

  user_has_format <- "format" %in% ...names()

  read_target <- if (user_has_format) {
    targets::tar_target_raw(name = name_str, command = read_call, ...)
  } else {
    targets::tar_target_raw(
      name = name_str,
      command = read_call,
      format = "parquet",
      ...
    )
  }

  list(
    targets::tar_target_raw(
      name = name_file,
      command = command_expr,
      format = "file"
    ),
    read_target
  )
}

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
tar_age_date <- function(
  name,
  command,
  age = as.difftime(1, units = "days"),
  ...
) {
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

#' Read a target and stash it in an environment
#'
#' Reads a target with [targets::tar_read()] and, in addition to returning it,
#' assigns a copy into `envir` under a fixed scratch name (`.target` by
#' default). This lets you keep a handle to the value for interactive
#' exploration without re-running the read. It is the engine behind the
#' [rstudio_addin_tar_read_stash()] addin.
#'
#' @param name Symbol or string, the target to read. NSE-friendly, matching
#'   [targets::tar_read()].
#' @param stash_name String, the variable name to assign the value to in
#'   `envir`. Defaults to `".target"`, a leading-dot scratch slot. If it
#'   already exists in `envir` it is silently overwritten.
#' @param print_value Logical. If `TRUE` (default), the value is printed after
#'   assignment so the addin behaves like the stock `tar_read` addin.
#' @param envir Environment to stash the value into. Defaults to
#'   [globalenv()].
#' @param store Character, the targets data store. Passed through to
#'   [targets::tar_read_raw()].
#' @param ... Additional arguments passed to [targets::tar_read_raw()]
#'   (e.g. `branches`).
#'
#' @details A resolved character target name is passed to
#'   [targets::tar_read_raw()] rather than [targets::tar_read()], because the
#'   latter uses non-standard evaluation and would otherwise look up a target
#'   named after the variable rather than its value.
#'
#'   When called from a non-interactive context (a script or pipeline), a
#'   warning is emitted but the value is still stashed.
#'
#' @return The target value, invisibly.
#' @export
#'
#' @examples
#' if (identical(Sys.getenv("TAR_EXAMPLES"), "true")) {
#' targets::tar_dir({
#'   targets::tar_script({
#'     library(targets)
#'     list(
#'       targets::tar_target(x, 1 + 1)
#'     )
#'   })
#'   targets::tar_make()
#'   tar_read_stash(x)
#'   .target
#' })
#' }
tar_read_stash <- function(
  name,
  stash_name = ".target",
  print_value = TRUE,
  envir = globalenv(),
  store = targets::tar_config_get("store"),
  ...
) {
  name_expr <- substitute(name)
  name_str <- if (is.symbol(name_expr)) {
    deparse(name_expr)
  } else if (is.character(name_expr)) {
    name_expr
  } else {
    as.character(name)
  }

  value <- targets::tar_read_raw(name_str, store = store, ...)

  if (!interactive()) {
    rlang::warn(sprintf(
      "tar_read_stash() stashed '%s' as '%s' in a non-interactive context.",
      name_str,
      stash_name
    ))
  }

  assign(stash_name, value, envir = envir)

  if (isTRUE(print_value)) {
    print(value)
  }

  invisible(value)
}

#' RStudio addin to read a target and stash it
#'
#' Reads the target named under the cursor (or the active selection) and stashes
#' it via [tar_read_stash()], leaving a copy in the global environment as
#' `.target`. Bind it to a keyboard shortcut in the RStudio addin manager or a
#' Positron keybinding, analogous to `targets::rstudio_addin_tar_read()`.
#'
#' @details The symbol under the cursor is extracted with
#'   [atcursor::get_word_or_selection()], which works in RStudio, VS Code, and
#'   Positron. `atcursor` is an optional dependency; if it is not installed the
#'   addin prompts to install it from its r-universe repository. If the cursor
#'   is on whitespace with no selection, the addin reports this and does
#'   nothing.
#'
#' @return The target value, invisibly (also stashed as `.target`).
#' @export
rstudio_addin_tar_read_stash <- function() {
  rlang::check_installed(
    "atcursor",
    reason = "to read the target name under the cursor.",
    action = function(pkgs, ...) {
      utils::install.packages(
        pkgs,
        repos = c(
          "https://milesmcbain.r-universe.dev/",
          getOption("repos")
        )
      )
    }
  )

  symbol <- atcursor::get_word_or_selection()

  if (length(symbol) == 0 || !nzchar(symbol)) {
    rlang::inform("No target name under the cursor.")
    return(invisible(NULL))
  }

  eval(bquote(tar_read_stash(.(as.name(symbol)))))
}
