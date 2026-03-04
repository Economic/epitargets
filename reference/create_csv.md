# Write data to a CSV file and return the file path

A thin wrapper around
[`readr::write_csv()`](https://readr.tidyverse.org/reference/write_delim.html)
that writes `data` to `file` and returns the file path. This is useful
as a targets format function where the target value should be the path
to the written file.

## Usage

``` r
create_csv(data, file, ...)
```

## Arguments

- data:

  A data frame to write.

- file:

  A string giving the file path to write to.

- ...:

  Additional arguments passed to
  [`readr::write_csv()`](https://readr.tidyverse.org/reference/write_delim.html).

## Value

The file path `file`, invisibly.

## Examples

``` r
targets::tar_dir({
  create_csv(data.frame(x = 1:3), "test.csv")
})
```
