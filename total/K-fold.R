setwd("~/Documents/Repertory/Advanced CS Experiment/DMonPacing/total")
require(caret)
require(MASS)
dat <- read.csv("dynamic_parameter.csv", header = FALSE)

folds<-createFolds(dat$V1,k=5)

for(i in 1:5){

  train<-dat[-folds[[i]],]
  test<-dat[folds[[i]],]
  
  train_Gait_data <- train[, 1:36]
  train_Gait_label <- train[,39]
  (lda.sol = lda(train_Gait_data, train_Gait_label))
  
  p_Gait_data <- test[, 1:36]
  p_Gait_label <- test[,39]
  p = predict(lda.sol, p_Gait_data)
  print(table(p_Gait_label, p$class))
}
#qplot(p$x[,"LD1"], p$x[,"LD2"], color = p$class, xlab = "LD1", ylab = "LD2")