#scratch_openfiles.R
#
#opening files
#library
library(tidyverse)

import_pre<-read_csv("Data/final/predicted_results.csv.gz")
view(import_pre)

import_pre %>% 
    count(da, nsd) %>% 
    mutate(prop = (`n`/sum(`n`))*100)


metadata<-read_csv("Data/final/predictions_with_metadata.csv.gz")
head(metadata)
colnames(metadata)

metadata <- metadata %>% 
    mutate(year.published = dplyr::case_when((is.na(pub_date) & !is.na(issued) & is.na(publishYear)) ~ str_sub(issued, start = 1, end = 4), 
                        (!is.na(pub_date) & is.na(issued) & is.na(publishYear)) ~ as.character(pub_year), 
                        (is.na(pub_date) & is.na(issued) & !is.na(publishYear)) ~ as.character(publishYear), 
                        FALSE ~ NA_character_), 
          issued.date = ymd(issued, truncated = 2) %||% ymd(pub_date, truncated = 2), 
          is.referenced.by.count = ifelse(!is.na(is.referenced.by.count), is.referenced.by.count, `citedby-count`))

metadata <- metadata %>% 
  mutate(age.in.months = interval(metadata$issued.date, ymd("2025-01-01")) %/% months(1), 
    ref_count_log2 = log2(is.referenced.by.count + 0.01))

select(final_results_cscar, c(paper.x, da, nsd, doi journal_abrev, container.title, ))