# Find definition words in the files
library(dplyr)
library(tidytext)
library(tibble)
library(stringr)

load("XREFS.rda")

Definitions <- XREFS %>%
  filter(grepl("-definition$", ID)) |>
  mutate(chap = gsub("Chap-([0-9]+)-.*", "\\1", file)) |>
  mutate(label = tolower(label), chap = as.integer(chap)) |>
  select(label, chap)



find_phrases_in_text <- function(df, chapnum) {
  Chapters <- dir(pattern = "Chap-[0-9]{2}-.*\\.qmd$")[-1]
  file_path <- Chapters[chapnum]

  # 1. Read the text file and collapse it into a single string
  text_content <- paste(readLines(file_path, warn = FALSE), collapse = " ")
  df <- df |> filter(as.integer(chap) <= chapnum)
  # 2. Extract unique phrases from the 'label' column
  phrases <- unique(df$label)
  
  # 3. Use stringr to count occurrences of each phrase
  # paste0("\\b", ...) ensures we match whole phrases, not partial words
  counts <- sapply(phrases, function(p) {
    pattern <- paste0("\\b", regex_escape(p), "\\b")
    str_count(text_content, regex(pattern, ignore_case = TRUE))
  })
  
  # 4. Build the output data frame containing only matching phrases
  output_df <- data.frame(
    phrase = phrases,
    count = counts,
    stringsAsFactors = FALSE
  ) |>
    filter(count > 0)

  if (nrow(output_df) == 0) return(output_df)

  
  
  rownames(output_df) <- NULL
  return(output_df |> arrange(phrase))
}



# Helper function to escape special regex characters (like ?, ., +, etc.)
# if they happen to exist inside your phrases
regex_escape <- function(string) {
  str_replace_all(string, "([\\.\\\\\\+\\*\\?\\[\\^\\]\\$\\(\\)\\{\\}\\=\\!\\<\\>\\|\\:])", "\\\\\\1")
}
  

chapter_phrases <- function(chapnum = 3) {
    Chap_phrases <- find_phrases_in_text(Definitions, chapnum)
    Chap_phrases |>
      left_join(Definitions, by = c("phrase" = "label")) |>
      filter(chap <= chapnum, count > 1) |>
      mutate(type = ifelse(chap == chapnum, "current", "previous")) |>
      filter(!duplicated(phrase))
}


  
 words_for_chapter <- function(chapnum = 3) {
   dat <- chapter_phrases(chapnum)
   top <- dat |> 
     filter(type=="previous") |>
     select(phrase, chap) |>
     arrange(phrase) |>
     with(paste0("- ", phrase, " (", chap, ")", collapse="\n"))
   bottom <- dat |>
     filter(type=="current") |>
     select(phrase, chap) |>
     arrange(phrase) |>
     with(paste0("- ", phrase, collapse="\n"))
 
   text <- paste0("*Vocabulary Review*\n\n", top, "\n\n*New*\n\n", bottom) 
   writeLines(text, con = paste0("_Words/chap_", chapnum, ".txt"))
 }
  
 words_for_chapter(1)
 words_for_chapter(2)  
  
  
