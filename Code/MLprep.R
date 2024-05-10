#prep dataset for ML modeling 
#
# 20240429 MLprep.R of groundtruth, groundtruth_subset30
# using mikropml and model glmnet to train model to predict
# variable new_seq_data
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
 json_tibble <- tibble(paper_doi = json_data$`paper_doi`,
         new_seq_data = json_data$`data$new_seq_data`,
         text_tibble = json_data$`paper_tokens`,
         journal = json_data$`journal`, 
         year_published = json_data$`year_published`) 
 
 tidy_tibble <- unnest(json_tibble, cols = text_tibble)
 
 data_tibble <- pivot_wider(tidy_tibble, id_cols = c(paper_doi, new_seq_data),
                            names_from = word, values_from = n,
                            names_sort = TRUE, values_fill = 0) #%>%
 data_tibble <- select(data_tibble, !paper_doi)
 return(data_tibble)
}

#----------------20240510----fix script for gtss30--------------------------
json_data <- gtss30
json_tibble <- tibble(paper_doi = json_data$`paper_doi`,
                      new_seq_data = json_data$`data$new_seq_data`,
                      text_tibble = json_data$`paper_tokens`,
                      journal = json_data$`journal`, 
                      year_published = json_data$`year_published`) 

json_tibble_untouched <- json_tibble
json_tibble$text_tibble <- map(json_tibble$text_tibble, unlist)



#------------------------end---------------------------------------------


#gtss30 intial model
gtss30 <- use_json("Data/gt_subset_30_data.json")
gtss30 <- json_to_tibble(gtss30)

prepped_data_gtss30 <- preprocess_data(gtss30, outcome_colname = "new_seq_data")
prepped_data_gtss30$dat_transformed

ml_model_gtss30 <- run_ml(prepped_data_gtss30$dat_transformed, 
                   method = "glmnet",  outcome_colname = "new_seq_data", 
                   seed = 2000)
ml_model_gtss30

# #groundtruth intial model
# #20240510 gt is living on GL right now so because it is too large
# groundtruth <- use_json("Data/groundtruth.json")
# groundtruth <- json_to_tibble(groundtruth)
# 
# prepped_data_gt <- preprocess_data(groundtruth, outcome_colname = "new_seq_data")
# prepped_data_gt$dat_transformed
# 
# ml_model_gt <- run_ml(prepped_data_gt$dat_transformed, 
#                           method = "glmnet",  outcome_colname = "new_seq_data", 
#                           seed = 2000)
# ml_model_gt
