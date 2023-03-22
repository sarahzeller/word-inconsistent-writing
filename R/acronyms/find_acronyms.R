library(dtplyr)
library(dplyr)
library(here)
library(stringr)
words <- here("output/content_tableDT.rds") |> readRDS() |> 
  select(-first_word, -N)

acronym_candidates <- words |>
  mutate(n_upper = str_count(word, pattern = "[A-ZÄÖÜ]")) |> 
  filter(n_upper/nchar(word) > .5 & n_upper > 1) |> 
  select(-n_upper) |> 
  arrange(desc(word)) |> 
  distinct()

saveRDS(acronym_candidates,
        file = "output/acronym_candidates.rds")
