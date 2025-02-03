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
    mutate(year.published = str_sub(issued, start = 1, end = 4), 
            years.since.published = (2024-as.numeric(year.published)), 
             citations.per.year = (is.referenced.by.count/years.since.published), 
             issued.date = ymd(issued, truncated = 2))
metadata <- metadata %>% 
  mutate(months.since.y2k = interval(ymd("2000-01-01"), metadata$issued.date) %/% months(1), 
          age.in.months = interval(metadata$issued.date, ymd("2025-01-01")) %/% months(1))

colnames(metadata)

metadata %>% count(container.title)

#20250203 - how many mra papers are there from 2024? 
metadata %>% 
  filter(year.published == 2024 & container.title == "Microbiology Resource Announcements" & nsd == "Yes", da == "No") %>% 
  write_csv(file = "Data/spot_check/mra_2024_nsd_yes_da_no.csv")


#modeling using time intervals
summary(lm(is.referenced.by.count~da + nsd + months.since.y2k, data = metadata))
summary(lm(is.referenced.by.count~ 0 + da + nsd + age.in.months, data = metadata))

#modeling with nsd yes only data
nsd_yes_metadata <- 
  metadata %>% 
    filter(nsd == "Yes")

summary(lm(is.referenced.by.count~0+da + age.in.months, data = nsd_yes_metadata))


#number of papers over time

metadata %>% 
    count(year.published) %>% 
    ggplot(mapping = aes(y = `n`, 
                    x = year.published)) + 
    geom_point() + 
    labs(x = "Year Published", 
        y = "Number of Papers", 
        title = "Number of Papers Published \nEach Year in ASM Journals 2000-2024")


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
        title = "Number of Papers Published Each Year \nContaining New Sequeunce Data in \nASM Journals 2000-2024")

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
        title = "Number of Papers Published Each Year \nContaining Available Data in \nASM Journals 2000-2024")

# number of citations by nsd status (and then probs by year) "is.referenced.by.count"
metadata %>%  
    filter(!is.na(nsd)) %>% 
    ggplot(mapping = aes(x = nsd,
                        y = is.referenced.by.count)) + 
    geom_boxplot() + 
    ylim(0,100) + 
    labs(x = "Contains New Sequence Data?", 
         y = "Number of Times Referenced", 
         title = "Number of Times Referenced by \nContains New Sequencing Data Status")

#by year
metadata %>%  
    filter(!is.na(nsd) & !is.na(year.published)) %>% 
    ggplot(mapping = aes(fill = nsd,
                        x = year.published,
                        y = is.referenced.by.count)) + 
    geom_boxplot() + 
    ylim(0,200) + 
    labs(y = "Number of Times Referenced", 
         x = "Year Published", 
         title = "Number of Times Referenced by New \nSequencing Data Status and Year Published", 
         fill = "Does this Contain \nNew Sequencing Data?")



# number of citations by da status (and then probs by year)

  metadata %>%
    filter(!is.na(da)) %>% 
    ggplot(mapping = aes(x = da,
                        y = is.referenced.by.count)) + 
    geom_boxplot() + 
    ylim(0,100) + 
    labs(x = "Is Data Available?", 
         y = "Number of Times Referenced", 
         title = "Number of Times Referenced \nby Data Availability Status")

#by year
metadata %>%  
    filter(!is.na(da) & !is.na(year.published)) %>% 
    ggplot(mapping = aes(fill = da,
                        x = year.published,
                        y = is.referenced.by.count)) + 
    geom_boxplot() + 
    ylim(0,200) + 
    labs(y = "Number of Times Referenced", 
         x = "Year Published", 
         title = "Number of Times Referenced by Data \nAvailability Status and Year Published", 
         fill = "Is Data \nAvailable?")



#do avg citations per year by nsd/da status
metadata %>%  
    filter(!is.na(nsd) & !is.na(year.published)) %>% 
    ggplot(mapping = aes(x = nsd,
                        y = citations.per.year)) + 
    geom_boxplot() + 
    ylim(0,15) + 
    labs(x = "Does this Contain New Sequencing Data?", 
         y = "Average Number of Times Referenced/Year", 
         title = "Average Number of Times Referenced/Year \nby New Sequencing Data Status")

#da
metadata %>%  
    filter(!is.na(da) & !is.na(year.published)) %>% 
    ggplot(mapping = aes(x = da,
                        y = citations.per.year)) + 
    geom_boxplot() + 
    ylim(0,15)  + 
  labs(x = "Is Data Available?", 
       y = "Average Number of Times Referenced/Year", 
       title = "Average Number of Times Referenced/Year \nby Data Availability Status")



#over time 
#nsd
metadata %>%  
    filter(!is.na(nsd) & !is.na(year.published)) %>% 
    ggplot(mapping = aes(fill = nsd,
                        x = year.published,
                        y = citations.per.year)) + 
    geom_boxplot() + 
    ylim(0,15)  + 
  labs(fill = "Does this Contain \nNew Sequencing Data?", 
       x = "Year Published",
       y = "Average Number of Times Referenced/Year", 
       title = "Average Number of Times Referenced/Year \nby New Sequencing Data Status")

#da
metadata %>%  
    filter(!is.na(da) & !is.na(year.published)) %>% 
    filter(nsd == "Yes") %>% 
    ggplot(mapping = aes(fill = da,
                        x = year.published,
                        y = citations.per.year)) + 
    geom_boxplot() + 
    ylim(0,15)   + 
  labs(fill = "Is Data \nAvailable?", 
       x = "Year Published",
       y = "Average Number of Times Referenced/Year", 
       title = "Average Number of Times Referenced/Year \nby Data Availability Status")

