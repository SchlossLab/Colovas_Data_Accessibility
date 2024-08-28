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

add_zeros <-
  tibble("year.published" = c(2013, 2014), 
          "n" = c(0, 0))
      
year_tally_zeros <-
    rbind(year_tally, add_zeros) 

sum <- as.numeric(sum(year_tally$n)) 

# there are only links in papers from 2011-2023
LinksByYear <- 
  ggplot(
    data = year_tally_zeros, 
    mapping = aes(x = as.numeric(year.published), y = `n`)) + 
  geom_line(stat = "identity", linewidth = 1) +
  scale_x_continuous(breaks = c(2011, 2015, 2020, 2023), 
                   labels = c(2011, 2015, 2020, 2023)) +
  labs( y = "Number of Manuscripts Containing Links", 
        x = "Year Published",
        title = stringr::str_glue("Number of ASM Manuscripts by Year Containing 1+ External Links\nAdded by User (N={sum})")) 
LinksByYear


ggsave(LinksByYear, filename = output)