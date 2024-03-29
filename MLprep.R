#prep dataset for ML modeling 
#
#
#library statements
library(tidyverse)
library(tidytext)
library(jsonlite)

#read and unserialize json file
jsonfile <- "Data/gt_subset_30_data.json"
json_data <- read_json(jsonfile)  
json_data <- unserializeJSON(json_data[[1]])

#set up dataset for 1 ML model; paper, new_seq_data, text_tibble
json_tibble <- tibble(paper = json_data$`data$paper`,
                      new_seq_data = json_data$`data$new_seq_data`,
                      text_tibble = json_data$tibble_data)

#need to pull out text tibble so that each word appears by paper
tidy_tibble <- unnest(json_tibble, cols = c(new_seq_data, text_tibble))

#implement sparse matrix
sparse_matrix <- cast_sparse(tidy_tibble, paper, word, n)

  
