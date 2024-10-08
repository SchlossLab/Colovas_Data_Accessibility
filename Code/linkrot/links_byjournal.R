#!/usr/bin/env Rscript
#linkrot figure generator for number of links by journal
#
#
#library statements
library(tidyverse)

# load data from snakemake input
# {input.rscript} {input.metadata_links} {output.filename}
input <- commandArgs(trailingOnly = TRUE)
alllinks <- input[1]
alllinks <- read_csv(alllinks)
metadatalinks <- input[2]
metadatalinks <- read_csv(metadatalinks)
output <- input[3]

#non-snakemake implementation
#alllinks <- read_csv("Data/linkrot/groundtruth.alllinks.csv.gz")
#metadatalinks <- read_csv("Data/linkrot/groundtruth.linksmetadata.csv.gz")
#output <- "Figures/linkrot/groundtruth/links_byjournal.png"


journal_tally <- unique(metadatalinks) %>%
  count(container.title)
  
sum <- sum(journal_tally$n)

journal_only <- select(metadatalinks, paper = paper_doi, container.title)

# do percentages of live/dead links by journal 
# 20240730 - we only care about unique links 
distinct <- 
    distinct(alllinks) %>% 
    left_join(., journal_only, by = "paper", relationship = "many-to-many")
    


#group links by link_status
unique_type_tally <- distinct %>% 
                      group_by(container.title) %>%
                      tally()
unique_sum <- as.numeric(sum(unique_type_tally$n))


#get count data per journal
distinct <-
  distinct %>% 
    mutate(.by = container.title, 
          n_links = n(), 
          n_dead = sum(!is_alive),
          dead_fract = ((n_dead) / n_links), 
          )

distinct_count <-
  distinct %>% 
      count(dead_fract, container.title) %>%
      mutate(fancy_name = paste0(container.title, "\n(", `n`, ")"))
      

  distinct_count$fancy_name <-
    map_chr(distinct_count$fancy_name, gsub, 
      pattern = "&amp;", 
      replacement = "&")


#plot number of articles containing links by which journal they were in
LinksByJournal <- 
  ggplot(
    data = distinct_count, 
    mapping = aes(x = dead_fract, 
                  y = fct_reorder(fancy_name, dead_fract))) + 
  geom_point(size = 2.5) +
  labs( x = "Fraction of Dead Links per Journal", 
        y = "ASM Journal",
        title = stringr::str_glue("Percentage of Unique External User-Added Links\nby Journal and Status (N={unique_sum})") 
      ) +
      scale_x_continuous(labels = scales::percent)
LinksByJournal

ggsave(LinksByJournal, filename = output)

