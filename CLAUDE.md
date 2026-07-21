# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`epitargets` is an R package by the Economic Policy Institute that provides utilities for the `targets` pipeline framework. It wraps `targets` and `tarchetypes` to add automatic date-tracking alongside pipeline targets and age-based cue support for API targets.

General R package development conventions (workflows, documentation, testing)
live in `.claude/rules/r_package.md`. Note that `devtools::build_readme()`
should also be run after changes that affect `README.Rmd`.

## Architecture

All package code lives in `R/functions.R`. The functions fall into a few groups:

Date-tracking targets:

- **`tar_target_date()`** — wraps `tar_target_raw()` to create a primary target plus a companion `_date` target that records `Sys.Date()` when the primary target runs
- **`tar_age_date()`** — like `tar_target_date()` but adds an age-based cue via `tarchetypes::tar_cue_age_raw()` so the target re-runs after a configurable time period (default: 1 day)
- **`collect_target_date()`** — gathers `_date` targets into a tibble with columns `name` and `time`

File read/write helpers:

- **`tar_csv_read()`** — creates a pair of targets: a `_file` target tracking the CSV path (`format = "file"`) and a read target using `readr::read_csv()`
- **`tar_parquet_read()`** — like `tar_csv_read()` but reads via `arrow::read_parquet()`; the read target defaults to `format = "parquet"`
- **`create_csv()`** — thin wrapper around `readr::write_csv()` that returns the file path (useful as a `targets` format function)

Interactive helpers:

- **`tar_read_stash()`** — reads a target via `targets::tar_read_raw()` and assigns the value into an environment (default `.target` in the global env) for interactive exploration
- **`rstudio_addin_tar_read_stash()`** — RStudio/Positron addin that stashes the target named under the cursor via `tar_read_stash()`, using `atcursor` (an optional dependency) to locate the symbol

## Dependencies
The code uses functions from `targets`, `tarchetypes` (`tar_cue_age_raw`), `readr` (`read_csv`, `write_csv`), `arrow` (`read_parquet`), `tibble` (`tibble`), and `rlang`. `atcursor` is an optional (Suggests) dependency used only by the RStudio addin.
