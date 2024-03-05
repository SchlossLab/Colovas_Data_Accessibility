#linkrot figure generator 
#
#
#library statements
library(tidyverse)

#load needed files
groundtruth <- read_csv("Data/groundtruth.csv")
groundtruth_links <- read_csv("Data/groundtruth_links.csv")
groundtruth_linkcount <- read_csv("Data/groundtruth_linkcount.csv")

journal_tally <- groundtruth_linkcount %>% group_by(container.title) %>% tally()


LinksByJournal <- 
  ggplot(
    data = groundtruth_linkcount, 
    mapping = aes(x = container.title)
    ) + 
    geom_bar(stat = "count") +
    theme(axis.text.x = element_text(angle = 75, vjust = 1, hjust=1)) +
    labs( y = "Number of Manuscripts Containing Links", 
          x = "ASM Journal",
        title = "Number of ASM Manuscripts Containing 1+ 
        External Links Added by User (N=119)") 
LinksByJournal

