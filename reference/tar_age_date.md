# Create an age-cued target with a companion date target

Like
[`tar_target_date()`](https://economic.github.io/epitargets/reference/tar_target_date.md)
but adds an age-based cue via
[`tarchetypes::tar_cue_age_raw()`](https://docs.ropensci.org/tarchetypes/reference/tar_cue_age.html)
so the target automatically re-runs after a configurable time period.
Useful for targets that fetch data from APIs.

## Usage

``` r
tar_age_date(name, command, age = as.difftime(1, units = "days"), ...)
```

## Arguments

- name:

  Symbol, name of the target.

- command:

  Expression, R command to run the target.

- age:

  A [difftime](https://rdrr.io/r/base/difftime.html) object specifying
  the maximum age before the target re-runs. Defaults to 1 day.

- ...:

  Additional arguments passed to
  [`targets::tar_target_raw()`](https://docs.ropensci.org/targets/reference/tar_target.html).

## Value

A list of two target objects: the primary target (with an age cue) and
the companion `_date` target.

## Examples

``` r
if (identical(Sys.getenv("TAR_EXAMPLES"), "true")) {
targets::tar_dir({
  targets::tar_script({
    library(targets)
    list(
      epitargets::tar_age_date(x, 1 + 1, age = as.difftime(1, units = "days"))
    )
  })
  targets::tar_make()
  targets::tar_read(x)
  targets::tar_read(x_date)
})
}
```
