library(stringdist)
library(stringr)
library(data.table)
library(dplyr)
library(dtplyr)

words_with_infoDT <- readRDS("output/upper_lowerDT.rds")

proper_nouns <- words_with_infoDT |> 
  # filter(uppercase_mid > 0) |>
  collect()

check_end <- function(word, other_word, length, characters) {
  paste0(substr(word, nchar(word)-length[1], nchar(word)),
         substr(other_word, nchar(other_word)-length[2], nchar(other_word))) %in% characters
}

check_start <- function(word, other_word, length, characters) {
  paste0(substr(word, 1, length[1]),
         substr(other_word, 1, length[2])) %in% characters
}

wordsDT <- 
  CJ(word = proper_nouns[["word"]],
     other_word = proper_nouns[["word"]],
     unique = TRUE) |>
  filter(substr(word, 1, 1) == substr(other_word, 1, 1)) |>
  filter(word < other_word) |>
  filter(nchar(word) > 2 & nchar(other_word) > 2) |>
  # kick out "an", "ab" similarities
  filter(!check_start(word, other_word, c(2,2), c("aban", "anab"))) |>
  # kick out "auf", "aus"
  filter(!check_start(word, other_word, c(3,3), c("aufaus", "ausauf"))) |>
  # kick out "an"/"auf", "aus"/"ab"
  filter(!(check_start(word, other_word, c(2,3), c("anauf", "abaus"))|
           check_start(word, other_word, c(3,2), c("aufan", "ausab")))) |>
  # kick out "vor", "ver"
  filter(!check_start(word, other_word, c(3,3), c("vorver", "vervor"))) |>
  # kick out gendered words
  filter(!(check_end(word, other_word, c(-1, 1), c("in"))|
           check_end(word, other_word, c(1, -1), c("in")))) |>
  # kick out "n"/"t" in the end
  filter(!check_end(word, other_word, c(0, 0),
                    c("nt", "tn", "et", "te", "mr", "rm", "rs", "sr", "es", 
                      "se", "ms", "sm", "sn", "ns"))) |>
  mutate(dist = ifelse(substr(word, 1, nchar(word)-1) == other_word |
                         substr(other_word, 1, nchar(other_word)-1) == word,
                       NA_integer_,
                       stringdist(word, other_word, 
                                  weight = c(d = .5, i = .5, s = 1, t = 1)))) |>
  # check for different Genitiv (s/es)
  mutate(s_es = 
           (check_end(word, other_word, length = c(1, 0), c("ses", "ess")) |
           check_end(word, other_word, length = c(0,1), c("ses", "ess"))) & dist <= 1) |> 
  filter(!(s_es == TRUE &
            check_end(word, other_word, length = c(-1,1), "ss") |
             check_end(word, other_word, length = c(1, -1), "ss"))) |> 
  mutate(rn_ren = (str_detect(word, "ren") & str_detect(other_word, "rn")|
                     str_detect(word, "rn") & str_detect(other_word, "ren")) & dist <= 1) |> 
  mutate(t_z = (str_detect(word, "nt") & str_detect(other_word, "nz")|
           str_detect(word, "nz") & str_detect(other_word, "nt")) & dist <= 1 &
           !(str_detect(word, "nt$") | !str_detect(word, "nz$"))) |> 
  mutate(diff_s = dist == 0.5 & 
           (!str_detect(word, "st$") & !str_detect(other_word, "st$")) &
           (str_count(word, "s") != str_count(other_word, "s"))) |> 
  mutate(diff_e = dist == 0.5 & 
           (str_count(word, "e") != str_count(other_word, "e"))) |> 
  # kick out if "ge" somewhere within the word is the difference
  filter(!(str_count(word, "ge") != str_count(other_word, "ge") &
             dist == 1)) |> 
  # kick out if difference is at the end of the word only
  filter(!(check_end(word, other_word, length = c(-1, 1),
                     c("er", "em", "st", "et", "te", "so", "zu", "re")) &
           dist == 1)) |>
  # kick out "n"/"ung"
  filter(!(check_end(word, other_word, length = c(0, 2), c("nung", "ungn")) &
             dist == 1)) |>
  # kick out "er"/"et"
  filter(!(check_end(word, other_word, length = c(1,1), c("eret", "eter")) &
           dist == 1)) |>
  # kick out "en"/"ten"
  filter(!(check_end(word, other_word, length = c(1, 2), c("tenen", "enten")) &
           dist == 0.5)) |> 
  # kick out "daraus"/"darauf"
  filter(!(c(word %in% c("daraus", "darauf") & 
             other_word %in% c("daraus", "darauf")))) |> 
  # kick out "zwei"/"zeit"
  filter(!(word %in% c("zeit", "zweit") &
             other_word %in% c("zeit", "zweit"))) |> 
  collect()

saveRDS(wordsDT,
        "output/wordsDT.RDS")