#!/usr/bin/env Rscript
#linkrot figure generator for number of links by journal
#
#
#library statements
library(tidyverse)

# load data from snakemake input
# {input.rscript} {input.metadata_links} {output.filename}
input <- commandArgs(trailingOnly = TRUE)
linkrot <- read_csv(input[1])
lookup_table <- read_csv(input[2])
output <- input[3]

#non-snakemake implementation
linkrot <- read_csv("Data/final/linkrot_combined.csv.gz")
lookup_table <-read_csv("Data/all_dois_lookup_table.csv.gz")
# head(lookup_table)



linkrot_lookup<-left_join(linkrot, lookup_table, by = "html_filename",
          relationship = "many-to-one", multiple = "any")


journal_tally <- linkrot_lookup %>%
  count(journal_abrev)
  
sum <- sum(journal_tally$n)

#20250520 - why aren't there the right number of journals using container.title vs journal_abrev???
#why so many nas? 

#group links by link_status
type_tally <- journal_tally %>% 
                      group_by(container.title) %>%
                      tally()
# sum <- as.numeric(sum(unique_type_tally$n))


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
      count(dead_fract, container.title) %>%
      mutate(fancy_name = paste0(container.title, "\n(", `n`, ")"))
      

  distinct_count$fancy_name <-
    map_chr(distinct_count$fancy_name, gsub, 
      pattern = "&amp;", 
      replacement = "&")


#plot number of articles containing links by which journal they were in
LinksByJournal <- 
  ggplot(
    data = distinct_count, 
    mapping = aes(x = dead_fract, 
                  y = fct_reorder(fancy_name, dead_fract))) + 
  geom_point(size = 2.5) +
  labs( x = "Fraction of Dead Links per Journal", 
        y = "ASM Journal",
        title = stringr::str_glue("Percentage of Unique External User-Added Links\nby Journal and Status (N={unique_sum})") 
      ) +
      scale_x_continuous(labels = scales::percent)
LinksByJournal

ggsave(LinksByJournal, filename = output)

