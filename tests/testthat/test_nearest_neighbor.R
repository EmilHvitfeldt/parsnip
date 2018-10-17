library(testthat)
library(parsnip)
library(rlang)

# ------------------------------------------------------------------------------

context("nearest neighbor")
source("helpers.R")

# ------------------------------------------------------------------------------

test_that('primary arguments', {
  basic <- nearest_neighbor()
  basic_kknn <- translate(basic, engine = "kknn")

  expect_equal(
    object = basic_kknn$method$fit$args,
    expected = list(
      formula = expr(missing_arg()),
      data = expr(missing_arg()),
      kmax = expr(missing_arg())
    )
  )

  neighbors <- nearest_neighbor(neighbors = 5)
  neighbors_kknn <- translate(neighbors, engine = "kknn")

  expect_equal(
    object = neighbors_kknn$method$fit$args,
    expected = list(
      formula = expr(missing_arg()),
      data = expr(missing_arg()),
      kmax = expr(missing_arg()),
      ks = new_empty_quosure(5)
    )
  )

  weight_func <- nearest_neighbor(weight_func = "triangular")
  weight_func_kknn <- translate(weight_func, engine = "kknn")

  expect_equal(
    object = weight_func_kknn$method$fit$args,
    expected = list(
      formula = expr(missing_arg()),
      data = expr(missing_arg()),
      kmax = expr(missing_arg()),
      kernel = new_empty_quosure("triangular")
    )
  )

  dist_power <- nearest_neighbor(dist_power = 2)
  dist_power_kknn <- translate(dist_power, engine = "kknn")

  expect_equal(
    object = dist_power_kknn$method$fit$args,
    expected = list(
      formula = expr(missing_arg()),
      data = expr(missing_arg()),
      kmax = expr(missing_arg()),
      distance = new_empty_quosure(2)
    )
  )

})

test_that('engine arguments', {

  kknn_scale <- nearest_neighbor(scale = FALSE)

  expect_equal(
    object = translate(kknn_scale, "kknn")$method$fit$args,
    expected = list(
      formula = expr(missing_arg()),
      data = expr(missing_arg()),
      kmax = expr(missing_arg()),
      scale = new_empty_quosure(FALSE)
    )
  )

})


test_that('updating', {

  expr1     <- nearest_neighbor(               scale = FALSE)
  expr1_exp <- nearest_neighbor(neighbors = 5, scale = FALSE)

  expr2     <- nearest_neighbor(neighbors = varying())
  expr2_exp <- nearest_neighbor(neighbors = varying(), weight_func = "triangular")

  expr3     <- nearest_neighbor(neighbors = 2, weight_func = varying())
  expr3_exp <- nearest_neighbor(neighbors = 3)

  expr4     <- nearest_neighbor(neighbors = 1, scale = TRUE)
  expr4_exp <- nearest_neighbor(neighbors = 1, scale = TRUE, ykernel = 2)

  expect_equal(update(expr1, neighbors = 5), expr1_exp)
  expect_equal(update(expr2, weight_func = "triangular"), expr2_exp)
  expect_equal(update(expr3, neighbors = 3, fresh = TRUE), expr3_exp)
  expect_equal(update(expr4, ykernel = 2), expr4_exp)

})

test_that('bad input', {
  # expect_error(nearest_neighbor(eighbor = 7))
  expect_error(nearest_neighbor(mode = "reallyunknown"))
  # expect_error(nearest_neighbor(neighbors = -5))
  # expect_error(nearest_neighbor(neighbors = 5.5))
  # expect_error(nearest_neighbor(neighbors = c(5.5, 6)))
  expect_warning(translate(nearest_neighbor(), engine = NULL))
})