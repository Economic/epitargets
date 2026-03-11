# -- create_csv -----------------------------------------------------------------

test_that("create_csv writes a CSV and returns the file path", {
  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp))

  df <- data.frame(x = 1:3, y = letters[1:3])
  result <- create_csv(df, tmp)

  expect_equal(result, tmp)
  expect_true(file.exists(tmp))

  roundtrip <- readr::read_csv(tmp, show_col_types = FALSE)
  expect_equal(roundtrip$x, 1:3)
  expect_equal(roundtrip$y, letters[1:3])
})

test_that("create_csv returns the path invisibly", {
  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp))

  out <- withVisible(create_csv(data.frame(a = 1), tmp))
  expect_false(out$visible)
})

# -- tar_target_date -----------------------------------------------------------

test_that("tar_target_date returns a list of two targets with correct names", {
  result <- tar_target_date(my_target, 1 + 1)

  expect_type(result, "list")
  expect_length(result, 2)

  main <- result[[1]]
  date <- result[[2]]

  expect_s3_class(main, "tar_stem")
  expect_s3_class(date, "tar_stem")
  expect_equal(main$settings$name, "my_target")
  expect_equal(date$settings$name, "my_target_date")
})

test_that("tar_target_date companion target depends on the main target", {
  result <- tar_target_date(foo, rnorm(5))
  date_cmd_text <- paste(deparse(result[[2]]$command$expr[[1]]), collapse = " ")

  # The date command should reference `foo` via force()

  expect_true(grepl("foo", date_cmd_text, fixed = TRUE))
})

# -- tar_age_date -------------------------------------------------------------------

test_that("tar_age_date returns a list of two targets with correct names", {
  result <- tar_age_date(api_target, paste0("result"))

  expect_type(result, "list")
  expect_length(result, 2)
  expect_equal(result[[1]]$settings$name, "api_target")
  expect_equal(result[[2]]$settings$name, "api_target_date")
})

test_that("tar_age_date main target has an age-based cue", {
  result <- tar_age_date(
    api_target,
    1 + 1,
    age = as.difftime(7, units = "days")
  )
  main <- result[[1]]

  expect_s3_class(main$cue, "tar_cue")
  # tar_cue_age_raw sets mode to "always"
  expect_equal(main$cue$mode, "always")
})

# -- collect_target_date -------------------------------------------------------

test_that("collect_target_date returns a tibble with name and time columns", {
  # collect_target_date expects bare symbols (as used in a targets pipeline),

  # so we assign variables and pass them unquoted
  x_date <- as.Date("2024-01-01")
  y_date <- as.Date("2024-06-15")
  result <- collect_target_date(x_date, y_date)

  expect_s3_class(result, "tbl_df")
  expect_named(result, c("name", "time"))
  expect_equal(result$name, c("x", "y"))
  expect_equal(result$time, c(x_date, y_date))
})

test_that("collect_target_date strips _date suffix from names", {
  alpha_date <- as.Date("2024-01-01")
  result <- collect_target_date(alpha_date)
  expect_equal(result$name, "alpha")
})

test_that("collect_target_date works with a single target", {
  only_date <- as.Date("2025-03-04")
  result <- collect_target_date(only_date)

  expect_equal(nrow(result), 1)
  expect_equal(result$name, "only")
  expect_equal(result$time, only_date)
})
