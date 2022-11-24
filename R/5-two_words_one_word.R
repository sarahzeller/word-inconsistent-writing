library(tidyverse)
library(data.table)
library(dtplyr)
two_words <- readRDS("output/two_words.rds")

two_words <- two_words |> 
  # mutate(two_words = tolower(two_words)) |> 
  mutate(two_words = paste0(substr(two_words, 1, 1) |> tolower(), 
                           substr(two_words, 2, nchar(two_words)))) |> 
  group_by(two_words) |> 
  summarize(n2 = n()) |> 
  mutate(no_space = gsub(" ", "", two_words |> tolower())) |> 
  distinct() |> 
  collect()

one_word <- readRDS("output/content_tableDT.rds") |> 
  mutate(one_lower = tolower(word)) |> 
  group_by(one_lower) |> 
  summarize(n1 = sum(N)) |> 
  collect()

one_two <- CJ(two_words_no_space = two_words[["no_space"]],
              one_word = one_word[["one_lower"]]) |> 
  filter(two_words_no_space == one_word) |> 
  distinct() |> 
  collect()  |> 
  merge(all.x = TRUE,
        y = two_words,
        by.x = "two_words_no_space",
        by.y = "no_space") |> 
  merge(all.x = TRUE,
        y = one_word,
        by.x = "one_word",
        by.y = "one_lower") |> 
  select(-two_words_no_space) |> 
  collect()

saveRDS(one_two, "output/one_two.rds")


