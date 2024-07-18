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
metadatalinks <- read_csv(metadatalinks)
output <- input[2]

#non-snakemake implementation
#alllinks <- read_csv("Data/linkrot/groundtruth.alllinks.csv.gz")
#metadatalinks <- read_csv("Data/linkrot/groundtruth.linksmetadata.csv.gz")
#output <- "Figures/linkrot/groundtruth/links_byjournal.png"


#group articles by the journal they were found in
# journal_tally <- unique(metadatalinks) %>% 
#                   group_by(container.title) %>% 
#                   add_tally()


journal_tally <- unique(metadatalinks) %>%
  count(container.title)

sum <- sum(journal_tally$n)

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
        title = stringr::str_glue("Number of ASM Manuscripts Containing 1+ External Links\nAdded by User (N={sum})"))
LinksByJournal

ggsave(LinksByJournal, filename = output)


# what if i do it as a line graph? 
journal_tally %>%
  ggplot(aes(x = container.title)) +
  geom_bar(stat_count = `n`)
