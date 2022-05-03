############################################
#Project: Inconsistent Writing in Word files
#Author:  Sarah
#Data:    friend's master's thesis
#Topic:   filter out relevant/actual words
#last edit: 22/04/07
#############################################

source("set-up.R")
content_tableDT <- readRDS("output/content_tableDT.rds")

##check for upper and lower case
first_letter_upper <- function(x){
  substr(x, 1, 1) == toupper(substr(x, 1, 1))
}
content_tableDT[, uppercase := first_letter_upper(word)][
                , word := tolower(word)
                ]

# remove German stop words, numbers and single letters
stop_german <- data.table(word = c(stopwords::stopwords("de"),
                                   c("ab",
                                     "allerdings",
                                     "aufgrund",
                                     "beim",
                                     "bei",
                                     "dass",
                                     "jedoch",
                                     "sei",
                                     "sodass",
                                     "sowie",
                                     "wurde",
                                     "wurden")))
wordsDT <- content_tableDT[!stop_german, on = .(word)][ #stop words
                              nchar(word) > 1           #single letters
                            ][
                              !grepl("\\d", word)       #numbers
                            ][
                              order(word)               #order alphabetically
                            ]

#save
saveRDS(wordsDT, file = "output/wordsDT.rds")