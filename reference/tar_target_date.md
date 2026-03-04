# Create a target with a companion date target

Wraps
[`targets::tar_target_raw()`](https://docs.ropensci.org/targets/reference/tar_target.html)
to create a primary target and a companion `_date` target that records
[`Sys.Date()`](https://rdrr.io/r/base/Sys.time.html) whenever the
primary target runs.

## Usage

``` r
tar_target_date(name, command, ...)
```

## Arguments

- name:

  Symbol, name of the target.

- command:

  Expression, R command to run the target.

- ...:

  Additional arguments passed to
  [`targets::tar_target_raw()`](https://docs.ropensci.org/targets/reference/tar_target.html).

## Value

A list of two target objects: the primary target and the companion
`_date` target.

## Examples

``` r
if (identical(Sys.getenv("TAR_EXAMPLES"), "true")) {
targets::tar_dir({
  targets::tar_script({
    library(targets)
    list(
      epitargets::tar_target_date(x, 1 + 1)
    )
  })
  targets::tar_make()
  targets::tar_read(x)
  targets::tar_read(x_date)
})
}
```
