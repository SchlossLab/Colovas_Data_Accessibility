#!/usr/bin/env Rscript
#plot status of "more permanent hostname links" 
#
#library statements
library(tidyverse)


# load data from snakemake input
# {input.rscript} {input.all_links} {output.all_filename} {output.unique_filename}
input <- commandArgs(trailingOnly = TRUE)
alllinks <- input[1]
alllinks <- read_csv(alllinks)
output <- input[2]


#non-snakemake implementation
#alllinks <- read_csv("Data/linkrot/groundtruth.alllinks.csv.gz")
#metadatalinks <- read_csv("Data/linkrot/groundtruth.linksmetadata.csv.gz")
#output <- "Figures/linkrot/groundtruth/links_errorhostname.png"

#separate out only deadlinks
error_only <- filter(alllinks, link_status != 200)

#group links by link_status
tally <- error_only %>%
        group_by(hostname) %>% 
        tally()
sum <- as.numeric(sum(tally$n)) 

#add graphing name too
error_count <-
  error_only %>% 
      count(hostname, link_status) %>%
      mutate(fancy_name = paste0(hostname, "\n(", `n`, ")"))


error_only_hostname <- 
  ggplot(
    data = error_count, 
    mapping = aes(y = fancy_name, x = `n`, shape = factor(link_status))
  ) + 
  geom_point(size = 3) +
  labs( x = "Number of Links", 
        y = "Website Hostname",
        title = stringr::str_glue("Number of Dead External User-Added\nLinks by Hostname and Error Status (N={sum})"), 
        shape = "Link Status") +
scale_shape_discrete(labels = c("403 Forbidden", "404 Not Found", "429 Too Many Requests"))
error_only_hostname

ggsave(error_only_hostname, filename = output)

