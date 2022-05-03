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
wordsDT[, `:=`(uppercase = ifelse(uppercase == T, 
                                  "uppercase", 
                                  "lowercase"),
               first_word = ifelse(first_word ==T, 
                                        "start", 
                                        "mid"))]
upper_lowerDT <- dcast(wordsDT, 
                       word  ~ uppercase + first_word, 
                       value.var = "N", 
                       fun.aggregate = sum,
                       sep = "_", 
                       drop = F)

#exclude upper after punctuation --> doesn't matter
upper_lowerDT[, uppercase_start := NULL]

#exclude all which don't have both spellings after the first word of a sentence
upper_lower_gapDT <- upper_lowerDT[!(lowercase_mid == 0 | uppercase_mid == 0)][
  , lowercase_start := NULL
]

#TODO: figure out if a "-" precedes an uppercase word
#TODO: figure out if an article precedes the uppercase word
saveRDS(upper_lowerDT, "output/upper_lowerDT.rds")
