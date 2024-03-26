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

tibble_data <- lapply(json_data$webscraped_data, create_tokens)
unlisted_tokens <- lapply(tibble_data, unlist_tokens)

unlist_tokens <- function(tibble_data){
  tibble_length <- length(tibble_data)
  
  for(i in seq_along(1:tibble_length)) {
    tibble <- tibble_data[[i]]
    unlisted_tokens[[i]] <- lapply(tibble, uncount, weights = "n") 
    unnested_tokens[[i]] <- lapply(unlisted_tokens[[i]], unlist, use.names = FALSE)
  }
  
  return(unnested_tokens)
}


json_unserialized <- tibble(paper = json_data$`data$paper`, 
                            text_tibble = json_data$tibble_data)
json_unserialized$unnested <- map(json_unserialized$text_tibble, uncount, weights = n) %>% 
  map(., unlist, use.names = FALSE)
  

#practice unnesting 

one_tibble <- tibble_data[[1]]
ot_unnested <- uncount(one_tibble, weights = n)
ot_unlisted <- unlist(ot_unnested, use.names = FALSE)

one_tibble <- tibble_data[[1:2]]
ot_unnested <- lapply(one_tibble, uncount, weights = n)
ot_unlisted <- unlist(ot_unnested, use.names = FALSE)

j <- seq_along(1:2)

for(i in seq_along(1:2)) {
  unlisted_tokens[[i]] <- lapply(one_tibble[i], uncount, weights = "n") 
  unlisted_tokens[[i]]
  unnested_tokens[[i]] <- lapply(unlisted_tokens[i], unlist, use.names = FALSE)
  unnested_tokens[[i]]
}i f

