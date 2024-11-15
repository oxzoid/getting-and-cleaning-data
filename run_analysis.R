library(dplyr)

if (!file.exists("./data")) {
  dir.create("./data")
}
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, destfile = "./data/dataset.zip")
unzip("./data/dataset.zip", exdir = "./data")

# Read features and activity labels
features <- read.table("./data/UCI HAR Dataset/features.txt", col.names = c("n", "functions"))
activities <- read.table("./data/UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))

# Read training data
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
x_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt", col.names = "code")

# Read test data
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
x_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt", col.names = "code")

# Combine datasets
subject <- rbind(subject_train, subject_test)
x_data <- rbind(x_train, x_test)
y_data <- rbind(y_train, y_test)

# Merge all data into one dataset
merged_data <- cbind(subject, y_data, x_data)
merged_data
tidy_data <- merged_data %>%
  select(subject, code, contains("mean"), contains("std"))

tidy_data$code <- activities[tidy_data$code, 2]
names(tidy_data)[2] <- "activity"

names(tidy_data) <- gsub("^t", "Time", names(tidy_data))
names(tidy_data) <- gsub("^f", "Frequency", names(tidy_data))
names(tidy_data) <- gsub("Acc", "Accelerometer", names(tidy_data))
names(tidy_data) <- gsub("Gyro", "Gyroscope", names(tidy_data))
names(tidy_data) <- gsub("Mag", "Magnitude", names(tidy_data))
names(tidy_data) <- gsub("BodyBody", "Body", names(tidy_data))

final_data <- tidy_data %>%
  group_by(subject, activity) %>%
  summarise(across(everything(), ~ mean(.x, na.rm = TRUE)), .groups = "drop")

# Write to file
write.table(final_data, "tidy_dataset.txt", row.name = FALSE)


