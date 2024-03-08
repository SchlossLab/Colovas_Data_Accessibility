# text statistics summary figures
#
#
#library statements 
library(tidyverse)

#read in data, group by paper
gt_ss30_tfidf <- read_csv("Data/gt_ss30_tfidf.csv")
gt_ss30_tfidf <- group_by(gt_ss30_tfidf, paper)
gt_ss30_tfidf_overall <- read_csv("Data/gt_ss30_tfidf_overall.csv")

#grab the top 3 words for each of the papers, and then the top 93 overall
top_gtss30 <- top_n(gt_ss30_tfidf, 3, tf_idf)
top_gtss30_overall <- top_n(gt_ss30_tfidf_overall, 93, tf_idf)

#this part doesn't work, i want to compare the two lists 
top_words_gtss30 <- tibble(top_gtss30) %>% sort()
top_words_gtss30_overall <- tibble(top_gtss30_overall) %>% sort()
equal <- inner_join(top_words_gtss30, top_words_gtss30_overall, by = word)

