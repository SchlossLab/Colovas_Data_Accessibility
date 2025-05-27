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


#pat said start with one journal, but i think that i need to start with all of them 
nsd_yes_metadata <- 
  metadata %>% 
    filter(nsd == "Yes") %>%
    mutate(da_factor = factor(da)) 


interaction <-glm.nb(is.referenced.by.count~ da_factor * age.in.months, data = nsd_yes_metadata, link = log)

EMM <-emmeans(interaction, ~ da_factor * age.in.months)

con<-pairs(EMM, simple = "da_factor")
pairs(EMM, simple = "age.in.months")

contrast(con, "consec", by = NULL)

test(pairs(EMM, by = "age.in.months"), by = NULL, adjust = "mvt")


no_interaction <- update(interaction, . ~ da_factor + age.in.months)
#let's try and graph it 
summary(no_interaction)

pairs(interaction, simple = "da_factor")

emmeans(jvi ~ da * age.in.months)
