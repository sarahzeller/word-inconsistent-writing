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
library(stringr)
# build a DT in which all words are confronted with all others with the same 
# first letter
wordsDT <- words_with_infoDT[, "word"][
  CJ(word1 = word,
     other_word = word,
     unique = TRUE)
][
  # exclude pairs with the different start letter
  , c("word1_letter1", "word2_letter1") := 
                     .(substr(word, 1, 1), substr(other_word, 1, 1))
][
  word1_letter1 == word2_letter1
][
 , c("word1_letter1", "word2_letter1") := NULL 
][
  # exclude pairs with the same word
  word != other_word][
  # calculate distance between words
  , dist := stringdist(word, other_word)
][
  # exclude too short words & too large distances
  # TODO figure out a good distance
  length(word) > dist + 1 & dist < 4
]



