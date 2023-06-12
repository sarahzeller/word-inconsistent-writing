library(dtplyr)
library(dplyr)
library(here)
library(stringr)

# load words
words <- here("output/content_tableDT.rds") |> readRDS() |> 
  select(-first_word, -N)

two_words_unfiltered <- here("output/two_words.rds") |> readRDS() 

addin_vars <- abbreviations <- "input/addin_variables.docx" |> 
  here() |> 
  read_combinations_from_word() |> 
  mutate(word = trimws(word)) |> 
  pull(word)

# find Add-in IDs
ids_in_first_word <- two_words_unfiltered |> 
  filter(str_starts(two_words, "citationID |items |journalAbbreviation")) |> 
  mutate(id = sapply(strsplit(two_words, " "), `[`, 2)) |> 
  pull(id)

ids_in_second_word <- two_words_unfiltered |> 
  filter(str_ends(two_words, " properties")) |> 
  mutate(id = sapply(strsplit(two_words, " "), `[`, 1)) |> 
  pull(id)
  
# filter out add-in IDs
acronym_candidates <- words |>
  filter(!word %in% c(ids_in_first_word, 
                      ids_in_second_word,
                      addin_vars)) |> 
  mutate(n_upper = str_count(word, pattern = "[A-ZÄÖÜ]")) |> 
  filter(n_upper/nchar(word) > .5 & n_upper > 1) |>
  select(-n_upper) |> 
  arrange(desc(word)) |> 
  distinct()

saveRDS(acronym_candidates,
        file = "output/acronym_candidates.rds")
