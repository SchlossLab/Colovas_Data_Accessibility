#!/usr/bin/env Rscript
# working on negative binomial regression
#
#library statements 
library(tidyverse)
library(MASS)
# library(emmeans)
library(jtools)



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


interaction <-glm.nb(is.referenced.by.count~ da_factor + age.in.months + da_factor * age.in.months, data = nsd_yes_metadata, link = log)
# no_interaction <-glm.nb(is.referenced.by.count~ da_factor + age.in.months, data = nsd_yes_metadata, link = log)
# three_terms_no_int <-glm.nb(is.referenced.by.count~ da_factor + age.in.months + container.title, data = nsd_yes_metadata, link = log)
# three_terms_int <-glm.nb(is.referenced.by.count~ da_factor + age.in.months + container.title + da_factor*container.title, data = nsd_yes_metadata, link = log)
three_terms_int_all <-glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + container.title + 
      log(age.in.months)*da_factor*container.title, data = nsd_yes_metadata, link = log)

three_terms_int_all <-glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + container.title + 
      + container.title*da_factor + log(age.in.months)*da_factor + container.title*log(age.in.months) + 
       log(age.in.months)*da_factor*container.title, data = nsd_yes_metadata, link = log)
three_terms_0 <-glm.nb(is.referenced.by.count~ 1+ da_factor + log(age.in.months) + container.title + 
      log(age.in.months)*da_factor*container.title, data = nsd_yes_metadata, link = log)
three_sqrt <-glm.nb(is.referenced.by.count~ da_factor + sqrt(age.in.months) + container.title + 
      sqrt(age.in.months)*da_factor*container.title, data = nsd_yes_metadata, link = log)
inverse <-glm.nb(is.referenced.by.count~ da_factor + 1/age.in.months + container.title + 
      1/age.in.months*da_factor*container.title, data = nsd_yes_metadata, link = log)
jtools::summ(interaction)
summ(three_sqrt)
summ(inverse)
# jtools::summ(no_interaction)
# jtools::summ(three_terms_no_int)
# jtools::summ(three_terms_int)
jtools::summ(three_terms_int_all)

#i actually want to see if i filter these better if the models make more sense 
jvi <- nsd_yes_metadata %>% 
  filter(journal_abrev == "jvi")

iai <- nsd_yes_metadata %>% 
  filter(journal_abrev == "iai")

msys <- nsd_yes_metadata %>% 
  filter(journal_abrev == "msystems")


jvi_interaction <-glm.nb(is.referenced.by.count~ da_factor + age.in.months, data = jvi, link = log)
jvi_interaction_2 <-glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + da_factor*log(age.in.months), data = jvi, link = log)
jtools::summ(jvi_interaction)

msys_interaction <-glm.nb(is.referenced.by.count~ da_factor + age.in.months, data = msys, link = log)
msys_interaction_2 <-glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + da_factor*log(age.in.months), data = msys, link = log)
jtools::summ(msys_interaction_2)


iai_interaction <-glm.nb(is.referenced.by.count~ da_factor + age.in.months, data = iai, link = log)
iai_interaction_2 <-glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + da_factor*log(age.in.months), data = iai, link = log)
jtools::summ(iai_interaction_2)

#graphing with jtools 

plot_1<-jtools::effect_plot(interaction, da_factor, plot.points = TRUE)
jtools::effect_plot(interaction, age.in.months, plot.points = TRUE)
plot_2<-effect_plot(three_terms_int_all, age.in.months, interval = TRUE, int.type = "confidence", 
                    int.width = 0.8, plot.points = TRUE, data = nsd_yes_metadata, line.colors = "blue", 
                    outcome.scale = "link")

plot_2_no_points<-effect_plot(three_terms_0, age.in.months, interval = TRUE, int.type = "confidence", 
                    int.width = 0.8, data = nsd_yes_metadata, line.colors = "blue", 
                    outcome.scale = "link")

plot_3<-effect_plot(three_terms_int_all, da_factor, interval = TRUE, int.type = "confidence", 
                    int.width = 0.8, plot.points = TRUE, data = nsd_yes_metadata, line.colors = "blue", 
                    outcome.scale = "link")
ggsave(plot_2, file = "Figures/test_2.png")
ggsave(plot_2_no_points, file = "Figures/test_nopoints_2.png")
ggsave(plot_3, file = "Figures/test_3.png")


