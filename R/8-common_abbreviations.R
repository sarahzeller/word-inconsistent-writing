library(data.table)
library(dtplyr)
library(dplyr)

source("R/functions/read_combinations_from_word.R")
abbreviations <- "input/common_inconsistencies.docx" |> 
  read_combinations_from_word() |> 
  mutate(word = trimws(word)) |> 
  mutate(other_word_no_dot = gsub("\\.", "", other_word))
wordsDT <- readRDS("output/wordsDT.rds")

duplicates <-
  abbreviations |>
  # check for duplicates
  mutate(dupl = tolower(word) %in% wordsDT$word &
           tolower(other_word_no_dot) %in% wordsDT$word) |>
  filter(dupl == TRUE) |>
  # merge with word counts
  merge(wordsDT |> select(word, N), 
        by = "word") |> 
  merge(wordsDT |> select(word, N),
        by.x = "other_word_no_dot",
        by.y = "word",
        suffixes = c("", "_other")) |>
  # clean up
  select(-other_word_no_dot, -dupl) |> 
  # ignore capitalization
  group_by(word, other_word) |> 
  summarize(N = sum(N), 
            N_other = sum(N_other)) |> 
  ungroup() |> 
  # put in the right order
  mutate(first_word = ifelse(N <= N_other, word, other_word),
         second_word = ifelse(N <= N_other, other_word, word)) |> 
  # only replace abbreviations with dots when they do not directly follow parentheses
  mutate(first_word = ifelse(grepl("\\.", first_word),
                             paste0("^32", first_word),
                             first_word),
         second_word = ifelse(grepl("\\.", first_word),
                              paste0("^32", second_word),
                              second_word))

saveRDS(duplicates,
        "output/common_abbreviations.rds")