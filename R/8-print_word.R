library(officer)
library(dplyr)

words <- readRDS("output/interesting_words.RDS")
next_best <- readRDS("output/close_words.RDS")
one_two <- readRDS("output/one_two_filtered.RDS")
hyphens <- readRDS("output/hyphen_filtered.RDS")

to_text <- function(word_pair) {
  "\u00AC" |> 
  paste0(paste(word_pair |> pull(first_word), 
               word_pair |> pull(second_word), 
               sep = "|"))
}

full_text <- c(to_text(words), 
               "", "| next-best", "", to_text(next_best), 
               "", "| one-two", "", to_text(one_two),
               "", "| hyphens", "", to_text(hyphens))

doc_words <- read_docx() 
doc_words <- body_add_par(doc_words,
                          "| Check the words before applying FRedit!")
doc_words <- lapply(1:length(full_text),
                    FUN = function (x) body_add_par(doc_words,
                                                    full_text[[x]], 
                                                    style = "Normal"))


if ("output_file" %in% ls() == FALSE) {
  output_file <- "output/inconsistent_words.docx"
}

print(doc_words,
      target = output_file)
