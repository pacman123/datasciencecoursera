#loading the feature description 
featureDesc = read.table("./UCI HAR Dataset/features.txt");
#loading the required feature 
featureDesc.f = rbind(filter(featureDesc, grepl("mean()",V2, fixed = TRUE)),
                      filter(featureDesc, grepl("std()",V2, fixed = TRUE)))

selectedFeatures = featureDesc.f[,1]

#1. Loading the test data file 
testDataX = read.table("./UCI HAR Dataset/test/X_test.txt");
testDataY = read.table("./UCI HAR Dataset/test/y_test.txt");
testDataSubject = read.table("./UCI HAR Dataset/test/subject_test.txt")

#2. Renaming the column names
colnames(testDataX) <- featureDesc[,2]
colnames(testDataY) <- "label"
colnames(testDataSubject) <- "subject"
testDataX = testDataX[,selectedFeatures]
#3. Adding the index number to test data
testDataRow = nrow(testDataX)
testDataX$index = seq(1, testDataRow)
testDataY$index = seq(1, testDataRow)
testDataSubject$index = seq(1, testDataRow)

#4. Merge the three datasets.
testDataMerged = merge(testDataX,testDataY, by.x = "index", by.y = "index")
testDataMerged = merge(testDataMerged, testDataSubject, by.x = "index", by.y = "index")

#5 Reapeating step 1- 4 for training data as well
trainDataX = read.table("./UCI HAR Dataset/train/X_train.txt");
trainDataY = read.table("./UCI HAR Dataset/train/y_train.txt");
trainDataSubject = read.table("./UCI HAR Dataset/train/subject_train.txt")
colnames(trainDataX) <- featureDesc[,2]
colnames(trainDataY) <- "label"
colnames(trainDataSubject) <- "subject"
trainDataX = trainDataX[,selectedFeatures]
trainDataRow = nrow(trainDataX)
trainDataX$index = seq(testDataRow + 1, testDataRow + trainDataRow)
trainDataY$index = seq(testDataRow + 1, testDataRow + trainDataRow)
trainDataSubject$index = seq(testDataRow + 1, testDataRow + trainDataRow)
trainDataMerged = merge(trainDataX, trainDataY, by.x = "index", by.y = "index")
trainDataMerged = merge(trainDataMerged, trainDataSubject, by.x = "index", by.y = "index")

#binding trainData and TestData
completeData = rbind(testDataMerged, trainDataMerged)


#replacing the label with the variable name
activityLabel = read.table("./UCI HAR Dataset/activity_labels.txt"); 
activityLabelVector = activityLabel[,2]
completeData.final = mutate(completeData, label = activityLabelVector[label])

#FinalStep
tidyData = completeData.final %>% group_by(label,subject) %>% summarise_each(funs(mean))
write.table(tidyData, "tidyData.txt", sep="\t")
