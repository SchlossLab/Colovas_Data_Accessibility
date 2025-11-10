#!/usr/bin/env Rscript
#summary figs for da/nsd


#library statements
library(tidyverse)

#import datasets
metadata <- read_csv(
"/Users/jocolova/Documents/Schloss/Colovas_Data_Accessibility/Data/final/predictions_with_metadata.csv.gz")

journal_table <-
metadata %>%
    select(container.title, journal_abrev) %>%
    unique() %>% 
    mutate(container.title = ifelse(str_detect(container.title, "&amp;"), 
            "Journal of Microbiology and Biology Education", container.title))



#summarize data
#whole dataset yay!
whole_dataset_table <-
metadata %>% 
    mutate(journal_abrev = ifelse(journal_abrev == "genomea", "mra", journal_abrev)) %>%
    count(journal_abrev, nsd, da) %>%
    na.omit() %>%
    complete(., journal_abrev, nsd, da, fill = list(`n` = 0L)) %>%
    mutate(.by = journal_abrev, 
               n_total = sum(`n`), 
           n_fract = (n_total/sum(.$`n`)))  %>% 
    filter(nsd == "Yes")  %>%
       mutate(.by = journal_abrev,
           n_nsd = sum(`n`), 
           fract_nsd = n_nsd/n_total) %>%
    filter(da == "Yes") %>% 
    mutate(.by = journal_abrev, 
          n_da = `n`, 
          fract_da = n_da/n_nsd) %>%
    select(journal_abrev, n_total:fract_da)


## whole dataset stats
n_total <- nrow(metadata)
all_per_nsd <- count(metadata, nsd) %>%
            mutate(percent = `n`/sum(`n`)*100) %>%
            .[[2, 3]]

all_per_da <- count(metadata, nsd, da) %>%
            filter(nsd == "Yes") %>%
            mutate(percent = `n`/sum(`n`)*100) %>%
            .[[2, 4]]


whole_dataset_table<- left_join(whole_dataset_table, journal_table, by = "journal_abrev")

# graphs 

# whole_fract_nsd <- 
    ggplot(whole_dataset_table, aes(x = fract_nsd, y = container.title)) + 
        geom_point()  +
        labs(title = "New sequencing data by ASM journal",
        x = "Percentage of papers with new sequencing data", 
        y = "ASM Journal"
        ) + 
      scale_x_continuous(labels = scales::percent)  

# whole_fract_da <- 
    ggplot(whole_dataset_table, aes(x = fract_da, y = container.title)) + 
        geom_point() + 
         labs(title = "New seqeuncing data papers with\ndata availability by ASM journal",
        x = "Percentage of new sequencing papers with data available", 
        y = "ASM Journal" 
        ) + 
      scale_x_continuous(labels = scales::percent)


# ok now to do this by time 

time_dataset_table <-
metadata %>% 
    mutate(journal_abrev = ifelse(journal_abrev == "genomea", "mra", journal_abrev)) %>%
    count(journal_abrev, nsd, da, year.published) %>%
    na.omit() %>%
    complete(., journal_abrev, nsd, da, year.published, fill = list(`n` = 0L)) %>%
    mutate(.by = c(year.published, journal_abrev),
               n_total = sum(`n`), 
           n_fract = (n_total/sum(.$`n`)))  %>% 
    filter(nsd == "Yes")  %>%
       mutate(.by = journal_abrev,
           n_nsd = sum(`n`), 
           fract_nsd = n_nsd/n_total) %>%
    filter(da == "Yes") %>% 
    mutate(.by = journal_abrev, 
          n_da = `n`, 
          fract_da = n_da/n_nsd)


#these fractions aren't quite right and i need to come back to this tomorrow 

ggplot(time_dataset_table, aes(y = fract_nsd, x = year.published)) + 
        geom_point()  + 
        facet_wrap(vars(journal_abrev))
    #     labs(title = "New sequencing data by ASM journal",
    #     x = "Percentage of papers with new sequencing data", 
    #     y = "ASM Journal"
    #     ) + 
    #   scale_x_continuous(labels = scales::percent)  

# head(time_dataset_table)
