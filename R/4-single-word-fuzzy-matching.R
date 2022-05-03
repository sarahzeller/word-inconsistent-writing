############################################
#Project: Inconsistent Writing in Word files
#Author:  Sarah
#Data:    friend's master's thesis
#Topic:   fuzzy matching for single words
#last edit: 03/05/2022
#############################################

# load libraries and words
source("set-up.R")
words_with_infoDT <- readRDS("output/upper_lowerDT.rds")

library(stringdist)
# build a DT in which all words are confronted with the other
wordsDT <- words_with_infoDT[, "word"][
  CJ(word1 = word,
     word2 = word,
     unique = TRUE)
  # exclude words which are paired with themselves
][word != word2][
  # calculate distance between words
  , dist := stringdist(word, word2)
][
  # exclude too large distances;
  # TODO figure out a good distance
  dist < 3
]



