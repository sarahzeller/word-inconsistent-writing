library(data.table)
library(dtplyr)
library(dplyr)
library(tidytext)

acros <- readRDS("output/acronym_candidates.rds")
doc <- readRDS("output/contentDT.rds")

sentences <- unnest_tokens(doc, 
                           sentence, 
                           text,
                           token = "sentences",
                           to_lower = FALSE) 

# find something easy first
acro_letters <- 
  acros[28,] |> 
  pull() |> 
  gsub("\\.", "", x = _) |> 
  strsplit("") |>
  unlist()
regex <- paste0("\\b", 
                paste0(acro_letters, "\\w*(\\s|-|\\.)*", collapse = ""),
                collapse = "")
matches <- grepl(regex, sentences$sentence, ignore.case = FALSE) |> which()
sentences[matches] |> View()
