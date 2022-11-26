# put file name here
# library(utils)
# args <- commandArgs(trailingOnly = TRUE, asValues = TRUE)
# input <- args$file
# 
# if (is.null(file)) {
#   print("Please specify a file using the -file option")
#   quit()
# }

input <- file.choose()

source("R/1-read-in.R")
source("R/2-relevant-words.R")
source("R/3-upper-lower-case.R")
source("R/4-proper_nouns.R")
source("R/5-two_words_one_word.R")
source("R/6_hyphens.R")
source("R/7-filter_words.R")
source("R/8-print_word.R")

shell("start output/inconsistent_words.docx", wait = FALSE)
shell("start input/stop_combinations.docx", wait = FALSE)

