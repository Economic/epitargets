# Collect date targets into a tibble

Gathers the values of companion `_date` targets (created by
[`tar_target_date()`](https://economic.github.io/epitargets/reference/tar_target_date.md)
or
[`tar_age_date()`](https://economic.github.io/epitargets/reference/tar_age_date.md))
into a
[tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
with columns `name` and `time`.

## Usage

``` r
collect_target_date(...)
```

## Arguments

- ...:

  Date values from `_date` targets. Pass each `_date` target by name
  (e.g., `x_date, y_date`).

## Value

A [tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
with columns `name` (character) and `time`.

## Examples

``` r
collect_target_date(x_date = as.Date("2024-01-01"), y_date = as.Date("2024-06-15"))
#> # A tibble: 2 × 2
#>   name                      time      
#>   <chr>                     <date>    
#> 1 "as.Date(\"2024-01-01\")" 2024-01-01
#> 2 "as.Date(\"2024-06-15\")" 2024-06-15
```
