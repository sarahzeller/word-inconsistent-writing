# read in words so far
word_combinationsDT <- readRDS("output/word_combinationsDT.RDS")

# read in stop words
source("R/functions/read_combinations_from_word.R")
stop_words <- read_combinations_from_word("input/stop_combinations.docx")
 
word_combinationsDT <- word_combinationsDT |> 
  anti_join(stop_words, by = c("word", "other_word"))

interesting_words <-
  word_combinationsDT |> 
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

close_words <- word_combinationsDT |> 
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

# one two
readRDS("output/one_two.rds") |> 
  anti_join(stop_words, 
            by = c("two_words" = "word", "one_word" = "other_word")) |> 
  mutate(first_word = ifelse(n1 >= n2,
                             two_words,
                             one_word),
         second_word = ifelse(n1 >= n2,
                              one_word,
                              two_words)) |> 
  saveRDS("output/one_two_filtered.rds")
  

# hyphens
  readRDS("output/hyphen_no_hyphen.rds") |> 
  anti_join(stop_words,
            by = c("hyphen" = "word", "no_hyphen_word" = "other_word")) |> 
  mutate(first_word = ifelse(n_hyphen > n_no_hyphen,
                             no_hyphen_word,
                             hyphen),
         second_word = ifelse(n_hyphen > n_no_hyphen,
                              hyphen,
                              no_hyphen_word)) |> 
    select(first_word, second_word) |> 
    saveRDS("output/hyphen_filtered.rds")
