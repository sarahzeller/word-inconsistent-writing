# Inconsistent writing

Pulls all words from a Word document and checks for inconsistent writing, e.g. zu Hause/zuhause, Schneider/Schneyder.

To run: open `R/0-run_all.R` and let it run.
You can interactively choose the document you want to analyze.

Output is a word document which can be used with Paul Beverley's [FRedit macro](https://www.wordmacrotools.com/pdfs/FRedit_Manual.pdf).

*Note:* The output file should be checked!

Many combinations should not be run with FRedit, since they actually include two different words, and not one word which is spelled in two different ways.
To ignore such combinations in the future, copy them into `input/stop_combinations.docx`.
The script will find them there and ignore them.
