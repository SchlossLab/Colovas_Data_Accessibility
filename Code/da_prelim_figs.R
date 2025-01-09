#!/usr/bin/env Rscript
#data acessibility prelim figures work 
#
#
#
#library statements
library(tidyverse)

#import data 
# predicted_files <-read_csv("Data/final/predicted_results.csv.gz")
# head(predictions)

# lookup_table <-read_csv("Data/papers/lookup_table.csv.gz")
# head(lookup_table)

# joined_predictions <- full_join(predicted_files, lookup_table, by = join_by("file" == "html_filename")) 
# head(joined_predictions)

# papers_dir <- "Data/papers"
# csv_files <- list.files(papers_dir, "*.csv", full.names = TRUE) 

# keep_track<-tibble()
# for(i in 1:12) {
#     csv_file <- read_csv(csv_files[i])
#     #this does it for the current journal to join with all_papers
#     all_papers <- left_join(csv_file, joined_predictions) %>%
#         mutate_if(is.double, as.character, .vars = "issue") %>%
#         mutate_if(lubridate::is.Date, as.character, .vars = "created")
#     keep_track<-bind_rows(keep_track, all_papers)
   
# }

# write_csv(keep_track, file = "Data/final/predictions_with_metadata.csv.gz")

metadata <- read_csv("Data/final/predictions_with_metadata.csv.gz")

#now we can start doing the fun graphing part

# make column for date published (issued) 
metadata <- metadata %>% 
    mutate(year.published = str_sub(issued, start = 1, end = 4))



#number of papers over time

metadata %>% 
    count(year.published) %>% 
    ggplot(mapping = aes(y = `n`, 
                    x = year.published)) + 
    geom_point() + 
    labs(x = "Year Published", 
        y = "Number of Papers", 
        title = "Number of Papers Published Each Year in ASM Journals 2000-2024")


#number of nsd papers over time 
metadata %>% 
    count(year.published, nsd) %>% 
    ggplot(mapping = aes(y = `n`, 
                    x = as.numeric(year.published), 
                    color = nsd)) + 
    geom_line(stat = "identity") + 
    labs(x = "Year Published", 
        y = "Number of Papers",
        color = "New Sequencing \nData Available",
        title = "Number of Papers Published Each Year Containing New Sequeunce Data in ASM Journals 2000-2024")

#number of da papers over time 
metadata %>% 
    count(year.published, da) %>% 
    ggplot(mapping = aes(y = `n`, 
                    x = as.numeric(year.published), 
                    color = da)) + 
    geom_line(stat = "identity") + 
    labs(x = "Year Published", 
        y = "Number of Papers",
        color = "Was Data Available?",
        title = "Number of Papers Published Each Year Containing Available Data in ASM Journals 2000-2024")

# number of citations by nsd status (and then probs by year) "is.referenced.by.count"
metadata %>%  
    filter(!is.na(nsd)) %>% 
    ggplot(mapping = aes(x = nsd,
                        y = is.referenced.by.count)) + 
    geom_boxplot() + 
    ylim(0,100)

#by year
metadata %>%  
    filter(!is.na(nsd) & !is.na(year.published)) %>% 
    ggplot(mapping = aes(fill = nsd,
                        x = year.published,
                        y = is.referenced.by.count)) + 
    geom_boxplot() + 
    ylim(0,200)



# number of citations by da status (and then probs by year)

metadata %>% 
    #count(is.referenced.by.count, nsd) %>% 
    filter(!is.na(da)) %>% 
    ggplot(mapping = aes(x = da,
                        y = is.referenced.by.count)) + 
    geom_boxplot() + 
    ylim(0,100)

#by year
metadata %>%  
    filter(!is.na(da) & !is.na(year.published)) %>% 
    ggplot(mapping = aes(fill = da,
                        x = year.published,
                        y = is.referenced.by.count)) + 
    geom_boxplot() + 
    ylim(0,200)
