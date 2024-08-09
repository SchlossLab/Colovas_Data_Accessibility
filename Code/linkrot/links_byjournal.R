#!/usr/bin/env Rscript
#linkrot figure generator for number of links by journal
#
#
#library statements
library(tidyverse)

# load data from snakemake input
# {input.rscript} {input.metadata_links} {output.filename}
input <- commandArgs(trailingOnly = TRUE)
alllinks <- input[1]
alllinks <- read_csv(alllinks)
metadatalinks <- input[2]
metadatalinks <- read_csv(metadatalinks)
output <- input[3]

#non-snakemake implementation
#alllinks <- read_csv("Data/linkrot/groundtruth.alllinks.csv.gz")
#metadatalinks <- read_csv("Data/linkrot/groundtruth.linksmetadata.csv.gz")
#output <- "Figures/linkrot/groundtruth/links_byjournal.png"


journal_tally <- unique(metadatalinks) %>%
  count(container.title)
  
sum <- sum(journal_tally$n)

journal_only <- select(metadatalinks, paper = paper_doi, container.title)

# do percentages of live/dead links by journal 
# 20240730 - we only care about unique links 
distinct <- 
    distinct(alllinks) %>% 
    left_join(., journal_only, by = "paper", relationship = "many-to-many")
    


#group links by link_status
unique_type_tally <- distinct %>% 
                      group_by(container.title) %>%
                      tally()
unique_sum <- as.numeric(sum(unique_type_tally$n))


#get count data per journal
distinct <-
  distinct %>% 
    mutate(.by = container.title, 
          n_links = n(), 
          n_dead = sum(!is_alive),
          dead_fract = ((n_dead) / n_links), 
          )

distinct_count <-
  distinct %>% 
      count(dead_fract, container.title) 

# 20240809 - i cannot for the life of me figure out how to make this work 
# distinct_count$container.title <-
# factor(journal_tally$container.title,
#     levels = c("Antimicrobial Agents and Chemotherapy",
#               "Applied and Environmental Microbiology",
#               "Infection and Immunity",
#               "Journal of Bacteriology",
#               "Journal of Clinical Microbiology", 
#               "Journal of Microbiology &amp; Biology Education",
#               "Journal of Virology",
#               "mBio",
#               "Microbiology Resource Announcements", 
#               "Microbiology Spectrum",
#               "mSphere",
#               "mSystems"), 
#     labels = c("Antimicrobial Agents and Chemotherapy" = "Antimicrobial Agents\nand Chemotherapy\n(2)",
#               "Applied and Environmental Microbiology"  = "Applied and Environmental\nMicrobiology\n(8)", 
#               "Infection and Immunity" = "Infection and Immunity\n(5)",
#               "Journal of Bacteriology" = "Journal of Bacteriology\n(8)",
#               "Journal of Clinical Microbiology" = "Journal of Clinical\nMicrobiology\n(4)", 
#               "Journal of Microbiology &amp; Biology Education" = "Journal of Microbiology &\nBiology Education\n(9)",
#               "Journal of Virology" = "Journal of Virology\n(1)",
#               "mBio" = "mBio\n(34)",
#               "Microbiology Resource Announcements" = "Microbiology Resource\nAnnouncements\n(37)",
#               "Microbiology Spectrum" = "Microbiology Spectrum\n(59)", 
#               "mSphere" = "mSphere\n(20)",
#               "mSystems" = "mSystems\n(85)"))


#plot number of articles containing links by which journal they were in 
LinksByJournal <- 
  ggplot(
    data = distinct_count, 
    mapping = aes(x = dead_fract, y = factor(container.title))) + 
  geom_point(size = 2.5) +
  labs( x = "Fraction of Dead Links per Journal", 
        y = "ASM Journal",
        title = stringr::str_glue("Percentage of Unique External User-Added Links\nby Journal and Status (N={unique_sum})") 
      ) +
      scale_x_continuous(labels = scales::percent)
LinksByJournal

ggsave(LinksByJournal, filename = output)

