# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working
with code in this repository.

## Project Overview

`epitargets` is an R package by the Economic Policy Institute that
provides utilities for the `targets` pipeline framework. It wraps
`targets` and `tarchetypes` to add automatic date-tracking alongside
pipeline targets and age-based cue support for API targets.

## Development workflow requirements

After any change to the package, re-run:

``` r
devtools::build_readme()
devtools::document()       # Regenerate NAMESPACE and docs from roxygen2 comments
devtools::test()           
devtools::check()
pkgdown::check_pkgdown()
```

## Architecture

All package code lives in `R/functions.R` with three main functions:

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
- **[`create_csv()`](https://economic.github.io/epitargets/reference/create_csv.md)**
  — thin wrapper around `write_csv()` that returns the file path (useful
  as a `targets` format function)

## Dependencies

The code uses functions from `targets` (`tar_target_raw`), `tarchetypes`
(`tar_cue_age_raw`), `readr` (`write_csv`), and `tibble` (`tibble`).
