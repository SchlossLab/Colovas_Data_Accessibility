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

#compare the two lists, join for a list of all words in common, and then full_join for all stats
top_words_gtss30 <- tibble(word_list = top_gtss30$word)
top_words_gtss30_overall <- tibble(word_list = top_gtss30_overall$word)
equal <- inner_join(top_words_gtss30, top_words_gtss30_overall, relationship = "many-to-many")
full_stats <- full_join(top_gtss30, top_gtss30_overall, by = join_by("word"), keep = TRUE, relationship = "many-to-many")

#graph word, n occurrences(x), vs tf-idf(y)? 
topWords_gtss30 <- 
  ggplot(data = full_stats, aes(x = n.y, y = tf_idf.y, label = word.y)) +
  geom_point(position="jitter") +
  geom_text(size = 2, nudge_y = 0.005 ) +
  labs(x = "Number of occurrences of word",
       y = "Inverse document frequency(higher=more value)", 
       title = "Predictive value of word in 
random N=30 papers from groundtruth")
topWords_gtss30
ggsave(topWords_gtss30, filename = "Figures/topWords_gtss30.png" )

#turn this whole thing into a function call

create_topwords_fig <- function(filename) {
  #read in data for group overall
  filename_tfidf_overall <- read_csv("Data/filename_tfidf_overall.csv")
  
  #grab the top 3 words for each of the papers, and then the top 100 overall
  filename_overall <- top_n(filename_tfidf_overall, 100, tf_idf)
  
  #graph word, n occurrences(x), vs tf-idf(y)? 
  topWords_filename <- 
    ggplot(data = full_stats, aes(x = n, y = tf_idf, label = word)) +
    geom_point(position="jitter") +
    geom_text(size = 2, nudge_y = 0.005 ) +
    labs(x = "Number of occurrences of word",
         y = "Inverse document frequency(higher=more value)", 
         title = "Predictive value of word in filename")
  
  topWords_filename
  ggsave(topWords_filename, filename = "Figures/topWords_filename.png" )
}


#dataset_names <- c("availability_no", "availability_yes", "gt", "newseq_no", "newseq_yes", "gt_ss30")

#for (name in dataset_names){
#  create_topwords_fig(dataset_names[name])
#}

#need to fix this function so that it works for all of the figures
create_topwords_fig("availability_no")

#read in data for group overall
  filename_tfidf_overall <- read_csv("Data/availability_no_tfidf_overall.csv")
  
  #grab the top 3 words for each of the papers, and then the top 100 overall
  filename_overall <- top_n(filename_tfidf_overall, 100, tf_idf)
  
  #graph word, n occurrences(x), vs tf-idf(y)? 
  topWords <- 
    ggplot(data = full_stats, aes(x = n, y = tf_idf, label = word)) +
    geom_point(position="jitter") +
    geom_text(size = 2, nudge_y = 0.005 ) +
    labs(x = "Number of occurrences of word",
         y = "Inverse document frequency(higher=more value)", 
         title = "Predictive value of word in availability = No")
  
  topWords
  ggsave(topWords, filename = "Figures/availability_no_filename.png" )