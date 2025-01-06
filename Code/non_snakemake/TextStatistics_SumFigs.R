# text statistics summary figures
#
#
#library statements 
library(tidyverse)

create_topwords_fig <- function(filename, nwords, xmax, ymax) {
  #read in data for group overall
  tfidf_overall <- read_csv(str_glue("Data/{filename}_tfidf_overall.csv"))
  
  # top 100 overall
  topN_overall <- top_n(tfidf_overall, nwords, tf_idf)
  
  #graph word, n occurrences(x), vs tf-idf(y)? 
  topWords <- 
    ggplot(data = topN_overall, aes(x = n, y = tf_idf, label = word)) +
    geom_point(position="jitter") +
    labs(x = "Number of occurrences of word",
         y = "Inverse document frequency(higher=more value)", 
         title = str_glue("Predictive value of word in {filename}"))
  
  topWords_withLabs <- topWords + 
    geom_text(size = 2, nudge_y = 0.01 ) 
  ggsave(topWords_withLabs, filename = str_glue("Figures/topWords_{filename}.png"))
  
  topWords_zoom <- topWords + 
    geom_text(size = 2, nudge_y = 0.001 ) +
    coord_cartesian(xlim = c(NA, xmax), ylim = c(NA, ymax))
  
  topWords_zoom
  ggsave(topWords_zoom, filename = str_glue("Figures/topWords_Zoom_{filename}.png"))
}


#dataset_names <- c("availability_no", "availability_yes", 
#"gt", "newseq_no", "newseq_yes", "gt_ss30")


create_topwords_fig("availability_no", 100, 150, 0.3)
create_topwords_fig("availability_yes", 100, 100, 0.15)
create_topwords_fig("gt", 200, 150, 0.3)
create_topwords_fig("gt_ss30", 100, 100, 0.1)
create_topwords_fig("newseq_no", 100, 150, 0.35)
create_topwords_fig("newseq_yes", 100, 100, 0.225)



