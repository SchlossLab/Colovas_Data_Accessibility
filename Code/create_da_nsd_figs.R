#!/usr/bin/env Rscript
#summary figs for da/nsd

# get file input from snakemake
input <- commandArgs(trailingOnly = TRUE)
metadata <- read_csv(input[1])

#library statements
library(tidyverse)

#import datasets (local )
# metadata <- read_csv(
# "/Users/jocolova/Documents/Schloss/Colovas_Data_Accessibility/Data/final/predictions_with_metadata.csv.gz")

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

whole_dataset_table<- left_join(whole_dataset_table, journal_table, by = "journal_abrev")


# ## whole dataset stats
# n_total <- nrow(metadata)
# all_per_nsd <- count(metadata, nsd) %>%
#             mutate(percent = `n`/sum(`n`)*100) %>%
#             .[[2, 3]]

# all_per_da <- count(metadata, nsd, da) %>%
#             filter(nsd == "Yes") %>%
#             mutate(percent = `n`/sum(`n`)*100) %>%
#             .[[2, 4]]




# graphs 

fract_nsd <- 
    ggplot(whole_dataset_table, aes(x = fract_nsd, y = container.title)) + 
        geom_point()  +
        labs(title = "New sequencing data by ASM journal",
        x = "Percentage of papers with new sequencing data", 
        y = "ASM Journal"
        ) + 
      scale_x_continuous(labels = scales::percent)  

ggsave("Figures/summary_stats/fract_nsd.png", plot = fract_nsd)

fract_da <- 
    ggplot(whole_dataset_table, aes(x = fract_da, y = container.title)) + 
        geom_point() + 
         labs(title = "New seqeuncing data papers with\ndata availability by ASM journal",
        x = "Percentage of new sequencing papers with data available", 
        y = "ASM Journal" 
        ) + 
      scale_x_continuous(labels = scales::percent)
ggsave("Figures/summary_stats/fract_da.png", plot = fract_da)

# ok now to do this by time 

time_dataset_table <-
metadata %>% 
    mutate(journal_abrev = ifelse(journal_abrev == "genomea", "mra", journal_abrev)) %>%
    count(journal_abrev, nsd, da, year.published) %>%
    na.omit() %>%
    complete(., journal_abrev, nsd, da, year.published, fill = list(`n` = 0L)) %>%
    mutate( .by = c(year.published, journal_abrev),
               n_total = sum(`n`), 
           n_fract = (`n`/n_total))  %>% 
    filter(nsd == "Yes")  %>%
       mutate(.by = c(year.published, journal_abrev),
           n_nsd = sum(`n`), 
           fract_nsd = n_nsd/n_total) %>%
    filter(da == "Yes") %>% 
    mutate(.by = c(year.published, journal_abrev), 
          n_da = `n`, 
          fract_da = n_da/n_nsd)

time_dataset_table<- left_join(time_dataset_table, journal_table, by = "journal_abrev")


#these fractions aren't quite right and i need to come back to this tomorrow 
time_nsd <- 
ggplot(time_dataset_table, aes(y = fract_nsd, x = year.published)) + 
        geom_line()  + 
        facet_wrap(vars(container.title), 
        labeller = label_wrap_gen(width = 18)) +
        labs(title = "New sequencing data by ASM journal and year",
        y = "Percentage of papers with new sequencing data", 
        x = "Year Published"
        ) + 
        scale_y_continuous(labels = scales::percent)  

ggsave("Figures/summary_stats/time_nsd.png", plot = time_nsd)

time_da <-
ggplot(time_dataset_table, aes(y = fract_da, x = year.published)) + 
        geom_line()  + 
        facet_wrap(vars(container.title), 
        labeller = label_wrap_gen(width = 18)) +
        labs(title = "New sequencing data with data available by ASM journal and year",
        y = "Percentage of papers with new sequencing data\nand data available", 
        x = "Year Published"
        ) + 
        scale_y_continuous(labels = scales::percent)  

ggsave("Figures/summary_stats/time_da.png", plot = time_da)
