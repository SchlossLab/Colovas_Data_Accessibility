#!/usr/bin/env Rscript
#linkrot figure generator for number of links by journal
#
#
#library statements
library(tidyverse)

# load data from snakemake input
# {input.rscript} {input.metadata_links} {output.filename}
input <- commandArgs(trailingOnly = TRUE)
metadatalinks <- input[1]
output <- input[2]

#non-snakemake implementation
#alllinks <- read_csv("Data/linkrot/groundtruth_alllinks.csv.gz")
#metadatalinks <- read_csv("Data/linkrot/groundtruth_links_metadata.csv.gz")
#output <- "Figures/linkrot/groundtruth/LinksByJournal.png"


#group articles by the journal they were found in
journal_tally <- metadatalinks %>% 
                  dplyr::group_by(container.title) %>% 
                  dplyr::add_tally()
sum <- as.numeric(sum(journal_tally$n)) 

#plot number of articles containing links by which journal they were in 
LinksByJournal <- 
  ggplot(
    data = metadatalinks, 
    mapping = aes(x = container.title)
  ) + 
  geom_bar(stat = "count") +
  theme(axis.text.x = element_text(angle = 75, vjust = 1, hjust=1)) +
  labs( y = "Number of Manuscripts Containing Links", 
        x = "ASM Journal",
        title = stringr::str_glue("Number of ASM Manuscripts Containing 1+ External Links Added by User (N={sum})"))
#LinksByJournal

ggsave(LinksByJournal, filename = output)
