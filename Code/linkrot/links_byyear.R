#!/usr/bin/env Rscript
#linkrot figure generator for number of links by year
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
#alllinks <- read_csv("Data/linkrot/groundtruth_alllinks.csv.gz")
#metadatalinks <- read_csv("Data/linkrot/groundtruth_links_metadata.csv.gz")
#all_output <- "Figures/linkrot/groundtruth/alllinks_bystatus.png"
#unique_output <- "Figures/linkrot/groundtruth/uniquelinks_bystatus.png"

#group articles by the year they were published
year_tally <- metadatalinks %>% 
                  group_by(year.published) %>% 
                  tally()
sum <- as.numeric(sum(year_tally$n)) 

LinksByYear <- 
  ggplot(
    data = metadatalinks, 
    mapping = aes(x = year.published)
  ) + 
  geom_bar(stat = "count") +
  theme(axis.text.x = element_text(angle = 75, vjust = 1, hjust=1)) +
  labs( y = "Number of Manuscripts Containing Links", 
        x = "Year Published",
        title = stringr::str_glue("Number of ASM Manuscripts Containing 1+ External Links Added by User (N={sum})")) 
LinksByYear

ggsave(LinksByYear, filename = output)