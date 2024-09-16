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
unique_output <- input[2]


#non-snakemake implementation
#alllinks <- read_csv("Data/linkrot/groundtruth.alllinks.csv.gz")
#metadatalinks <- read_csv("Data/linkrot/groundtruth.linksmetadata.csv.gz")
# unique_output <- "Figures/linkrot/groundtruth/alllinks_byhostname.png"

# 20240730 - we only care about unique links 

#group links by link_status
unique_type_tally <- distinct(alllinks) %>% 
                      group_by(hostname) %>%
                      tally()
unique_sum <- as.numeric(sum(unique_type_tally$n))



#20240730 - change to geom_point plot with percent alive/dead
# include N on the y axis 

distinct <- distinct(alllinks)
#plot status of "more permanent hostname links" 
long_lasting <- filter(distinct, 
                       grepl("doi|git|figshare|datadryad|zenodo|asm", hostname)) 

#get count data per hostname 
long_lasting <-
  long_lasting %>% 
    mutate(short_hostname = str_split_i(hostname, "\\.", -2)) 
    
long_lasting <-
  long_lasting %>% 
    mutate(.by = short_hostname, 
          n_links = n(), 
          n_dead = sum(!is_alive),
          dead_fract = ((n_dead) / n_links), 
          )

# 20240731 - technically this has every single point still and not just one per hostname...
# doesn't actually work 

long_count <-
  long_lasting %>% 
    count(dead_fract, short_hostname) %>%
    mutate(fancy_name = paste0(str_to_title(short_hostname), "\n(", `n`, ")"))
      

unique_long_lasting_status <- 
  ggplot(
    data = long_count, 
    mapping = aes(x = dead_fract, 
                  y = fct_reorder(fancy_name, dead_fract))) + 
  geom_point(size = 2.5) +
  labs( x = "Fraction of Dead Links per Website Hostname", 
        y = "Website Hostname (N)",
        title = stringr::str_glue("Percentage of Unique External User-Added Links\nby Hostname and Status for 'Long-Lasting' Hostnames (N={unique_sum})")) +
  scale_x_continuous(labels = scales::percent) 
unique_long_lasting_status

ggsave(unique_long_lasting_status, filename = unique_output)
