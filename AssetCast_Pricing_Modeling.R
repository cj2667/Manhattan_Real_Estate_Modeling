library(caret)
library(ISLR)
library(pls)


data <- read.csv("data_for_modeling_v2.csv")
filtered_data <- subset(data, select = -c(X, id, sold_year, heating, cooling,
                                          flooring, appliances, most_recent_listing_date,
                                          most_recent_listing_price, sold_time, listing_sold_time_diff,
                                          price_percent_change))


# Get training set and test set
set.seed(33)
train_size <- floor(0.75 * nrow(filtered_data))
train <- sample(1:nrow(filtered_data), train_size)

#################################
# Leap Forward Subset Selection #
model_matrix <- model.matrix(price ~ ., data = filtered_data[-train, ])
set.seed(33)
train_control <- trainControl(method = "cv")
caret_forward_stepwise = train(form = price ~ .,
                          data = filtered_data,
                          subset = train,
                          method = 'leapForward',
                          tuneGrid = data.frame(nvmax = 25),
                          trControl = train_control)
forward_stepwise = caret_forward_stepwise$finalModel
summary(forward_stepwise)

# Find the best subset size
mse_validation <- rep(0, 23)
for (t in 1:23)
{
  coefs <- coef(forward_stepwise, t)
  preds <- model_matrix[ , names(coefs)] %*% coefs
  mse_validation[t] <- mean( (filtered_data$price[-train] - preds)^2 )
}

best_size <- which(mse_validation == min(mse_validation))
best_size

coef(forward_stepwise, best_size)
intercept <- as.double(coef(forward_stepwise, best_size)[1])
ba <- as.double(coef(forward_stepwise, best_size)[2])
building_age <- as.double(coef(forward_stepwise, best_size)[3])

# Calculate RMSE
preds_forward_stepwise <- intercept + ba * filtered_data$ba[-train] + building_age * filtered_data$building_age[-train]
rmse_forward_stepwise <- mean( (preds_forward_stepwise - filtered_data$price[-train])**2 )**0.5
rmse_forward_stepwise
summary(filtered_data)


##############################
# Ridge Regression Selection #
grid = 10^seq(10,-5,length=100)
set.seed(33)
train_control = trainControl(method = "cv")
caret_model_l2_cv = train(price ~ .,
                          data = data,
                          subset = train,
                          method = "glmnet",
                          lambda = grid,
                          tuneGrid = data.frame(alpha = 0, lambda = grid),
                          trControl = train_control)
# Get best Lambda
best_lambda = caret_model_l2_cv$bestTune$lambda
best_lambda

# Train again using the best Lambda found
caret_model_l2 = train(price ~ .,
                       data = data,
                       subset = train,
                       method = "glmnet",
                       lambda = best_lambda,
                       tuneGrid = data.frame(alpha = 0, lambda = best_lambda))
model_l2 = caret_model_l2$finalModel

# Observe the coefficients
coef(model_l2)[2:30]

# Predict on test set
y_pred_l2 = predict(caret_model_l2, data[-train,])

# Calculate RMSE
RMSE_l2 = mean( (y_pred_l2 - data$price[-train])**2 )**0.5
RMSE_l2


####################################
# Partial Least Squares Regression #
set.seed(33)
train_control = trainControl(method = "cv")
caret_pls.fit_cv = train(price ~.,
                         data = Hitters.clean,
                         subset = train,
                         method = "pls",
                         preProcess = c("center", "scale"),
                         tuneGrid = data.frame(ncomp = 1:(ncol(Hitters.clean-1))),
                         trControl = train_control)
pls.fit_cv = caret_pls.fit_cv$finalModel
summary(pcr.fit)

