#!/usr/bin/env Rscript
#data acessibility prelim figures work 
#
#
#
#library statements
library(tidyverse)

#load metadata
metadata <- read_csv("Data/final/predictions_with_metadata.csv.gz")

which(!is.na(metadata$pub_date))
which(is.na(metadata$issued))

#get the year published out of as many of these as possible
metadata <- metadata %>% 
    mutate(year.published = dplyr::case_when((is.na(pub_date) & !is.na(issued) & is.na(publishYear)) ~ str_sub(issued, start = 1, end = 4), 
                        (!is.na(pub_date) & is.na(issued) & is.na(publishYear)) ~ as.character(pub_year), 
                        (is.na(pub_date) & is.na(issued) & !is.na(publishYear)) ~ as.character(publishYear), 
                        FALSE ~ NA_character_))

metadata %>%
  count(year.published) %>%
  print(n = Inf)

#find out how many don't have one of those 3 n = 429
# metadata %>%
#   filter(is.na(pub_date) & is.na(issued) & is.na(publishYear)) %>%
#   view()

#these are the columns i want for the data 
# year.published - done 20250320 
# need to do age.in.months, and citation number for those that have it 
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
  select(c(paper, doi, da, nsd, year.published)) %>%  
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

