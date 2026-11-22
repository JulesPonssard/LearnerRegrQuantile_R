testthat::test_that("the learner trains and returns the expected mean predictions", {
  # Arrange: use separate observations for training and prediction
  task <- mlr3::tsk("mtcars")
  train_ids <- task$row_ids[1:24]
  test_ids <- task$row_ids[25:32]

  learner <- LearnerRegrQuantregForest$new()
  learner$param_set$values <- list(ntree = 50L)

  # Act: train the forest, then predict on held-out observations
  set.seed(42)
  learner$train(task, row_ids = train_ids)
  prediction <- learner$predict(task, row_ids = test_ids)

  # Assert: the model was trained and the hyperparameter was forwarded.
  testthat::expect_s3_class(learner$model, "quantregForest")
  testthat::expect_equal(learner$model$ntree, 50L)

  # Assert: one finite numeric response is returned per test observation.
  testthat::expect_s3_class(prediction, "PredictionRegr")
  testthat::expect_equal(prediction$row_ids, test_ids)
  testthat::expect_type(prediction$response, "double")
  testthat::expect_length(prediction$response, length(test_ids))
  testthat::expect_true(all(is.finite(prediction$response)))

  # Assert: the wrapper agrees with a direct prediction from the same model.
  # Reusing the fitted model avoids differences from fitting random forests twice.
  newdata <- task$data(
    rows = prediction$row_ids,
    cols = task$feature_names
  )
  expected <- stats::predict(
    learner$model,
    newdata = as.data.frame(newdata),
    what = mean
  )
  testthat::expect_equal(
    unname(prediction$response),
    unname(as.numeric(expected))
  )
})
