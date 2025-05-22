#!/usr/bin/env Rscript
# working on negative binomial regression
#
#library statements 
library(tidyverse)
library(MASS)
library(emmeans)


#load metadata
metadata <- read_csv("Data/final/predictions_with_metadata.csv.gz")

#get the year published out of as many of these as possible
metadata <- metadata %>% 
    mutate(year.published = dplyr::case_when((is.na(pub_date) & !is.na(issued) & is.na(publishYear)) ~ str_sub(issued, start = 1, end = 4), 
                        (!is.na(pub_date) & is.na(issued) & is.na(publishYear)) ~ as.character(pub_year), 
                        (is.na(pub_date) & is.na(issued) & !is.na(publishYear)) ~ as.character(publishYear), 
                        FALSE ~ NA_character_), 
          issued.date = ymd(issued, truncated = 2) %||% ymd(pub_date, truncated = 2), 
          is.referenced.by.count = ifelse(!is.na(is.referenced.by.count), is.referenced.by.count, `citedby-count`))

#from latest scrape date!
metadata <- metadata %>% 
  mutate(age.in.months = interval(metadata$issued.date, ymd("2025-02-10")) %/% months(1))


#pat said start with one journal - let's try jvi 
nsd_yes_metadata <- 
  metadata %>% 
    filter(nsd == "Yes" & journal_abrev == "jvi") %>%
    mutate(da_factor = factor(da)) 


jvi<-glm.nb(is.referenced.by.count~0+da + age.in.months, data = nsd_yes_metadata, link = log)
#let's try and graph it 
emmeans(jvi ~ da * age.in.months)
