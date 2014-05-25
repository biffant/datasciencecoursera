library(reshape2)

#load test data
test_measures <- read.table("test/X_test.txt", header = FALSE)
test_subjects <- read.table("test/subject_test.txt", header = FALSE)
test_activities <- read.table("test/y_test.txt", header = FALSE)

#load train data
train_measures <- read.table("train/X_train.txt", header = FALSE)
train_subjects <- read.table("train/subject_train.txt", header = FALSE)
train_activities <- read.table("train/y_train.txt", header = FALSE)

#merge test & train data
measures_df <- rbind(test_measures, train_measures)
subjects_df <- rbind(test_subjects, train_subjects)
activities_df <- rbind(test_activities, train_activities)

#indexes of 33 features of mean & more 33 of stdev for measurements
mean_stddev_features_indexes = c(1:6,41:46,81:86,121:126,161:166,201:202,214:215,227:228,240:241,253:254,266:271,345:350,424:429,503:504,516:517,529:530,542:543)

#leave required mean/stddev features only in test dataset
measures_df <- subset(measures_df, select = mean_stddev_features_indexes)

#get descriptive activity names
activity_labels <- read.table("activity_labels.txt")

#add column with activity descriptive labels
activities_df[,2] <- activity_labels[activities_df[,1],2]

#remove activity IDs
activities_df = subset(activities_df, select = c(2))

#merge all data into a single dataframe
merged_df <- cbind(subjects_df, activities_df, measures_df)

#set column names in merged data frame
colnames(merged_df)[1] <- "subject"
colnames(merged_df)[2] <- "activity"

#prepare new dataframe of average values for each activity/subject
melted_df <- melt(merged_df, id=c("subject","activity"))
result_df <- dcast(melted_df, subject + activity ~ variable, fun.aggregate=mean)

#write result to a file
write.table(result_df, file="analysis_result.txt")
