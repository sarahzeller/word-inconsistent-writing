library(officer)
acronyms <- readRDS("output/acronym_candidates.rds")

doc_acros <- read_docx() 
doc_acros <- body_add_par(doc_acros,
                          "List of acronyms",
                          style = "heading 1")
doc_acros <- lapply(1:length(acronyms$word),
                    FUN = function (x) body_add_par(doc_acros,
                                                    acronyms$word[[x]],
                                                    style = "Normal"))


if ("output_file" %in% ls() == FALSE) {
  output_file <- "output/acro_list.docx"
}

print(doc_acros,
      target = output_file)
