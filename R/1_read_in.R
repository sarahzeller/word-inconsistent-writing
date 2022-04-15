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

# replace colon so that it's the end of a sentence
contentDT[, text := str_replace(text, ":", ". ")]

## unnest tokens to find words
content_tidyDT <- unnest_tokens(contentDT, 
                              word, 
                              text,
                              token = "sentences",
                              to_lower = F) %>%
  #figure out first word in sentence
  mutate(word1 = sapply(strsplit(word, " "), `[`, 1)) %>%
  #then into words
  unnest_tokens(word, word, to_lower = F) 

content_tidyDT[, first_word := grepl(word, word1), by = word]
content_tidyDT[, word1 := NULL]

## create table of all words
content_tableDT <- content_tidyDT[, .N, by = .(word, first_word)]

saveRDS(content_tableDT, file = "output/content_tableDT.rds")