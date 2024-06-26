#!/usr/bin/env Rscript
#linkrot figure generator for number of links by their status and website type
#
#
#library statements
library(tidyverse)


# load data from snakemake input
# {input.rscript} {input.all_links} {output.all_filename} {output.unique_filename}
input <- commandArgs(trailingOnly = TRUE)
alllinks <- input[1]
alllinks <- read_csv(alllinks)
all_output <- input[2]
unique_output <- input[3]

#non-snakemake implementation
#alllinks <- read_csv("Data/linkrot/groundtruth_alllinks.csv.gz")
#metadatalinks <- read_csv("Data/linkrot/groundtruth_links_metadata.csv.gz")


#group links by link_status
all_type_tally <- alllinks %>%
                    group_by(website_type) %>% 
                    tally()
unique_type_tally <- unique(alllinks) %>% 
                      group_by(website_type) %>%
                      tally()
all_sum <- as.numeric(sum(all_type_tally$n)) 
unique_sum <- as.numeric(sum(unique_type_tally$n))

#plot type of link 
AllLinkType <- 
  ggplot(
    data = alllinks, 
    mapping = aes(x = website_type, fill = as.factor(link_status))
  ) + 
  geom_bar(stat = "count") +
  theme(axis.text.x = element_text(angle = 75, vjust = 1, hjust=1)) +
  labs( y = "Number of External User-Added Links", 
        x = "Link Type",
        title = stringr::str_glue("Total Number of External User-Added Links by Domain Typ\nand Status (N={all_sum})"), 
        fill = "Link Status") 
AllLinkType

ggsave(AllLinkType, filename = all_output)

#plot type of link for only unique links
UniqueLinkType <- 
  ggplot(
    data = unique(alllinks), 
    mapping = aes(x = website_type, fill = as.factor(link_status))
  ) + 
  geom_bar(stat = "count") +
  theme(axis.text.x = element_text(angle = 75, vjust = 1, hjust=1)) +
  labs( y = "Number of External User-Added Links", 
        x = "Year Published",
        title = stringr::str_glue("Unique Number of External User-Added Links by Domain Type\nand Status (N={unique_sum})"), 
        fill = "Link Type") 
UniqueLinkType

ggsave(UniqueLinkType, filename = unique_output)