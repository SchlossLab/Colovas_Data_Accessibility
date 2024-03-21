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

#2 column dataframe, unnest makes each word part of the same list

#20230321 we actually want json_unserialized to be a df with each paper, 
#the variable in question/its status, and the entire text in one place
#how we do that?idk 
json_unserialized <- tibble(paper = json_data$`data$paper`, 
                            text_tibble = json_data$tibble_data)
papers_long <- unnest(json_unserialized, col = text_tibble)


