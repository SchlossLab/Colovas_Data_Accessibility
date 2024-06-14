#!/usr/bin/env Rscript
#linkrot figure generator 
#
#
#library statements
library(tidyverse)

# load data from snakemake input
# {input.rscript} {input.all_links} {input.metadata_links}
input <- commandArgs(trailingOnly = TRUE)
alllinks <- input[1]
metadatalinks <- input[2]

#load needed files
groundtruth <- read_csv("Data/groundtruth.csv")
groundtruth_links <- read_csv("Data/linkrot/groundtruth_links.csv")
groundtruth_linkcount <- read_csv("Data/linkrot/groundtruth_linkcount.csv")
gt_all_links_with_metadata <- read_csv("Data/linkrot/gt_all_links_with_metadata.csv")

#group articles by the journal they were found in
journal_tally <- groundtruth_linkcount %>% group_by(container.title) %>% tally()

# 20240614 - moved to links_byjournal.R
# #plot number of articles containing links by which journal they were in 
# LinksByJournal <- 
#   ggplot(
#     data = groundtruth_linkcount, 
#     mapping = aes(x = container.title)
#     ) + 
#     geom_bar(stat = "count") +
#     theme(axis.text.x = element_text(angle = 75, vjust = 1, hjust=1)) +
#     labs( y = "Number of Manuscripts Containing Links", 
#           x = "ASM Journal",
#         title = "Number of ASM Manuscripts Containing 1+ 
#         External Links Added by User (N=119)") 
# LinksByJournal
# 
# ggsave(LinksByJournal, filename = "Figures/LinksByJournal.png")

#group links by link_status
status_tally <- groundtruth_links %>% group_by(link_status) %>% tally()

#plot number of links with each status
LinksByStatus <- 
  ggplot(
    data = groundtruth_links, 
    mapping = aes(x = factor(link_status)) ) + 
  geom_bar() +
  geom_text(stat = "count", aes(label = after_stat(count)), vjust = 1.2, color = "white", size = 3) +
  theme(axis.text.x = element_text(angle = 75, vjust = 1, hjust=1)) +
  labs( y = "Number of Links", 
        x = "Link Status",
        title = "Number of External User-Added  
        Links by Status (N=270)") 
LinksByStatus

ggsave(LinksByStatus, filename = "Figures/LinksByStatus.png")

#plot number of articles containing links by year published 
LinksByYear <- 
  ggplot(
    data = groundtruth_linkcount, 
    mapping = aes(x = year.published)
  ) + 
  geom_bar(stat = "count") +
  theme(axis.text.x = element_text(angle = 75, vjust = 1, hjust=1)) +
  labs( y = "Number of Manuscripts Containing Links", 
        x = "Year Published",
        title = "Number of ASM Manuscripts Containing 1+ 
        External Links Added by User (N=119)") 
LinksByYear

ggsave(LinksByYear, filename = "Figures/LinksByYear.png")

#plot number of articles containing links by year published 
LinksByYearAndStatus <- 
  ggplot(
    data = gt_all_links_with_metadata, 
    mapping = aes(x = year.published, fill = as.factor(link_status))
  ) + 
  geom_bar(stat = "count") +
  theme(axis.text.x = element_text(angle = 75, vjust = 1, hjust=1)) +
  labs( y = "Number of Manuscripts Containing Links", 
        x = "Year Published",
        title = "Number of External User-Added  
        Links by Year and Status (N=270)", 
        fill = "Link Status") 
LinksByYearAndStatus

ggsave(LinksByYearAndStatus, filename = "Figures/LinksByYearAndStatus.png")


#plot type of link 
LinkType <- 
  ggplot(
    data = groundtruth_links, 
    mapping = aes(x = website_type, fill = as.factor(link_status))
  ) + 
  geom_bar(stat = "count") +
  theme(axis.text.x = element_text(angle = 75, vjust = 1, hjust=1)) +
  labs( y = "Number of External User-Added Links", 
        x = "Year Published",
        title = "Number of External User-Added  
        Links by Domain Type and Status (N=270)", 
        fill = "Link Status") 
LinkType

ggsave(LinkType, filename = "Figures/link_type_status.png")

#plot hostame of deadlinks
error_only <- filter(gt_all_links_with_metadata, link_status != 200)

error_only_hostname <- 
  ggplot(
    data = error_only, 
    mapping = aes(y = hostname, fill = as.factor(link_status))
  ) + 
  geom_bar(stat = "count") +
  labs( x = "Number of Links", 
        y = "Website Hostname",
        title = "Number of External User-Added  
        Links by Hostname and Status (N=29 of 270)", 
        fill = "Link Status") 
error_only_hostname

ggsave(error_only_hostname, filename = "Figures/error_only_hostname.png")


#plot status of "more permanent hostname links" 
long_lasting <- filter(gt_all_links_with_metadata, 
                       grepl("doi|git|figshare|datadryad|zenodo|asm", hostname))

long_lasting_status <- 
  ggplot(
    data = long_lasting, 
    mapping = aes(y = hostname, fill = as.factor(link_status))
  ) + 
  geom_bar(stat = "count") +
  labs( x = "Number of Links", 
        y = "Website Hostname",
        title = "Number of External User-Added  
        Links by Hostname and Status (N=109)", 
        fill = "Link Status") 
long_lasting_status

ggsave(long_lasting_status, filename = "Figures/long_lasting_status.png")
