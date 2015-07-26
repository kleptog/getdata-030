# Load datasets
labellist = read.table("UCI HAR Dataset/activity_labels.txt")
featurelist <- read.table("UCI HAR Dataset/features.txt")$V2
training_data <- read.table("UCI HAR Dataset/train/X_train.txt")
training_labels <- read.table("UCI HAR Dataset/train/y_train.txt")
training_subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
test_data <- read.table("UCI HAR Dataset/test/X_test.txt")
test_labels <- read.table("UCI HAR Dataset/test/y_test.txt")
test_subjects <- read.table("UCI HAR Dataset/test/subject_test.txt")

# Fix column names
names(labellist) <- c("label", "label_text")
names(training_data) <- featurelist
names(training_labels) <- c("label")
names(training_subjects) <- c("subject")
names(test_data) <- featurelist
names(test_labels) <- c("label")
names(test_subjects) <- c("subject")

# Step 1: Combine datasets. check.names=FALSE prevents R from changing the column names
training <- data.frame(training_subjects, training_labels, training_data, check.names=FALSE)
test <- data.frame(test_subjects, test_labels, test_data, check.names=FALSE)

dataset <- rbind(training, test)

# Step 2: We only want the means and standard deviations
interesting_features <- grep("-(mean|std)\\(\\)", names(dataset), value=TRUE)
dataset <- dataset[c("subject", "label", interesting_features)]

# Step 3: Add label_text column
dataset <- join(dataset, labellist)

# Step 4: Fix column labels to be more descriptive (add mean() for each column that is a mean)
new_names <- sprintf("mean(%s)", interesting_features)
names(dataset) <- c("subject", "label", new_names, "label_text")

# Step 5: Aggrate per (subject, label) over columns we're interested in and save
res <- aggregate(dataset[new_names], list(subject=dataset$subject, label_text=dataset$label_text), mean)

write.table(res, file="step5.txt", row.name=FALSE)