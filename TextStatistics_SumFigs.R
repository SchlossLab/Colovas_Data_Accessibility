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
  tfidf_overall <- read_csv(str_glue("Data/{filename}_tfidf_overall.csv"))
  
  # top 100 overall
  top100_overall <- top_n(tfidf_overall, 100, tf_idf)
  
  #graph word, n occurrences(x), vs tf-idf(y)? 
  topWords <- 
    ggplot(data = top100_overall, aes(x = n, y = tf_idf, label = word)) +
    geom_point(position="jitter") +
    geom_text(size = 2, nudge_y = 0.005 ) +
    labs(x = "Number of occurrences of word",
         y = "Inverse document frequency(higher=more value)", 
         title = str_glue("Predictive value of word in {filename}"))
  
  topWords
  ggsave(topWords, filename = str_glue("Figures/topWords_{filename}.png"))
}



#dataset_names <- c("availability_no", "availability_yes", 
#"gt", "newseq_no", "newseq_yes", "gt_ss30")


create_topwords_fig("availability_no")
create_topwords_fig("availability_yes")
create_topwords_fig("newseq_no")
create_topwords_fig("newseq_yes")
create_topwords_fig("gt")

