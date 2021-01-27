data <- read.csv("data_for_modeling_v4.csv")

boxplot(data$sqft, main="Sqrt")
boxplot(data$sold_price, main="Sold Price")

summary(data$sqft)
summary(data$sold_price)
