library(stringdist)
library(stringr)
library(data.table)
library(dplyr)
library(dtplyr)

words_with_infoDT <- readRDS("output/upper_lowerDT.rds")

stem <- function(word){
  n <- nchar(word)
  last_2 <- substring(word, n-1, n)
  last <- substring(word, n, n)
  two_last_before <- substr(word, n-2, n-1)
  second_last <- substring(word, n-1, n-1)
  word_minus_1 <- substring(word, 1, n-1)
  word_minus_2 <- substring(word, 1, n-2)
  vowels_wo_e <- c("a", "i", "o", "u", "ö", "ü", "ä")
  stemmed <- ifelse(last_2 %in% c("en", "es", "er", "em", "nd", "rn", "in"),
                    word_minus_2,
                    ifelse(last %in% c("e") & 
                             !second_last == "e",
                           word_minus_1,
                           ifelse(last == "s" & !second_last %in% 
                                    c("l", 
                                      vowels_wo_e,
                                      "s"),
                                  word_minus_1,
                                  ifelse(last == "t" & !second_last %in%
                                           c("t",
                                             vowels_wo_e),
                                         word_minus_1,
                                         word))))
  
  return(stemmed)
}


words_with_infoDT <- words_with_infoDT |> 
  mutate(stem = stem(word) |> stem() |> stem()) |> 
  group_by(stem) |> 
  summarize(lowercase_mid = sum(lowercase_mid),
            lowercase_start = sum(lowercase_start),
            uppercase_mid = sum(uppercase_mid)
            # , word = paste(word)
  ) |> 
  as.data.table()

wordsDT <- words_with_infoDT[, "stem"][
  CJ(stem1 = stem,
     other_stem = stem,
     unique = TRUE)
]  |> 
  filter(substr(stem, 1, 1) == substr(other_stem, 1, 1)) |>
  filter(stem < other_stem) |>
  filter(nchar(stem) > 2 & nchar(other_stem) > 2) |>
  # kick out "an", "ab" similarities
  filter(!paste0(substr(stem, 1, 2), substr(other_stem, 1, 2)) 
         %in% c("aban", "anab")) |> 
  # kick out "auf", "aus"
  filter(!paste0(substr(stem, 1, 3), substr(other_stem, 1, 3)) 
         %in% c("aufaus", "ausauf")) |> 
  # ignore distance if it's about the last letter
  mutate(dist = ifelse(substr(stem, 1, nchar(stem)-1) == other_stem |
                         substr(other_stem, 1, nchar(other_stem)-1) == stem, 
                       NA_integer_,
                       stringdist(stem, other_stem))) |>
  mutate(frst_part_of_scnd = str_detect(other_stem, stem)) |>
  collect()



#TODO this is from the internet and needs to be checked out
hc <- hclust(as.dist(d))

plot(hc)
rect.hclust(hc,k=6)
df <- data.frame(names,cutree(hc,k=2000))
which(table(df$cutree.hc..k...2000.)>1)
View(df[df$cutree.hc..k...2000. %in% which(table(df$cutree.hc..k...2000.)>1),])

