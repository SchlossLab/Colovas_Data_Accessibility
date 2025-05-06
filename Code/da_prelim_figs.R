#!/usr/bin/env Rscript
#data acessibility prelim figures work 
#
#
#
#library statements
library(tidyverse)
library(MASS)

#load metadata
metadata <- read_csv("Data/final/20250423/20250423_predictions_with_metadata.csv.gz")

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


#modeling using time intervals -------------------------------------------------------------------------------
# summary(lm(is.referenced.by.count~da + nsd + months.since.y2k, data = metadata))

#without 0 intercept 
summary(lm(is.referenced.by.count~ da + nsd + age.in.months, data = metadata))
#with 0 intercept 
summary(lm(is.referenced.by.count~ 0 + da + nsd + age.in.months, data = metadata))



#modeling with nsd yes only data #482 without is.referenced.by.count
nsd_yes_metadata <- 
  metadata %>% 
    filter(nsd == "Yes")

summary(lm(is.referenced.by.count~da + age.in.months, data = nsd_yes_metadata))
summary(lm(is.referenced.by.count~0+da + age.in.months, data = nsd_yes_metadata))

nsd_yes_da_factor <- 
nsd_yes_metadata %>%
  mutate(da_factor = factor(da))

#factored da 
# summary(lm(is.referenced.by.count~+da + age.in.months, data = nsd_yes_da_factor))
summary(lm(is.referenced.by.count~0+da_factor + age.in.months, data = nsd_yes_da_factor))

# summary(lm(is.referenced.by.count~+da + da:age.in.months, data = nsd_yes_da_factor))
summary(lm(is.referenced.by.count~0+da_factor + da_factor:age.in.months, data = nsd_yes_da_factor))

#summary(lm(is.referenced.by.count~0+da_factor + da_factor*age.in.months, data = nsd_yes_da_factor))


# #using negative binomial regression
# summary(glm.nb(is.referenced.by.count~0+da + age.in.months, data = nsd_yes_da_factor))

# summary(glm.nb(is.referenced.by.count~0+da + da:age.in.months, data = nsd_yes_da_factor))
#statistical models end --------------------------------------------------------------------------------------


#is.referenced.by.count~0+da_factor + da_factor:age.in.months, data = nsd_yes_da_factor
#graphing of the model data
nsd_yes_da_factor %>%
  ggplot(aes(x = age.in.months, 
            y = is.referenced.by.count, 
            color = da_factor)) + 
  geom_point(alpha = 0.5, size = 0.2) + 
  geom_smooth(method = "lm", formula = y ~ 0 + x, se = TRUE) + 
  coord_cartesian(ylim = c(0, 200)) #doesn't remove the data before stats 


ggsave(filename = "Figures/lm_by_da.jpg")

#20250327 - mob 
library(Hmisc) #new package for stats
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


colnames(nsd_yes_da_factor)

#looking for specific papers
nsd_yes_da_factor %>%
filter(is.referenced.by.count > 1000 & container.title == "mSystems" & da == "No") %>% 
view()




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



# #do avg citations per year by nsd/da status
# metadata %>%  
#     filter(!is.na(nsd) & !is.na(year.published)) %>% 
#     ggplot(mapping = aes(x = nsd,
#                         y = citations.per.year)) + 
#     geom_boxplot() + 
#     ylim(0,15) + 
#     labs(x = "Does this Contain New Sequencing Data?", 
#          y = "Average Number of Times Referenced/Year", 
#          title = "Average Number of Times Referenced/Year \nby New Sequencing Data Status")

# #da
# metadata %>%  
#     filter(!is.na(da) & !is.na(year.published)) %>% 
#     ggplot(mapping = aes(x = da,
#                         y = citations.per.year)) + 
#     geom_boxplot() + 
#     ylim(0,15)  + 
#   labs(x = "Is Data Available?", 
#        y = "Average Number of Times Referenced/Year", 
#        title = "Average Number of Times Referenced/Year \nby Data Availability Status")



# #over time 
# #nsd
# metadata %>%  
#     filter(!is.na(nsd) & !is.na(year.published)) %>% 
#     ggplot(mapping = aes(fill = nsd,
#                         x = year.published,
#                         y = citations.per.year)) + 
#     geom_boxplot() + 
#     ylim(0,15)  + 
#   labs(fill = "Does this Contain \nNew Sequencing Data?", 
#        x = "Year Published",
#        y = "Average Number of Times Referenced/Year", 
#        title = "Average Number of Times Referenced/Year \nby New Sequencing Data Status")

# #da
# metadata %>%  
#     filter(!is.na(da) & !is.na(year.published)) %>% 
#     filter(nsd == "Yes") %>% 
#     ggplot(mapping = aes(fill = da,
#                         x = year.published,
#                         y = citations.per.year)) + 
#     geom_boxplot() + 
#     ylim(0,15)   + 
#   labs(fill = "Is Data \nAvailable?", 
#        x = "Year Published",
#        y = "Average Number of Times Referenced/Year", 
#        title = "Average Number of Times Referenced/Year \nby Data Availability Status")

