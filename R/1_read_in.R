############################################
#Project: Inconsistent Writing in Word files
#Author:  Sarah
#Data:    friend's master's thesis
#Topic:   read in word file
#last edit: 22/03/28
#############################################

source("set-up.R")

## read in file
word_file <- read_docx("input/220222_Leo.docx")
contentDT <- as.data.table(docx_summary(word_file))

## delete appendix and empty lines
contentDT <- contentDT[
  1:(which(text == "Literaturverzeichnis")-2)][
  text != "", "text"
]

# replace colon with space
contentDT[, text := str_replace(text, ":", " ")]

## unnest tokens to find words
content_tidy <- unnest_tokens(contentDT, 
                              words, 
                              text,
                              to_lower = F)

## create table of all words
content_tableDT <- as.data.table(table(content_tidy,
                                     dnn = "word"))[
  order(-N, word)
]
saveRDS(content_tableDT, file = "output/content_tableDT.rds")
