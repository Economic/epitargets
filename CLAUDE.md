# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working
with code in this repository.

## Project Overview

`epitargets` is an R package by the Economic Policy Institute that
provides utilities for the `targets` pipeline framework. It wraps
`targets` and `tarchetypes` to add automatic date-tracking alongside
pipeline targets and age-based cue support for API targets.

General R package development conventions (workflows, documentation,
testing) live in `.claude/rules/r_package.md`. Note that
`devtools::build_readme()` should also be run after changes that affect
`README.Rmd`.

## Architecture

All package code lives in `R/functions.R`. The functions fall into a few
groups:

Date-tracking targets:

- **[`tar_target_date()`](https://economic.github.io/epitargets/reference/tar_target_date.md)**
  — wraps `tar_target_raw()` to create a primary target plus a companion
  `_date` target that records
  [`Sys.Date()`](https://rdrr.io/r/base/Sys.time.html) when the primary
  target runs
- **[`tar_age_date()`](https://economic.github.io/epitargets/reference/tar_age_date.md)**
  — like
  [`tar_target_date()`](https://economic.github.io/epitargets/reference/tar_target_date.md)
  but adds an age-based cue via
  [`tarchetypes::tar_cue_age_raw()`](https://docs.ropensci.org/tarchetypes/reference/tar_cue_age.html)
  so the target re-runs after a configurable time period (default: 1
  day)
- **[`collect_target_date()`](https://economic.github.io/epitargets/reference/collect_target_date.md)**
  — gathers `_date` targets into a tibble with columns `name` and `time`

File read/write helpers:

- **[`tar_csv_read()`](https://economic.github.io/epitargets/reference/tar_csv_read.md)**
  — creates a pair of targets: a `_file` target tracking the CSV path
  (`format = "file"`) and a read target using
  [`readr::read_csv()`](https://readr.tidyverse.org/reference/read_delim.html)
- **[`tar_parquet_read()`](https://economic.github.io/epitargets/reference/tar_parquet_read.md)**
  — like
  [`tar_csv_read()`](https://economic.github.io/epitargets/reference/tar_csv_read.md)
  but reads via
  [`arrow::read_parquet()`](https://arrow.apache.org/docs/r/reference/read_parquet.html);
  the read target defaults to `format = "parquet"`
- **[`create_csv()`](https://economic.github.io/epitargets/reference/create_csv.md)**
  — thin wrapper around
  [`readr::write_csv()`](https://readr.tidyverse.org/reference/write_delim.html)
  that returns the file path (useful as a `targets` format function)

Interactive helpers:

- **[`tar_read_stash()`](https://economic.github.io/epitargets/reference/tar_read_stash.md)**
  — reads a target via
  [`targets::tar_read_raw()`](https://docs.ropensci.org/targets/reference/tar_read.html)
  and assigns the value into an environment (default `.target` in the
  global env) for interactive exploration
- **[`rstudio_addin_tar_read_stash()`](https://economic.github.io/epitargets/reference/rstudio_addin_tar_read_stash.md)**
  — RStudio/Positron addin that stashes the target named under the
  cursor via
  [`tar_read_stash()`](https://economic.github.io/epitargets/reference/tar_read_stash.md),
  using `atcursor` (an optional dependency) to locate the symbol

## Dependencies

The code uses functions from `targets`, `tarchetypes`
(`tar_cue_age_raw`), `readr` (`read_csv`, `write_csv`), `arrow`
(`read_parquet`), `tibble` (`tibble`), and `rlang`. `atcursor` is an
optional (Suggests) dependency used only by the RStudio addin.
