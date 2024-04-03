#prep dataset for ML modeling 
#
#
#library statements
library(tidyverse)
library(tidytext)
library(jsonlite)
library(mikropml)

#read and unserialize json file
jsonfile <- "Data/groundtruth.json"
json_data <- read_json(jsonfile)  
json_data <- unserializeJSON(json_data[[1]])

#set up dataset for 1 ML model; paper, new_seq_data, text_tibble
json_tibble <- tibble(paper = json_data$`data$paper`,
                      new_seq_data = json_data$`data$new_seq_data`,
                      text_tibble = json_data$tibble_data)


# new column for paper as paper_doi
json_tibble <- rename(json_tibble, paper_doi = paper)

#need to pull out text tibble so that each word appears by paper
tidy_tibble <- unnest(json_tibble, cols = text_tibble)

#implement sparse matrix
#sparse_matrix <- cast_sparse(tidy_tibble, paper, column = new_seq_data_binary, word, n)

matrix <- pivot_wider(tidy_tibble, id_cols = c(paper_doi, new_seq_data), names_from = word, 
                      values_from = n, names_sort = TRUE, values_fill = 0)
matrix <- select(matrix, !paper_doi)

ml_model <- run_ml(matrix, method = "glmnet",  outcome_colname = "new_seq_data", seed = 2000)

ml_model
ml_model$trained_model
  
