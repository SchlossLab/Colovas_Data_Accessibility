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

# 20240730 - we only care about unique links 

#group links by link_status
unique_type_tally <- unique(alllinks) %>% 
                      group_by(hostname) %>%
                      tally()
unique_sum <- as.numeric(sum(unique_type_tally$n))



#20240730 - change to geom_point plot with percent alive/dead
# include N on the y axis 

distinct <- distinct(alllinks)
#plot status of "more permanent hostname links" 
long_lasting <- filter(distinct, 
                       grepl("doi|git|figshare|datadryad|zenodo|asm", hostname)) 

#get count data 
long_lasting <-
  long_lasting %>% 
    mutate(.by = paper, 
          n_links = n(), 
          n_dead = sum(!is_alive),
          dead_fract = ((n_dead) / n_links), 
          ) %>%
    select(paper, n_links, n_dead, dead_fract)



unique_long_lasting_status <- 
   ggplot(
    data = long_lasting, 
    mapping = aes(y = hostname, color = binary_status)
  ) + 
  geom_point(stat = "count") +
  labs( x = "Number of Links", 
        y = "Website Hostname",
        title = stringr::str_glue("Total Number of External User-Added Links\nby Hostname and Status (N={unique_sum})"), 
        fill = "Link Status") +
scale_color_manual(values = c("seagreen2", "indianred1"))

unique_long_lasting_status

ggsave(unique_long_lasting_status, filename = unique_output)
