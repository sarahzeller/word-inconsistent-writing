library(tidyverse)
library(data.table)
library(dtplyr)
library(stringdist)
hyphens <- readRDS("output/hyphens.rds") |> 
  mutate(no_hyphen = gsub("-", "", word) |> tolower()) |> 
  rename(hyphen = word) |> 
  collect()

no_hyphens <- readRDS("output/content_tableDT.rds") |> 
  mutate(lower_word = tolower(word)) |> 
  group_by(lower_word) |> 
  summarize(n_no_hyphen = sum(N)) |> 
  collect()

hyphen_no_hyphen <- CJ(hyphen_word = hyphens[["no_hyphen"]],
                    no_hyphen_word = no_hyphens[["lower_word"]]) |> 
  filter(substr(hyphen_word, 1, 1) == substr(no_hyphen_word, 1, 1)) |>
  filter(hyphen_word <= no_hyphen_word) |> 
  mutate(dist = stringdist(hyphen_word, no_hyphen_word)) |> 
  filter(dist <= 1) |>
  collect() |> 
  merge(y = hyphens, 
        all.x = TRUE,
        by.x = "hyphen_word",
        by.y = "no_hyphen") |> 
  merge(y = no_hyphens,
        all.x = TRUE,
        by.x = "no_hyphen_word",
        by.y = "lower_word")  |> 
  select(hyphen, n_hyphen, no_hyphen_word, n_no_hyphen)

saveRDS(hyphen_no_hyphen,
        "output/hyphen_no_hyphen.rds")
