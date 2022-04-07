############################################
#Project: Inconsistent Writing in Word files
#Author:  Sarah
#Data:    friend's master's thesis
#Topic:   find occurrences of the same word in upper/lower case
#last edit: 22/04/07
#############################################

source("set-up.R")
wordsDT <- readRDS("output/wordsDT.rds")

#long to wide: check if a word is spelled with upper and lower case
wordsDT[, uppercase := ifelse(uppercase == T, "uppercase", "lowercase")]
upper_lowerDT <- dcast(wordsDT, 
                       word ~ uppercase, 
                       value.var = "N", 
                       fun.aggregate = sum,
                       sep = "_")

#exclude all which don't have both spellings
upper_lowerDT <- upper_lowerDT[!(lowercase == 0 | uppercase == 0)]

##TODO: Check if there's a fullstop before the word.