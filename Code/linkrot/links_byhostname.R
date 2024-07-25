#!/usr/bin/env Rscript
#plot status of "more permanent hostname links" 
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
#alllinks <- read_csv("Data/linkrot/groundtruth.alllinks.csv.gz")
#metadatalinks <- read_csv("Data/linkrot/groundtruth.linksmetadata.csv.gz")


#group links by link_status
all_type_tally <- alllinks %>%
                    group_by(hostname) %>% 
                    tally()
unique_type_tally <- unique(alllinks) %>% 
                      group_by(hostname) %>%
                      tally()
all_sum <- as.numeric(sum(all_type_tally$n)) 
unique_sum <- as.numeric(sum(unique_type_tally$n))


#plot status of "more permanent hostname links" 
long_lasting <- filter(alllinks, 
                       grepl("doi|git|figshare|datadryad|zenodo|asm", hostname))

all_long_lasting_status <- 
  ggplot(
    data = long_lasting, 
    mapping = aes(y = hostname, fill = binary_status)
  ) + 
  geom_bar(stat = "count") +
  labs( x = "Number of Links", 
        y = "Website Hostname",
        title = stringr::str_glue("Total Number of External User-Added Links\nby Hostname and Status (N={all_sum})"), 
        fill = "Link Status") +
scale_fill_manual(values = c("seagreen2", "indianred1"))
all_long_lasting_status

ggsave(all_long_lasting_status, filename = all_output)

unique_long_lasting_status <- 
   ggplot(
    data = unique(long_lasting), 
    mapping = aes(y = hostname, fill = binary_status)
  ) + 
  geom_bar(stat = "count") +
  labs( x = "Number of Links", 
        y = "Website Hostname",
        title = stringr::str_glue("Total Number of External User-Added Links\nby Hostname and Status (N={all_sum})"), 
        fill = "Link Status") +
scale_fill_manual(values = c("seagreen2", "indianred1"))

unique_long_lasting_status

ggsave(unique_long_lasting_status, filename = unique_output)
