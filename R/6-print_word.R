library(officer)
library(dplyr)

words <- readRDS("output/interesting_words.RDS")
next_best <- readRDS("output/close_words.RDS")

text <- 
"\u00AC" |> 
paste0(paste(words |> pull(first_word), words |> pull(second_word), sep = "|"))

text_next_best <- "\u00AC" |>
  paste0(paste(next_best |> pull(first_word), next_best |> pull(second_word), sep = "|"))

full_text <- c(text, "", "| next-best", "", text_next_best)

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
