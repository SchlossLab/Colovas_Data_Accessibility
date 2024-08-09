#!/usr/bin/env Rscript
#linkrot figure generator for number of links by journal
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
#alllinks <- read_csv("Data/linkrot/groundtruth.alllinks.csv.gz")
#metadatalinks <- read_csv("Data/linkrot/groundtruth.linksmetadata.csv.gz")
#output <- "Figures/linkrot/groundtruth/links_byjournal.png"


journal_tally <- unique(metadatalinks) %>%
  count(container.title)
  
sum <- sum(journal_tally$n)

# 20240809 - i cannot for the life of me figure out how to make this work 
# journal_tally$container.title <-
# factor(journal_tally$container.title,
#     levels = c("Antimicrobial Agents and Chemotherapy",
#               "Journal of Bacteriology",
#               "Journal of Microbiology &amp; Biology Education",
#               "Microbiology Resource Announcements", 
#               "Journal of Clinical Microbiology", 
#               "Applied and Environmental Microbiology", 
#               "Infection and Immunity",
#               "Journal of Virology",
#               "mSphere",
#               "mBio",
#               "Microbiology Spectrum",
#               "mSystems"), 
#     labels = c("Antimicrobial Agents and Chemotherapy" = "Antimicrobial Agents\nand Chemotherapy",
#               "Journal of Bacteriology" = "Journal of Bacteriology",
#               "Journal of Microbiology &amp; Biology Education" = "Journal of Microbiology &\nBiology Education",
#               "Microbiology Resource Announcements" = "Microbiology Resource\nAnnouncements", 
#               "Journal of Clinical Microbiology" = "Journal of Clinical\nMicrobiology", 
#               "Applied and Environmental Microbiology"  = "Applied and Environmental\nMicrobiology", 
#               "Infection and Immunity" = "Infection and Immunity",
#               "Journal of Virology" = "Journal of Virology",
#               "mSphere" = "mSphere",
#               "mBio" = "mBio",
#               "Microbiology Spectrum" = "Microbiology Spectrum",
#               "mSystems" = "mSystems"))


#plot number of articles containing links by which journal they were in 
LinksByJournal <- 
  ggplot(
    data = journal_tally, 
    mapping = aes( x = `n`, y = factor(container.title))) + 
  geom_point(size = 2.5) +
  labs( x = "Number of Manuscripts Containing Links", 
        y = "ASM Journal",
        title = stringr::str_glue("Number of ASM Manuscripts Containing 1+ External Links\nAdded by User Separated by Journal (N={sum})"))
LinksByJournal

ggsave(LinksByJournal, filename = output)

