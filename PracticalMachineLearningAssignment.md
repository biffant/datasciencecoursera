Human Activity Recognition Analysis
===================================

## Loading and preprocessing the data

I decided to use only those features from the training datasets - which have no NAs (all other features have more than 98% of NAs, so usage of them looks useless for our purpose).

```r
download.file("https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv", destfile="pml-training.csv")
```

```r
activity_df <- read.csv("pml-training.csv", stringsAsFactors=FALSE, na.strings=c("", "NA", "#DIV/0!"))

#Take only those features, which has no NAs (all others have >98% of NAs, so looks useless)
activity_df <- subset(activity_df,
                      select=c(classe,gyros_belt_x,gyros_belt_y,gyros_belt_z, total_accel_belt,
                               accel_belt_x,accel_belt_y,accel_belt_z, yaw_belt,
                               magnet_belt_x,magnet_belt_y,magnet_belt_z, pitch_belt,
                               roll_arm,pitch_arm,yaw_arm, roll_belt,
                               gyros_arm_x,gyros_arm_y,gyros_arm_z, new_window,
                               accel_arm_x,accel_arm_y,accel_arm_z, user_name,
                               magnet_arm_x,magnet_arm_y,magnet_arm_z,
                               roll_dumbbell,pitch_dumbbell,yaw_dumbbell,total_accel_dumbbell,
                               gyros_dumbbell_x,gyros_dumbbell_y,gyros_dumbbell_z,
                               accel_dumbbell_x,accel_dumbbell_y,accel_dumbbell_z,
                               magnet_dumbbell_z,magnet_dumbbell_y,magnet_dumbbell_x,
                               roll_forearm,total_accel_forearm,yaw_forearm, pitch_forearm,
                               gyros_forearm_x, gyros_forearm_y, gyros_forearm_z,
                               accel_forearm_x,accel_forearm_y,accel_forearm_z,
                               magnet_forearm_z,magnet_forearm_y,magnet_forearm_x)
                      )

#Make new_window variable numeric
activity_df$new_window <- as.numeric(ifelse(activity_df$new_window == "no", 0, 1))

#Make class variable factor
activity_df$classe = factor(activity_df$classe)

#Make user_name variable numeric
parseUserName <- function(username) {
  switch(username, "carlitos" = 1, "pedro" = 2, "adelmo" = 3, "charles" = 4, "eurico" = 5, "jeremy" = 6)
}
activity_df$user_name <- sapply(activity_df$user_name, FUN = parseUserName, simplify = TRUE)
```

## Training our algorithm

After some experiments with such methods as GBM and svmLinear - I decided to use Random-Forest learning method for this assignment. Simplifying of training (Cross-validation with four Folds) with 50% of samples as training set - gave well performance (5 mins on Intel i5-3570 with 16GB RAM) with very high accuracy (see below).

```r
library(AppliedPredictiveModeling)
library(caret)
```

```
## Loading required package: lattice
## Loading required package: ggplot2
```

```r
inTrain <- createDataPartition(activity_df$classe, p = 1/2)[[1]]

training <- activity_df[ inTrain,]
training_classe <- training$classe
training <- subset(training, select=-c(classe))

testing <- activity_df[-inTrain,]
testing_classe <- testing$classe
testing <- subset(testing, select=-c(classe))

result <- preProcess(training) #, method="pca")
trainData <- predict(result, training)

#Gives 90% on training 1/4, and 80% on test (remaining 3/4 samples)
##modelFit <- train(training_classe ~ ., method = "gbm", data = trainData, metric="Accuracy")

modelFit <- train(training_classe ~ ., method = "rf", data = trainData, metric="Accuracy",
                  trControl = trainControl(method = "cv", number = 4))
```

```
## Loading required package: randomForest
## randomForest 4.6-7
## Type rfNews() to see new features/changes/bug fixes.
```

## Estimating our algorithm

As we can see, training set was predicted with 100% accuracy - so it might be overfitting case...

But, after estimating trained algorithm with remaining 50% of samples - we can see that we're good - accuracy is almost 99%!

Another proof that trained algorithm works fine - 100% passed test-cases from the auto-validated part of this assignment :)



```r
confusionMatrix(training_classe, predict(modelFit, trainData))
```

```
## Confusion Matrix and Statistics
## 
##           Reference
## Prediction    A    B    C    D    E
##          A 2790    0    0    0    0
##          B    0 1899    0    0    0
##          C    0    0 1711    0    0
##          D    0    0    0 1608    0
##          E    0    0    0    0 1804
## 
## Overall Statistics
##                                 
##                Accuracy : 1     
##                  95% CI : (1, 1)
##     No Information Rate : 0.284 
##     P-Value [Acc > NIR] : <2e-16
##                                 
##                   Kappa : 1     
##  Mcnemar's Test P-Value : NA    
## 
## Statistics by Class:
## 
##                      Class: A Class: B Class: C Class: D Class: E
## Sensitivity             1.000    1.000    1.000    1.000    1.000
## Specificity             1.000    1.000    1.000    1.000    1.000
## Pos Pred Value          1.000    1.000    1.000    1.000    1.000
## Neg Pred Value          1.000    1.000    1.000    1.000    1.000
## Prevalence              0.284    0.194    0.174    0.164    0.184
## Detection Rate          0.284    0.194    0.174    0.164    0.184
## Detection Prevalence    0.284    0.194    0.174    0.164    0.184
## Balanced Accuracy       1.000    1.000    1.000    1.000    1.000
```

```r
testData <- predict(result,testing)
confusionMatrix(testing_classe, predict(modelFit, testData))
```

```
## Confusion Matrix and Statistics
## 
##           Reference
## Prediction    A    B    C    D    E
##          A 2785    2    0    0    3
##          B   24 1866    7    1    0
##          C    0   16 1689    6    0
##          D    0    1   34 1570    3
##          E    0    2    3    8 1790
## 
## Overall Statistics
##                                         
##                Accuracy : 0.989         
##                  95% CI : (0.987, 0.991)
##     No Information Rate : 0.286         
##     P-Value [Acc > NIR] : <2e-16        
##                                         
##                   Kappa : 0.986         
##  Mcnemar's Test P-Value : NA            
## 
## Statistics by Class:
## 
##                      Class: A Class: B Class: C Class: D Class: E
## Sensitivity             0.991    0.989    0.975    0.991    0.997
## Specificity             0.999    0.996    0.997    0.995    0.998
## Pos Pred Value          0.998    0.983    0.987    0.976    0.993
## Neg Pred Value          0.997    0.997    0.995    0.998    0.999
## Prevalence              0.286    0.192    0.177    0.162    0.183
## Detection Rate          0.284    0.190    0.172    0.160    0.182
## Detection Prevalence    0.284    0.193    0.174    0.164    0.184
## Balanced Accuracy       0.995    0.992    0.986    0.993    0.998
```
