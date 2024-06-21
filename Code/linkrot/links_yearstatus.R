#!/usr/bin/env Rscript
#linkrot figure generator for number of links by year by their status
#
#
#library statements
library(tidyverse)

# load data from snakemake input
# {input.rscript} {input.all_links} {input.metadata_links} {output.filename}
input <- commandArgs(trailingOnly = TRUE)
alllinks <- input[1]
alllinks <- read_csv(alllinks) %>% unique()
metadatalinks <- input[2]
metadatalinks <- read_csv(metadatalinks)
output <- input[3]

#non-snakemake implementation
#alllinks <- read_csv("Data/linkrot/groundtruth_alllinks.csv.gz") %>% unique()
#metadatalinks <- read_csv("Data/linkrot/groundtruth_links_metadata.csv.gz")
#all_output <- "Figures/linkrot/groundtruth/alllinks_bystatus.png"

all_with_meta <- left_join(alllinks, metadatalinks, 
                            by = join_by("paper" == "paper_doi"),
                            relationship = "many-to-one")

year_tally <- all_with_meta %>% 
                  group_by(year.published, link_status) %>% 
                  tally()
sum <- as.numeric(sum(year_tally$n)) 

LinksByYearAndStatus <- 
  ggplot(
    data = unique(all_with_meta), 
    mapping = aes(x = year.published, fill = as.factor(link_status))
  ) + 
  geom_bar(stat = "count") +
  theme(axis.text.x = element_text(angle = 75, vjust = 1, hjust=1)) +
  labs( y = "Number of Manuscripts Containing Links", 
        x = "Year Published",
        title = stringr::str_glue("Number of External User-Added Links by Year and Status (N={sum})"), 
        fill = "Link Status") 
LinksByYearAndStatus

ggsave(LinksByYearAndStatus, filename = output)