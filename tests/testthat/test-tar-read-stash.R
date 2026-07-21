# -- tar_read_stash ------------------------------------------------------------

# tar_read_stash() warns when run non-interactively (as in tests), so most
# assertions wrap the call in suppressWarnings() and stash into a throwaway
# environment rather than the global environment.

make_store <- function(env) {
  # Build a minimal targets pipeline in a temp dir and return its store path.
  dir <- withr::local_tempdir(.local_envir = env)
  script <- file.path(dir, "_targets.R")
  store <- file.path(dir, "_targets")
  targets::tar_script(
    list(targets::tar_target(my_data, data.frame(x = 1:3, y = letters[1:3]))),
    script = script
  )
  targets::tar_make(script = script, store = store, reporter = "silent")
  store
}

test_that("tar_read_stash reads a target and assigns it to the stash name", {
  store <- make_store(environment())
  stash <- new.env()

  out <- suppressWarnings(
    tar_read_stash(my_data, envir = stash, store = store, print_value = FALSE)
  )

  expect_s3_class(out, "data.frame")
  expect_equal(out$x, 1:3)
  expect_true(exists(".target", envir = stash, inherits = FALSE))
  expect_equal(get(".target", envir = stash), out)
})

test_that("tar_read_stash accepts a string name and a custom stash_name", {
  store <- make_store(environment())
  stash <- new.env()

  out <- suppressWarnings(
    tar_read_stash(
      "my_data",
      stash_name = ".scratch",
      envir = stash,
      store = store,
      print_value = FALSE
    )
  )

  expect_equal(get(".scratch", envir = stash), out)
})

test_that("tar_read_stash returns the value invisibly", {
  store <- make_store(environment())
  stash <- new.env()

  res <- withVisible(suppressWarnings(
    tar_read_stash(my_data, envir = stash, store = store, print_value = FALSE)
  ))
  expect_false(res$visible)
})

test_that("tar_read_stash silently overwrites an existing stash slot", {
  store <- make_store(environment())
  stash <- new.env()
  assign(".target", "stale", envir = stash)

  suppressWarnings(
    tar_read_stash(my_data, envir = stash, store = store, print_value = FALSE)
  )

  expect_s3_class(get(".target", envir = stash), "data.frame")
})

test_that("tar_read_stash warns in a non-interactive context but still stashes", {
  store <- make_store(environment())
  stash <- new.env()

  expect_warning(
    tar_read_stash(my_data, envir = stash, store = store, print_value = FALSE),
    "non-interactive"
  )
  expect_true(exists(".target", envir = stash, inherits = FALSE))
})

test_that("tar_read_stash prints the value when print_value = TRUE", {
  store <- make_store(environment())
  stash <- new.env()

  expect_output(
    suppressWarnings(
      tar_read_stash(my_data, envir = stash, store = store, print_value = TRUE)
    )
  )
})
