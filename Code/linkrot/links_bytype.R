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
unique_output <- input[2]

#non-snakemake implementation
#alllinks <- read_csv("Data/linkrot/groundtruth.alllinks.csv.gz")
#metadatalinks <- read_csv("Data/linkrot/groundtruth.linksmetadata.csv.gz")


# 20240730 - we only care about unique links 

#group links by link_status
unique_type_tally <- distinct(alllinks) %>% 
                      group_by(website_type) %>%
                      tally()
unique_sum <- as.numeric(sum(unique_type_tally$n))

# only unique links
distinct <- distinct(alllinks)

#get count data per website_type
distinct <-
  distinct %>% 
    mutate(.by = website_type, 
          n_links = n(), 
          n_dead = sum(!is_alive),
          dead_fract = ((n_dead) / n_links), 
          )
#add graphing name too
distinct_count <-
  distinct %>% 
      count(dead_fract, website_type) %>%
      mutate(fancy_name = paste0(str_to_title(website_type), "\n(", `n`, ")"))
  

#create plot
UniqueLinkType <- 
  ggplot(
    data = distinct_count, 
    mapping = aes(y = fct_reorder(fancy_name, -dead_fract),  
      x = dead_fract)
  ) + 
    geom_point(size = 2.5) +
  labs( x = "Fraction of Dead Links per Website Domain Name",
        y = "Domain Type (N)",
        title = stringr::str_glue("Percentage of Unique External User-Added Links by Domain Type\nand Status (N={unique_sum})"), 
        ) +
scale_x_continuous(labels = scales::percent)
UniqueLinkType

ggsave(UniqueLinkType, filename = unique_output)