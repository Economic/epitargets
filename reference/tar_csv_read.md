# Read a CSV file as a target

A convenience wrapper around
[`tarchetypes::tar_file_read()`](https://docs.ropensci.org/tarchetypes/reference/tar_file_read.html)
for CSV files. Creates a pair of targets: one to track the file with
`format = "file"`, and another to read the file with
[`readr::read_csv()`](https://readr.tidyverse.org/reference/read_delim.html).

## Usage

``` r
tar_csv_read(name, command, .readr_args = list(show_col_types = FALSE), ...)
```

## Arguments

- name:

  Symbol, name of the target.

- command:

  Expression, R code that returns the file path to the CSV.

- .readr_args:

  A named list of additional arguments passed to
  [`readr::read_csv()`](https://readr.tidyverse.org/reference/read_delim.html).
  Defaults to `list(show_col_types = FALSE)`. Supplying this argument
  replaces the defaults entirely.

- ...:

  Additional arguments passed to
  [`targets::tar_target_raw()`](https://docs.ropensci.org/targets/reference/tar_target.html)
  for the read target.

## Value

A list of two target objects: a file-tracking target (`name_file`) and a
CSV-reading target (`name`).

## Examples

``` r
if (identical(Sys.getenv("TAR_EXAMPLES"), "true")) {
targets::tar_dir({
  targets::tar_script({
    library(targets)
    list(
      epitargets::tar_csv_read(my_data, "data.csv")
    )
  })
  targets::tar_manifest()
})
}
```
