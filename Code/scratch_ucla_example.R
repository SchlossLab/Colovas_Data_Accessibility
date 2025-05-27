#ucla example with https://stats.oarc.ucla.edu/r/dae/negative-binomial-regression/
#
#
# library statements
library(tidyverse)
library(ggplot2)
library(MASS)
library(foreign) #dubs i had this one installed, must be part of stomething else

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


nsd_yes_metadata <- 
  metadata %>% 
    filter(nsd == "Yes") %>%
    mutate(da_factor = factor(da)) 

dat <- nsd_yes_metadata %>% 
    filter(container.title == "Journal of Virology")

dat <- within(dat, {
    da_factor <- factor(da)
    is.referenced.by_factor <- factor(is.referenced.by.count)
})

summary(dat)

#mean referenced by count has a loner right tail in da = no than yes
ggplot(dat, aes(x = is.referenced.by.count, fill = da_factor)) + 
    geom_histogram() + 
    facet_grid(da_factor ~ ., margins = TRUE, scales = "free")

# overall plot looks more like the combination of the two conditions
#da = yes has a long tail for older papers, and da = no has fewer recent papers
ggplot(dat, aes(x = age.in.months, fill = da_factor)) + 
    geom_histogram() + 
    facet_grid(da_factor ~ ., margins = TRUE, scales = "free")


# look at the mean and SD of the data 
with(dat, tapply(is.referenced.by.count, da_factor, function(x) {
    paste0("ref mean/sd ", mean(x, na.rm = TRUE), "/", sd(x, na.rm = TRUE)) }

))

mean(dat$is.referenced.by.count)
?mean
