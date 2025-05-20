#!/usr/bin/env Rscript
#plot status of "more permanent hostname links" 
#
#
#library statements
library(tidyverse)


# load data from snakemake input
# {input.rscript} {input.all_links} {output.all_filename} {output.unique_filename}
input <- commandArgs(trailingOnly = TRUE)
linkrot <- read_csv(input[1])
output <- input[2]


# local testing
# linkrot <- read_csv("Data/final/linkrot_combined.csv.gz")



#group links by link_status
tally <- linkrot %>% 
          group_by(hostname) %>%
          tally()
sum <- as.numeric(sum(tally$n))

#filter for the long lasting links
# use ^asm = aka starts with asm 

long_lasting <- linkrot %>% 
    filter(str_detect(hostname, "^doi|^git|^figshare|^datadryad|^zenodo|^asm|^bitbucket")) %>%
    mutate(collapse_hostname = case_when(str_detect(hostname, "asm") ~ "asm", 
                                  str_detect(hostname, "doi") ~ "doi", 
                                  str_detect(hostname,"git") ~ "github",
                                  str_detect(hostname,"figshare") ~ "figshare",
                                  str_detect(hostname,"datadryad") ~ "datadryad",
                                  str_detect(hostname, "zenodo") ~ "zenodo",
                                  str_detect(hostname, "bitbucket") ~ "bitbucket",
                                  TRUE ~ "other") )

    
long_lasting <-
  long_lasting %>% 
    mutate(.by = collapse_hostname, 
          n_links = n(), 
          n_dead = sum(!is_alive),
          dead_fract = ((n_dead) / n_links), 
          )

#20250520 - save this for pat 
# write_csv(long_lasting, file =  "Data/final/long_lasting_links.csv")

# 20240731 - technically this has every single point still and not just one per hostname...
# doesn't actually work 

long_count <-
  long_lasting %>% 
    count(dead_fract, collapse_hostname) %>%
    mutate(fancy_name = paste0(str_to_title(collapse_hostname), "\n(", `n`, ")"))
      


  ggplot(
    data = long_count, 
    mapping = aes(x = dead_fract, 
                  y = fct_reorder(fancy_name, dead_fract))) + 
  geom_point(size = 2.5) +
  labs( x = "Fraction of Dead Links per Website Hostname (%)", 
        y = "Website Hostname (N)",
        title = stringr::str_glue("Percentage of Dead External User-Added Links\nby Hostname and Status for 'Long-Lasting' Hostnames (N={unique_sum})")) +
  scale_x_continuous(labels = scales::percent) 


ggsave(filename = unique_output)
