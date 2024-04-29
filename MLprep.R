#prep dataset for ML modeling 
#
#
#library statements
library(tidyverse)
library(tidytext)
library(jsonlite)
library(mikropml)
#library(textstem) #for stemming text variables

#function to read and unserialize jsonfile 
use_json <- function(jsonfile){
  json_data <- read_json(jsonfile)
  json_data <- unserializeJSON(json_data[[1]])
}

# #read and unserialize json file
# jsonfile <- "Data/gt_subset_30_data.json"
# json_data <- read_json(jsonfile)  
# json_data <- unserializeJSON(json_data[[1]])

json_to_tibble <- function(json_data) {
 json_tibble <- tibble(paper_doi = json_data$`data$paper`,
         new_seq_data = json_data$`data$new_seq_data`,
         text_tibble = json_data$tibble_data) 
 
 tidy_tibble <- unnest(json_tibble, cols = text_tibble)
 
 data_tibble <- pivot_wider(tidy_tibble, id_cols = c(paper_doi, new_seq_data),
                            names_from = word, values_from = n,
                            names_sort = TRUE, values_fill = 0) #%>%
 data_tibble <- select(data_tibble, !paper_doi)
 return(data_tibble)
}


# #set up dataset for 1 ML model; paper, new_seq_data, text_tibble
# json_tibble <- tibble(paper_doi = json_data$`data$paper`,
#                       new_seq_data = json_data$`data$new_seq_data`,
#                       text_tibble = json_data$tibble_data)
# 
# #need to pull out text tibble so that each word appears by paper
# tidy_tibble <- unnest(json_tibble, cols = text_tibble)

#implement sparse matrix
#sparse_matrix <- cast_sparse(tidy_tibble, paper, column = new_seq_data_binary, word, n)

#20240424 - export this 'matrix' like object and use mikropml vinegettes on data preprocessing
#also a section on hyper parameter tunings 
#kelly has a snakemake for mikropml as well, with template 
# data_tibble <- pivot_wider(tidy_tibble, id_cols = c(paper_doi, new_seq_data), names_from = word, 
#                       values_from = n, names_sort = TRUE, values_fill = 0) 
# data_tibble <- select(data_tibble, !paper_doi)

# prepped_data <- preprocess_data(data_tibble, outcome_colname = "new_seq_data")
# prepped_data$dat_transformed
#   
# ml_model <- run_ml(prepped_data$dat_transformed, method = "glmnet",  outcome_colname = "new_seq_data", seed = 2000)
# 
# ml_model
# ml_model$trained_model



#gtss30 intial model
gtss30 <- use_json("Data/gt_subset_30_data.json")
gtss30 <- json_to_tibble(gtss30)

prepped_data_gtss30 <- preprocess_data(gtss30, outcome_colname = "new_seq_data")
prepped_data_gtss30$dat_transformed

ml_model_gtss30 <- run_ml(prepped_data_gtss30$dat_transformed, 
                   method = "glmnet",  outcome_colname = "new_seq_data", 
                   seed = 2000)
ml_model_gtss30

#groundtruth intial model
groundtruth <- use_json("Data/groundtruth.json")
groundtruth <- json_to_tibble(groundtruth)

prepped_data_gt <- preprocess_data(groundtruth, outcome_colname = "new_seq_data")
prepped_data_gt$dat_transformed

ml_model_gtss30 <- run_ml(prepped_data_gt$dat_transformed, 
                          method = "glmnet",  outcome_colname = "new_seq_data", 
                          seed = 2000)
ml_model_gt
