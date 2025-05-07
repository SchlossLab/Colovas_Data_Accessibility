#!/usr/bin/env Rscript
#data acessibility prelim figures work 
#
#
#
#library statements
library(tidyverse)
library(MASS)
library(Hmisc) #new package for stats in the first graph

# get file input from snakemake
input <- commandArgs(trailingOnly = TRUE)
metadata <- read_csv(input[1])


# local data
# metadata <- read_csv("Data/final/20250423/20250423_predictions_with_metadata.csv.gz")

#getting the right metadata variables
#get the year published out of as many of these as possible
metadata <- metadata %>% 
    mutate(year.published = dplyr::case_when((is.na(pub_date) & !is.na(issued) & is.na(publishYear)) ~ str_sub(issued, start = 1, end = 4), 
                        (!is.na(pub_date) & is.na(issued) & is.na(publishYear)) ~ as.character(pub_year), 
                        (is.na(pub_date) & is.na(issued) & !is.na(publishYear)) ~ as.character(publishYear), 
                        FALSE ~ NA_character_), 
          issued.date = ymd(issued, truncated = 2) %||% ymd(pub_date, truncated = 2), 
          is.referenced.by.count = ifelse(!is.na(is.referenced.by.count), is.referenced.by.count, `citedby-count`))

metadata <- metadata %>% 
  mutate(age.in.months = interval(metadata$issued.date, ymd("2025-01-01")) %/% months(1))

nsd_yes_metadata <- 
  metadata %>% 
    filter(nsd == "Yes")

nsd_yes_da_factor <- 
nsd_yes_metadata %>%
  mutate(da_factor = factor(da))

#graph showing the rate of change over time for each journal
nsd_yes_da_factor %>%
  ggplot(aes(x = age.in.months, 
            y = is.referenced.by.count, 
            color = da_factor)) + 
  stat_summary(fun.data = "median_hilow", 
              fun.args = list(conf.int = 0.5), 
              linewidth = 0.1, size = 0.2) +
  #median_hilow = median center, line = 95%CI, conf.int = 0.5 gives iqr
  facet_wrap(~container.title, scales = "free_y") + 
  geom_smooth(method = "lm", formula = y ~ 0 + x, se = FALSE, linewidth = 2) 
ggsave(file = "Figures/citationrate_byjournal.png")


nsd_yes_metadata %>% 
  group_by(year.published, container.title) %>% 
  count(year.published, container.title, da) %>% 
  mutate(da_total = sum(`n`), 
         da_fract = `n`/da_total) %>%
 filter(da == "Yes") %>% 
  ggplot(aes(x = year.published, y = da_fract)) +
  geom_point(aes(size = da_total, alpha = .5)) +
  facet_wrap(vars(container.title),
             labeller = labeller(container.title = label_wrap_gen(14))) + 
  labs(x = "Year Published (2000-2024)", 
       y = "Fraction of Papers Containing New\nSequencing Data with Data Available", 
       title = "Fraction of Papers Containing New Sequencing Data\nwith Data Available Over 2020-2024 by ASM Journal") + 
  scale_x_discrete(breaks = c("2000", "2005", "2010", "2015", "2020")) 
  ggsave(filename = "Figures/nsdyes_da_2000_2024.png")