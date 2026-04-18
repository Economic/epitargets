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

# -- tar_csv_read --------------------------------------------------------------

test_that("tar_csv_read returns a file target and a read target with correct names", {
  result <- tar_csv_read(my_data, "data.csv")

  expect_type(result, "list")
  expect_length(result, 2)
  expect_equal(result[[1]]$settings$name, "my_data_file")
  expect_equal(result[[1]]$settings$format, "file")
  expect_equal(result[[2]]$settings$name, "my_data")
})

test_that("tar_csv_read builds a readr::read_csv call referencing the file target", {
  result <- tar_csv_read(my_data, "data.csv")
  read_expr <- result[[2]]$command$expr[[1]]

  expect_equal(read_expr[[1]], quote(readr::read_csv))
  expect_equal(read_expr$file, quote(my_data_file))
  expect_equal(read_expr$show_col_types, FALSE)
})

test_that("tar_csv_read .read_csv_args overrides defaults", {
  result <- tar_csv_read(
    my_data,
    "data.csv",
    .read_csv_args = list(col_types = "ii", skip = 1)
  )
  read_expr <- result[[2]]$command$expr[[1]]

  expect_equal(read_expr$col_types, "ii")
  expect_equal(read_expr$skip, 1)
  expect_null(read_expr$show_col_types)
})

test_that("tar_csv_read actually reads a CSV file end-to-end", {
  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp))
  df <- data.frame(x = 1:3, y = letters[1:3])
  readr::write_csv(df, tmp)

  result <- eval(bquote(tar_csv_read(my_data, .(tmp))))
  my_data_file <- eval(result[[1]]$command$expr[[1]])
  read_expr <- result[[2]]$command$expr[[1]]
  out <- eval(read_expr)

  expect_s3_class(out, "tbl_df")
  expect_equal(out$x, 1:3)
  expect_equal(out$y, letters[1:3])
})

# -- tar_parquet_read ----------------------------------------------------------

test_that("tar_parquet_read returns a file target and a read target with correct names", {
  result <- tar_parquet_read(my_data, "data.parquet")

  expect_type(result, "list")
  expect_length(result, 2)
  expect_equal(result[[1]]$settings$name, "my_data_file")
  expect_equal(result[[1]]$settings$format, "file")
  expect_equal(result[[2]]$settings$name, "my_data")
})

test_that("tar_parquet_read builds an arrow::read_parquet call referencing the file target", {
  result <- tar_parquet_read(my_data, "data.parquet")
  read_expr <- result[[2]]$command$expr[[1]]

  expect_equal(read_expr[[1]], quote(arrow::read_parquet))
  expect_equal(read_expr$file, quote(my_data_file))
})

test_that("tar_parquet_read .read_parquet_args are passed through", {
  result <- tar_parquet_read(
    my_data,
    "data.parquet",
    .read_parquet_args = list(col_select = "x")
  )
  read_expr <- result[[2]]$command$expr[[1]]

  expect_equal(read_expr$col_select, "x")
})

test_that("tar_parquet_read actually reads a Parquet file end-to-end", {
  tmp <- tempfile(fileext = ".parquet")
  on.exit(unlink(tmp))
  df <- data.frame(x = 1:3, y = letters[1:3])
  arrow::write_parquet(df, tmp)

  result <- eval(bquote(tar_parquet_read(my_data, .(tmp))))
  my_data_file <- eval(result[[1]]$command$expr[[1]])
  read_expr <- result[[2]]$command$expr[[1]]
  out <- eval(read_expr)

  expect_equal(out$x, 1:3)
  expect_equal(out$y, letters[1:3])
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
