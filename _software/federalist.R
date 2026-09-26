# Process the Federalist Papers

library(dplyr)

Raw <- readLines("www/Federalist-raw.txt")

salutations <- grep("^To the People of the State of New York", Raw)

paper_num <- grep("^No\\. [IVXLC]*", Raw)

author <- Raw[salutations - 3]
number <- gsub("^No\\. ", "", Raw[paper_num])
number <- gsub("\\.$", "", number)
publius <- grep("^PUBLIUS", Raw)
text <- character(length(number))
Words <- list()

for (k in 1:length(number)) {
  text[k] <- paste(Raw[(salutations[k]+1):(paper_num[k+1]-5)], collapse = " ")
  word_split <- text[k] |> 
    strsplit(split = "[ \\.\\?\\,;\\:\\!\\)\\(\\]") |> 
    unlist() |>
    tolower()
  word_split <- word_split[nchar(word_split) > 0]
  word_split <- gsub("”", "", word_split, fixed = TRUE )
  word_split <- gsub("]", "", word_split, fixed = TRUE )
  word_split <- gsub("“", "", word_split, fixed = TRUE )
  
  Words[[k]] <- tibble::tibble(word = word_split,
                               number = number[k],
                               author = author[k])
                               
}

Federalist <- dplyr::bind_rows(Words)

Federalist |> dplyr::summarize(count = n(), .by = author)

Federalist |> dplyr::summarize(whilst = sum(word == "whilst"), .by = author)

Federalist |> dplyr::summarize(words = n_distinct(word), .by = author)

Long <- Federalist |> dplyr::summarize(n_uses = n(), 
                                       .by = c(author, word)) |>
  dplyr::mutate(r = rank(desc(n_uses)), 
                prob = n_uses / sum(n_uses), .by = author) 


Wide <- Long |> 
  dplyr::filter(author %in% c("HAMILTON", "MADISON")) |>
  dplyr::select(-n_uses, -r) |> 
  pivot_wider(names_from = author, values_from = prob) |>
  dplyr::filter(HAMILTON > 0.0001 | MADISON > 0.0001) |>
  mutate(lratio = (log10(HAMILTON / MADISON))) |>
  arrange(desc(lratio))

Features <- tibble::tribble(
  ~ word, ~ favors, ~ selected,
  "upon",        "hamilton", 1,
  "community",   "hamilton", 0,
  "thing",       "hamilton", 0,
  "there",       "hamilton", 0, 
  "conduct",     "hamilton", 0,
  "considerable","hamilton", 0,
  "always",      "hamilton", 0,
  "duty",        "hamilton", 0,
  "causes",      "hamilton", 0,
  "while",       "hamilton", 1, 
  "powers",      "madison",  0,
  "latter",      "madison",  0,
  "among",       "madison",  0,
  "appointed",   "madison",  0,
  "forms",       "madison",  0,
  "distinct",    "madison",  0,
  "term",        "madison",  0,
  "coin",        "madison",  0,
  "again",       "madison",  0,
  "whilst",      "madison",  1, 
  ) 

Myfeatures <- Features |> dplyr::filter(selected == 1)

Unknown <- Federalist |>
  dplyr::filter(author == "HAMILTON OR MADISON", word %in% Myfeatures$word) |>
  dplyr::summarize(count = n(), .by = c(word, number)) |>
  left_join(Myfeatures |> select(-selected))

Word_probs <- Long |>
  dplyr::filter(author %in% c("HAMILTON", "MADISON")) |>
  dplyr::filter(word %in% Myfeatures$word) |>
  select(-n_uses, -r) |>
  pivot_wider(names_from = author, values_from = prob,
              values_fill = 0)

Unknown |>
  left_join(Word_probs)
  
