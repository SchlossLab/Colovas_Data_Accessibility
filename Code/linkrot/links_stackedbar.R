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


alive_by_total <- read_csv("Data/linkrot/groundtruth_alllinks.csv.gz") %>%
        mutate(is_alive = link_status == 200) %>%
        select(paper, link_text, is_alive) %>%
        distinct() %>% 
        count(paper, is_alive) %>%
        pivot_wider(names_from = is_alive, values_from = n,
                    values_fill = 0) %>%
        mutate(n_total = `FALSE` + `TRUE`, 
                f_alive = `TRUE`/n_total)

alive_by_total %>%
    ggplot(aes(x = factor(n_total), y = f_alive)) +
    geom_jitter()

#try and simplify the code, try not to bring in more dfs than you need
#downside is that we don't have data for papers with 0 links
#is a paper with 0 links truly "alive/dead"
#for area plot - think about how you're going to structure the splitting
#for this we don't have a t/f it's a proportion
#categorical version of f_alive? all dead, partial, all alive
# proportion >0.5 mostly active/dead? 
# f_alive for number of papers

# you have to have all values of true for all values of x
# can force that with factoring and not dropping in the count
#companion plot with histogram 
alive_by_total %>%
    filter(n_total <= 5) %>%
    mutate(`TRUE` = factor(`TRUE`, levels = 0:max(`TRUE`))) %>%
    count(n_total, `TRUE`, .drop = FALSE) %>%
    mutate(n_fract = n/sum(n), .by = n_total) %>%
    ggplot(aes(x = n_total, y = n_fract, fill = `TRUE`)) +
    geom_area()

#histogram 
#in general probably chop off at 5 links ish 
alive_by_total %>%
    select(paper, n_total) %>%
    distinct() %>%
    ggplot(aes(x = n_total)) +
    geom_histogram()


alive_by_total %>%
    filter(n_total <= 2) %>%
    group_by(n_total, `TRUE`) %>%
    
    summarize(n = sum(n_total)) %>%
    mutate(percentage = n/sum(n)) %>%
    #bind_rows(tibble(n_total = 1, `TRUE` = 2, n  = 0, percentage = 0)) %>%
    ggplot(aes(x= n_total, y = percentage, fill = factor(`TRUE`))) +
    geom_area()
    

#example code from https://r-graph-gallery.com/136-stacked-area-chart
# time <- as.numeric(rep(seq(1,7),each=7))  # x Axis
# value <- runif(49, 10, 100)               # y Axis
# group <- rep(LETTERS[1:7],times=7)        # group, one shape per group
# data <- data.frame(time, value, group)

# data <- data  %>%
#   group_by(time, group) %>%
#   summarise(n = sum(value)) %>%
#   mutate(percentage = n / sum(n))
