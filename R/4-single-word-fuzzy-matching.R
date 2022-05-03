############################################
#Project: Inconsistent Writing in Word files
#Author:  Sarah
#Data:    friend's master's thesis
#Topic:   fuzzy matching for single words
#last edit: 03/05/2022
#############################################

# load libraries and words
source("set-up.R")
wordsDT <- readRDS("output/upper_lowerDT.rds")

# create a distance matrix
names <- wordsDT$word
d  <- adist(names,
            ignore.case=TRUE, 
            costs=c(i=1,d=1,s=2)) #i=insertion, d=deletion s=substitution)
rownames(d) <- names
colnames(d) <- names
distDT <- as.data.table(d)


