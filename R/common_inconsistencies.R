############################################
#Project: Inconsistent Writing in Word files
#Author:  Sarah
#Data:    friend's master's thesis
#Topic:   inconsistent spelling of common abbreviations
#last edit: 22/04/07
#############################################

common_inconsistencies <- data.table(c("bspw", "bzw", "ggf", "insb", "selbständig"), 
                                     c("beispielsweise", "beziehungsweise", 
                                       "gegebenenfalls",
                                       "insbesondere","selbstständig"))

two_words <- data.table(two = c("zu Hause", "auf Grund"),
                        one = c("zuhause", "aufgrund"))

abbreviations <- data.table(abb = c("z.B.", "u.a.", "d.h.", "i.d.R.", "v.a."),
                            full = c("zum Beispiel", "unter anderem", 
                                     "das heißt", "in der Regel", 
                                     "vor allem"))