#get text statistics from tibbles in json files
#
#
#library statements
library(tidyverse)
library(tidytext)
library(jsonlite)

#read and de-serialize json 
json_data <- read_json("Data/gt_subset_30_data.json") 
json_data <- unserializeJSON(json_data[[1]])

#turns unserialized data into 2 column dataframe paper, text_tibble
json_unserialized <- tibble(paper = json_data$`data$paper`, 
                            text_tibble = json_data$tibble_data)

#use unnest_longer to make each word part of the same list
papers_long <- unnest_longer(json_unserialized, col = text_tibble)
#papers_long <- rename(papers_long, word = "text_tibble$word", n = "text_tibble$n")

total_words <- papers_long %>% group_by(paper) %>% summarize(total = sum(text_tibble$n))

paper_words <- left_join(papers_long, total_words)

paper_words <- arrange(paper_words, desc(text_tibble$n))
#paper_words <- rename(paper_words, word = "text_tibble$word", n = "text_tibble$n")

#this function doesn't work bc the names of the columns are too funky 
paper_words_tf_idf <- paper_words %>% bind_tf_idf(word, document = "paper", "text_tibble$n")
