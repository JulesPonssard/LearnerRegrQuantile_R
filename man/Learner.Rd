\name{LearnerRegrQuantregForest}
\alias{LearnerRegrQuantregForest}
\alias{Learner}
\title{Quantile Regression Forest Learner}
\description{
An interface between \pkg{mlr3} and \pkg{quantregForest}.
This learner predicts a numeric target from integer or numeric features.
It returns the estimated conditional mean, so it can be compared with
other regression learners using mean squared error (MSE).
}
\details{
Training calls \code{quantregForest::quantregForest()}.
Prediction calls \code{stats::predict()} on the fitted model with
\code{what = mean}. Although the underlying package can predict quantiles,
this interface currently returns only a response prediction, not quantiles
or prediction intervals.

Missing values are not supported. The target must be numeric and must not
also be included among the features.
}
\section{Creating the learner}{
Use \code{LearnerRegrQuantregForest$new()} to create an instance.
The learner inherits from \code{mlr3::LearnerRegr}.
Its default ID is \code{regr.quantregForest}, and its prediction type
is \code{response}.
}
\section{Hyperparameter}{
\describe{
  \item{\code{ntree}}{
    Number of trees in the forest. It must be an integer greater than or
    equal to 1. The default is 500. More trees usually give more stable
    predictions, but take longer to train.
    Set it with \code{learner$param_set$values <- list(ntree = 100L)}.
    If it is not set, the underlying package uses its default.
  }
}
}
\section{Training and prediction}{
\describe{
  \item{\code{learner$train(task, row_ids = train_ids)}}{
    Fits the model using the selected training rows of a regression task.
    The fitted forest is stored in \code{learner$model}.
  }
  \item{\code{learner$predict(task, row_ids = test_ids)}}{
    Predicts the target for the selected test rows.
    Returns an \code{mlr3::PredictionRegr} object.
    Its \code{response} field contains one numeric prediction per row.
  }
}
}
\examples{
# Use a built-in regression task.
task <- mlr3::tsk("mtcars")

# Keep different observations for training and testing.
set.seed(42)
train_ids <- sample(task$row_ids, size = 24L)
test_ids <- setdiff(task$row_ids, train_ids)

learner <- LearnerRegrQuantregForest$new()
learner$param_set$values <- list(ntree = 100L)

learner$train(task, row_ids = train_ids)
prediction <- learner$predict(task, row_ids = test_ids)

# Inspect predictions and compute test MSE.
prediction$response
prediction$score(mlr3::msr("regr.mse"))
}
\seealso{
\code{\link[quantregForest:quantregForest]{quantregForest}},
\code{\link[mlr3:LearnerRegr]{LearnerRegr}}
}
