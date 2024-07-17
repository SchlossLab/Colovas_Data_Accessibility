#!/usr/bin/env Rscript
#linkrot figure generator for number of links by status
#
#
#library statements
library(tidyverse)

# 20240717 - we're actually just not going to worry about this right now
# i'll worry about it later on my own 
# load data from snakemake input
# {input.rscript} {input.all_links} {output.all_filename} {output.unique_filename}
# input <- commandArgs(trailingOnly = TRUE)
# alllinks <- input[1]
# alllinks <- read_csv(alllinks)
# all_output <- input[2]
# unique_output <- input[3]


# non-snakemake implementation
alllinks <- read_csv("Data/linkrot/groundtruth_alllinks.csv.gz")
# metadata links has unique_link_count column
metadatalinks <- read_csv("Data/linkrot/groundtruth_links_metadata.csv.gz")
groundtruth <- read_csv("Data/groundtruth.csv")
# all_output <- "Figures/linkrot/groundtruth/alllinks_bystatus.png"
# unique_output <- "Figures/linkrot/groundtruth/uniquelinks_bystatus.png"

# alllinks %>% 
#     mutate(
#       binary_status = ifelse(link_status == 200, "Alive", "Dead")
#       )


# metadatalinks %>% count(unique_link_count)

# metadatalinks %>% 
#     full_join(groundtruth, by = join_by("paper_doi" == "paper")) %>%
#     select(paper_doi, unique_link_count) %>%
#     left_join(alllinks, by = join_by("paper_doi" == "paper")) %>%
#     mutate(is_alive = link_status == 200) %>%
#     select(paper_doi, unique_link_count, is_alive) %>%
#     mutate(unique_link_count = replace_na(unique_link_count, 0), 
#             is_alive = replace_na(is_alive, TRUE)) %>%
#     head()


read_csv("Data/linkrot/groundtruth_alllinks.csv.gz") %>%
        mutate(is_alive = link_status == 200) %>%
        select(paper, link_text, is_alive) %>%
        distinct() %>% 
        count(paper, is_alive) %>%
        pivot_wider(names_from = is_alive, values_from = n,
                    values_fill = 0) %>%
        mutate(n_total = `FALSE` + `TRUE`, 
                f_alive = `TRUE`/n_total)





