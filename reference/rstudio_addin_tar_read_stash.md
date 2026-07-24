# RStudio addin to read a target and stash it

Reads the target named under the cursor (or the active selection) and
stashes it via
[`tar_read_stash()`](https://economic.github.io/epitargets/reference/tar_read_stash.md),
leaving a copy in the global environment as `.target`. Bind it to a
keyboard shortcut in the RStudio addin manager or a Positron keybinding,
analogous to
[`targets::rstudio_addin_tar_read()`](https://docs.ropensci.org/targets/reference/rstudio_addin_tar_read.html).

## Usage

``` r
rstudio_addin_tar_read_stash()
```

## Value

The target value, invisibly (also stashed as `.target`).

## Details

The symbol under the cursor is extracted with
[`atcursor::get_word_or_selection()`](https://rdrr.io/pkg/atcursor/man/get_word_or_selection.html),
which works in RStudio, VS Code, and Positron. `atcursor` is an optional
dependency; if it is not installed the addin prompts to install it from
its r-universe repository. If the cursor is on whitespace with no
selection, the addin reports this and does nothing.
