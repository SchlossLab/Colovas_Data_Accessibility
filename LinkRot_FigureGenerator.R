#linkrot figure generator 
#
#
#library statements
library(tidyverse)

#load needed files
groundtruth <- read_csv("Data/groundtruth.csv")
groundtruth_links <- read_csv("Data/groundtruth_links.csv")
groundtruth_linkcount <- read_csv("Data/groundtruth_linkcount.csv")

#group articles by the journal they were found in
journal_tally <- groundtruth_linkcount %>% group_by(container.title) %>% tally()

#plot number of articles containing links by which journal they were in 
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

ggsave(LinksByJournal, filename = "Figures/LinksByJournal.png")

#group links by link_status
status_tally <- groundtruth_links %>% group_by(link_status) %>% tally()

#plot number of links with each status
LinksByStatus <- 
  ggplot(
    data = groundtruth_links, 
    mapping = aes(x = factor(link_status)) ) + 
  geom_bar() +
  geom_text(stat = "count", aes(label = after_stat(count)), vjust = 1.2, color = "white", size = 3) +
  theme(axis.text.x = element_text(angle = 75, vjust = 1, hjust=1)) +
  labs( y = "Number of Links", 
        x = "Link Status",
        title = "Number of External User-Added  
        Links by Status (N=270)") 
LinksByStatus

ggsave(LinksByStatus, filename = "Figures/LinksByStatus.png")
