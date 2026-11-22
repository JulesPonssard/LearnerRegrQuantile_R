# Start with initialize(), then .train(), and finally .predict().
#' Quantile Regression Forest Learner
#' @description
#' Regression learner using the quantregForest package.
#' Returns the estimated conditional mean as the response prediction.
#'
#' @export
LearnerRegrQuantregForest <- R6::R6Class(
  classname = "LearnerRegrQuantregForest",

  inherit = mlr3::LearnerRegr,

  public = list(
    initialize = function() {
      param_set <- paradox::ps(
        ntree = paradox::p_int(1, default = 500, tags = "train")
      )

      super$initialize(
        id = "regr.quantregForest",
        param_set = param_set,
        predict_types = "response",
        feature_types = c("integer", "numeric"),
        properties = character(),
        packages = "quantregForest",
        label = "Quantile Regression Forest",
        man = "LearnerRegrQuantregForest::LearnerRegrQuantregForest"
      )
    }
  ),

  private = list(
    .train = function(task) {
      x <- task$data(cols = task$feature_names)
      y <- task$truth()
      train_params <- self$param_set$get_values(tags = "train")
      do.call(quantregForest::quantregForest, c(list(x = as.data.frame(x), y = y), train_params))
    },

    .predict = function(task) {
      newdata <- task$data(cols = task$feature_names)
      response <- stats::predict(self$model, newdata = as.data.frame(newdata), what = mean)
      list(response = response)
    }
  )
)
