# LearnerRegrQuantregForest

An R package that makes `quantregForest` available as a regression learner
in `mlr3`. I created this interface for TP9 of the large-scale machine
learning course.

The learner predicts a numeric target using a random forest. This first
version returns the estimated conditional mean. The underlying
`quantregForest` package also supports quantiles, but these are not exposed
by this interface yet.

## Installation

Download the package folder and open R in the directory containing its
`DESCRIPTION` file. Then run:

```r
# Install the helper package once.
install.packages("remotes")

# Install this package and its required dependencies.
remotes::install_local(".", dependencies = NA, upgrade = "never")
```

After installation, load the package with:

```r
library(LearnerRegrQuantregForest)
```

## Usage

This example uses `mtcars`, a regression task available through
`mlr3::tsk()`. The goal is to predict fuel economy (`mpg`) from the other
car characteristics.

```r
library(LearnerRegrQuantregForest)

# Load the task and separate training and test observations.
task <- mlr3::tsk("mtcars")
set.seed(42)
train_ids <- sample(task$row_ids, size = 24L)
test_ids <- setdiff(task$row_ids, train_ids)

# Create the learner and choose the number of trees.
learner <- LearnerRegrQuantregForest$new()
learner$param_set$values <- list(ntree = 100L)

# Train on 24 observations and predict on the remaining 8.
learner$train(task, row_ids = train_ids)
prediction <- learner$predict(task, row_ids = test_ids)

# Compare observed and predicted values.
data.frame(
  observed = prediction$truth,
  predicted = prediction$response
)

# Compute mean squared error: lower is better.
prediction$score(mlr3::msr("regr.mse"))
```

The `ntree` hyperparameter controls the number of trees. It must be an
integer greater than or equal to 1. If it is not set, the default is 500.

The current learner accepts integer and numeric features without missing
values. It is designed for regression, so the target must be numeric.
The train/test split above is a small usage example; cross-validation
is more useful for comparing learners.

To open the full documentation:

```r
help("LearnerRegrQuantregForest", package = "LearnerRegrQuantregForest")
```

## Related work

- [Course project wiki](https://github.com/tdhock/2026-01-aa-grande-echelle/wiki/projets):
  the course page for the projects, including the context for this work.
- [quantregForest](https://github.com/cran/quantregForest):
  the package that implements the forest. Training uses
  `quantregForest::quantregForest()`. Prediction uses `stats::predict()`,
  which dispatches to its prediction method, with `what = mean`.
- [mlr3](https://github.com/mlr-org/mlr3):
  the framework used for tasks, learners, resampling, and benchmarks.
- [mlr3extralearners](https://github.com/mlr-org/mlr3extralearners):
  a collection of additional learners for mlr3. This project prepares an
  interface for a possible contribution.
