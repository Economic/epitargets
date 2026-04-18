# Read a Parquet file as a target

A convenience wrapper around
[`tarchetypes::tar_file_read()`](https://docs.ropensci.org/tarchetypes/reference/tar_file_read.html)
for Parquet files. Creates a pair of targets: one to track the file with
`format = "file"`, and another to read the file with
[`arrow::read_parquet()`](https://arrow.apache.org/docs/r/reference/read_parquet.html).

## Usage

``` r
tar_parquet_read(name, command, .read_parquet_args, ...)
```

## Arguments

- name:

  Symbol, name of the target.

- command:

  Expression, R code that returns the file path to the Parquet file.

- .read_parquet_args:

  A named list of additional arguments passed to
  [`arrow::read_parquet()`](https://arrow.apache.org/docs/r/reference/read_parquet.html).

- ...:

  Additional arguments passed to
  [`targets::tar_target_raw()`](https://docs.ropensci.org/targets/reference/tar_target.html)
  for the read target.

## Value

A list of two target objects: a file-tracking target (`name_file`) and a
Parquet-reading target (`name`).

## Examples

``` r
if (identical(Sys.getenv("TAR_EXAMPLES"), "true")) {
targets::tar_dir({
  targets::tar_script({
    library(targets)
    list(
      epitargets::tar_parquet_read(my_data, "data.parquet")
    )
  })
  targets::tar_manifest()
})
}
```
