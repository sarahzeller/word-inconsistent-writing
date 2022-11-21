# read in words so far
wordsDT <- readRDS("output/wordsDT.RDS")

# read in stop words
stop_words <- read_docx("input/stop_combinations.docx") |> 
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


wordsDT <- wordsDT |> 
  anti_join(stop_words, by = c("word", "other_word"))



interesting_words <-
  wordsDT |> 
  filter(s_es == TRUE | rn_ren == TRUE | t_z == TRUE | diff_s == TRUE | 
           diff_e == TRUE) |> 
  collect() |> 
  merge(words_with_infoDT |> select(word, n), 
        all.x = TRUE,
        by = "word") |> 
  merge(words_with_infoDT |> select(word, n),
        all.x = TRUE,
        by.x = "other_word",
        by.y = "word",
        suffixes = c("_other", "")) |> 
  mutate(first_word = ifelse(n >= n_other,
                             word,
                             other_word),
         second_word = ifelse(n >= n_other,
                              other_word,
                              word)) |> 
  mutate(first_word = ifelse(s_es == TRUE, paste0(first_word, "^32"), first_word)) |> 
  mutate(second_word = ifelse(s_es == TRUE, paste0(second_word, "^32"), second_word)) 

saveRDS(interesting_words |> select(first_word, second_word),
        "output/interesting_words.RDS")

close_words <- wordsDT |> 
  filter(dist <= 1 & nchar(word) > 3 & nchar(other_word) > 4) |> 
  filter(s_es == FALSE & rn_ren == FALSE & t_z == FALSE & diff_s == FALSE & 
           diff_e == FALSE) |> 
  filter(!(check_end(word, other_word, length = c(-1, 1),
                     c("en", "es", "de")) &
             dist == 1)) |>
  collect() |> 
  merge(words_with_infoDT |> select(word, n), 
        all.x = TRUE,
        by = "word") |> 
  merge(words_with_infoDT |> select(word, n),
        all.x = TRUE,
        by.x = "other_word",
        by.y = "word",
        suffixes = c("_other", "")) |> 
  mutate(first_word = ifelse(n >= n_other,
                             word,
                             other_word),
         second_word = ifelse(n >= n_other,
                              other_word,
                              word)) |> 
  arrange(dist) 

saveRDS(close_words |> select(first_word, second_word),
        "output/close_words.RDS")
