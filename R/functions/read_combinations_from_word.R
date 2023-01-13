library(officer)
library(data.table)
library(tidyverse)

read_combinations_from_word <- function(path) {
  read_docx(path) |> 
    docx_summary() |> 
    as.data.table() |> 
    filter(content_type == "paragraph") |> 
    mutate(word1 = gsub("\\|.*", "", text)) |>
    mutate(word1 = gsub("\u00AC", "", word1)) |>
    mutate(word2 = gsub(".*\\|", "", text)) |>
    collect() |> 
    rowwise() |> 
    mutate(word = min(word1, word2)) |>
    mutate(other_word = max(word1, word2)) |>
    select(word, other_word) 
}