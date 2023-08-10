############################################
#Project: Inconsistent Writing in Word files
#Author:  Sarah
#Data:    friend's master's thesis
#Topic:   read in word file
#last edit: 22/03/28
#############################################

library(officer)
library(data.table)
library(tidytext)
library(tidyverse)

## read in file
word_file <- read_docx(input)
contentDT <- as.data.table(docx_summary(word_file))

## delete appendix and empty lines
contentDT <- contentDT[1:(ifelse("Literaturverzeichnis" %in% contentDT$text,
                                 which(text == "Literaturverzeichnis")-2,
                                 nrow(contentDT)))
            ][text != "", "text"
              ]

# replace colon so that it's the end of a sentence
contentDT[, text := str_replace(text, ":", ". ")]
saveRDS(contentDT, "output/contentDT.rds")

## unnest tokens to find words
content_tidyDT <- unnest_tokens(contentDT, 
                              word, 
                              text,
                              token = "sentences",
                              to_lower = F) |> 
  #figure out first word in sentence
  mutate(word1 = sapply(strsplit(word, " "), `[`, 1)) |> 
  #then into words
  unnest_tokens(word, word, to_lower = F) |> 
  # kick out weird stuff
  filter(nchar(word) < 35,
         !str_detect(word, "ADDIN|CitaviPlaceholder|VDI|Zotero")
         ) |>  
  # group_by(word) |> 
  mutate(first_word = str_detect(word1, word)) |> 
  # ungroup() |> 
  select(-word1) 

## create table of all words
content_tableDT <- content_tidyDT[, .N, by = .(word, first_word)]

saveRDS(content_tableDT, file = "output/content_tableDT.rds")

## create ngrams with two words
two_words <- unnest_tokens(contentDT, 
                           word, 
                           text,
                           token = "sentences",
                           to_lower = F) |> 
  #figure out first word in sentence
  mutate(begin_sentence = sapply(strsplit(word, " "), `[`, 1))  |> 
  #ensure hyphen stays
  mutate(word = str_replace_all(word, "-", "_")) |> 
  collect() |> 
  unnest_tokens(two_words,
                word, 
                token = "ngrams",
                n = 2,
                to_lower = F)  |> 
  mutate(first_word = sapply(strsplit(two_words, " "), `[`, 1) == begin_sentence) 

saveRDS(two_words, file = "output/two_words.rds")

# hyphen-words
hyphens <- unnest_tokens(contentDT, 
                        word, 
                        text,
                        token = "sentences",
                        to_lower = F) |> 
  #only keep hyphen words
  mutate(word = str_replace_all(word, "-", "_")) |> 
  unnest_tokens(word, word, to_lower = F) |> 
  filter(grepl("_", word) & !grepl("^_|_$", word)) |> 
  mutate(word = str_replace_all(word, "_", "-")) |>
  # kick out weird stuff
  filter(nchar(word) < 35,
         # !str_detect(word, "ADDIN"), 
         # !str_detect(word, "CitaviPlaceholder"), 
         # !str_detect(word, "VDI"), 
         # !str_detect(word, "Zotero"),
         !grepl("([0-9])", word)) |> 
  group_by(word) |> 
  summarize(n_hyphen = n())
saveRDS(hyphens, "output/hyphens.rds")
