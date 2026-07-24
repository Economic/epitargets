# Read a target and stash it in an environment

Reads a target with
[`targets::tar_read()`](https://docs.ropensci.org/targets/reference/tar_read.html)
and, in addition to returning it, assigns a copy into `envir` under a
fixed scratch name (`.target` by default). This lets you keep a handle
to the value for interactive exploration without re-running the read. It
is the engine behind the
[`rstudio_addin_tar_read_stash()`](https://economic.github.io/epitargets/reference/rstudio_addin_tar_read_stash.md)
addin.

## Usage

``` r
tar_read_stash(
  name,
  stash_name = ".target",
  print_value = TRUE,
  envir = globalenv(),
  store = targets::tar_config_get("store"),
  ...
)
```

## Arguments

- name:

  Symbol or string, the target to read. NSE-friendly, matching
  [`targets::tar_read()`](https://docs.ropensci.org/targets/reference/tar_read.html).

- stash_name:

  String, the variable name to assign the value to in `envir`. Defaults
  to `".target"`, a leading-dot scratch slot. If it already exists in
  `envir` it is silently overwritten.

- print_value:

  Logical. If `TRUE` (default), the value is printed after assignment so
  the addin behaves like the stock `tar_read` addin.

- envir:

  Environment to stash the value into. Defaults to
  [`globalenv()`](https://rdrr.io/r/base/environment.html).

- store:

  Character, the targets data store. Passed through to
  [`targets::tar_read_raw()`](https://docs.ropensci.org/targets/reference/tar_read.html).

- ...:

  Additional arguments passed to
  [`targets::tar_read_raw()`](https://docs.ropensci.org/targets/reference/tar_read.html)
  (e.g. `branches`).

## Value

The target value, invisibly.

## Details

A resolved character target name is passed to
[`targets::tar_read_raw()`](https://docs.ropensci.org/targets/reference/tar_read.html)
rather than
[`targets::tar_read()`](https://docs.ropensci.org/targets/reference/tar_read.html),
because the latter uses non-standard evaluation and would otherwise look
up a target named after the variable rather than its value.

When called from a non-interactive context (a script or pipeline), a
warning is emitted but the value is still stashed.

## Examples

``` r
if (identical(Sys.getenv("TAR_EXAMPLES"), "true")) {
targets::tar_dir({
  targets::tar_script({
    library(targets)
    list(
      targets::tar_target(x, 1 + 1)
    )
  })
  targets::tar_make()
  tar_read_stash(x)
  .target
})
}
```
