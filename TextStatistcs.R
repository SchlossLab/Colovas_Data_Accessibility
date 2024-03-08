#get text statistics from tibbles in json files
#
#
#library statements
library(tidyverse)
library(tidytext)
library(jsonlite)

#function for tf-idf by paper
tfidf_bypaper <- function(jsonfile) {

  #read and de-serialize json 
  json_data <- read_json(jsonfile)  
  json_data <- unserializeJSON(json_data[[1]])
  
  #2 column dataframe, unnest makes each word part of the same list
  json_unserialized <- tibble(paper = json_data$`data$paper`, 
                              text_tibble = json_data$tibble_data)
  papers_long <- unnest(json_unserialized, col = text_tibble)
  
  #calculate the total number of words in each paper
  total_words <- papers_long %>% group_by(paper) %>% summarize(total = sum(n))
  
  #join the number of words in each paper to the paper link(DOI) and sort in descending order
  paper_words <- left_join(papers_long, total_words) %>% arrange(desc(n))
  
  #calculate and sort the tf-idf for each word in each document in the collection 
  paper_words_tf_idf <- bind_tf_idf(paper_words, word, paper, n) %>% 
    arrange(paper, desc(tf_idf))
  
  return(paper_words_tf_idf)
}

tfidf_overall <- function(jsonfile){
  
  #read and de-serialize json 
  json_data <- read_json(jsonfile)  
  json_data <- unserializeJSON(json_data[[1]])
  
  #2 column dataframe, unnest makes each word part of the same list
  json_unserialized <- tibble(paper = json_data$`data$paper`, 
                              text_tibble = json_data$tibble_data)
  papers_long <- unnest(json_unserialized, col = text_tibble)
  
  #join the number of words in each paper to the paper link(DOI) and sort in descending order
  total_words_ungrouped <- mutate(papers_long, total = sum(n)) %>% 
    arrange(desc(n))
  
  #calculate the tf-idf for each word in each document in the collection 
  overall_tf_idf <- bind_tf_idf(total_words_ungrouped, word, paper, n)
  
  return(overall_tf_idf)
  
}
#gt_subset_30
#gt_ss30_tfidf <- tfidf_bypaper("Data/gt_subset_30_data.json")
#gt_ss30_tfidf_overall <- tfidf_overall("Data/gt_subset_30_data.json")
#write_csv(gt_ss30_tfidf, "Data/gt_ss30_tfidf.csv")
#write_csv(gt_ss30_tfidf_overall, "Data/gt_ss30_tfidf_overall.csv")

#groundtruth
gt_tfidf <- tfidf_bypaper("Data/groundtruth.json")
gt_tfidf_overall <- tfidf_overall("Data/groundtruth.json")
write_csv(gt_tfidf, "Data/gt_tfidf.csv")
write_csv(gt_tfidf_overall, "Data/gt_tfidf_overall.csv")

#gt_availability yes/no
availability_no_tfidf <- tfidf_bypaper("Data/gt_availability_no.json")
availability_no_tfiidf_overall <- tfidf_overall("Data/gt_availability_no.json")
write_csv(availability_no_tfidf, "Data/availability_no_tfidf.csv")
write_csv(availability_no_tfiidf_overall, 
  "Data/availability_no_tfiidf_overall.csv")

availability_yes_tfidf <- tfidf_bypaper("Data/gt_availability_yes.json")
availability_yes_tfiidf_overall <- tfidf_overall("Data/gt_availability_yes.json")
write_csv(availability_yes_tfidf, "Data/availability_yes_tfidf.csv")
write_csv(availability_yes_tfiidf_overall, 
  "Data/availability_yes_tfiidf_overall.csv")

  #gt_newseq yes/no
newseq_no_tfidf <- tfidf_bypaper("Data/gt_newseq_no.json")
newseq_no_tfiidf_overall <- tfidf_overall("Data/gt_newseq_no.json")
write_csv(newseq_no_tfidf, "Data/newseq_no_tfidf.csv")
write_csv(newseq_no_tfiidf_overall, 
  "Data/newseq_no_tfiidf_overall.csv")

newseq_yes_tfidf <- tfidf_bypaper("Data/gt_newseq_yes.json")
newseq_yes_tfiidf_overall <- tfidf_overall("Data/gt_newseq_yes.json")
write_csv(newseq_yes_tfidf, "Data/newseq_yes_tfidf.csv")
write_csv(newseq_yes_tfiidf_overall, 
  "Data/newseq_yes_tfiidf_overall.csv")