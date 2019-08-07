# Random Forest Model Run
library(ROCR)
library(randomForest)
library(caTools)
library(tidyverse)
library(ROSE)


model_df_trim <- model_df %>%
  select(-c(Shipped_Dt, Order_Dt, Delivery_Confirmation_Dt, Sales_Order_Nbr, Package_Id,
            Product_Id, Source_Ship_Warehouse_Nbr, zip_dest, Party_Id, city_distctr, 
            city_dest, zip_distctr, fips_dest, lat_distctr, lon_distctr))

model_df_trim$Rescheduled <- as.factor(model_df_trim$Rescheduled) 
model_df_trim$Party_Id <- NULL


sample = sample.split(model_df_trim$Repeat, SplitRatio = .70)
df.train = subset(model_df_trim, sample == TRUE)
df.test = subset(model_df_trim, sample == FALSE)


rf <- randomForest(as.factor(Repeat)~., data=df.train, importance=TRUE, ntree=1000, do.trace = 50)
varImpPlot(rf)


mtry <- tuneRF(df.train[-15], as.factor(df.train$Repeat), ntreeTry=1000,
               stepFactor=0.5, improve=0.01, trace=TRUE, plot=TRUE, do.trace = TRUE)
best.m <- mtry[mtry[, 2] == min(mtry[, 2]), 1]


rf_tuned <- randomForest(as.factor(Repeat)~., data=df.train, mtry=best.m,
                   importance=TRUE, ntree=1000, do.trace = 50)
varImpPlot(rf_tuned)


pred = predict(rf_tuned, df.test)
print(table(pred, df.test$Repeat))

roc.curve(df.test$Repeat, pred, plotit = TRUE,add =TRUE)


perf <- performance(pred, "tpr", "fpr")
plot(perf)
abline(a=0,b=1)

