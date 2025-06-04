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
# three_terms_int_all <-glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + container.title + 
#       log(age.in.months)*da_factor*container.title, data = nsd_yes_metadata, link = log)

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


# 20250603 - after meeting with pat
# working on: 
# removing the top 1% of data and looking at model fit 
# truncating data at 5 years (60 mos) and 10 years (120 mos) and looking at model fit 
# looking at it by journals 

#double check that the number of rows is 1%/10% of the model data 
# removing the top 1% of data and looking at model fit 
no_1percent <-nsd_yes_metadata %>%
    filter(is.referenced.by.count < quantile(nsd_yes_metadata$is.referenced.by.count, 
                                              na.rm = TRUE, prob = 0.99))

#this model fits exactly the same with the top 1% removed R^2 = 0.68
all_terms_no_1percent <-glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + container.title + 
      + container.title*da_factor + log(age.in.months)*da_factor + container.title*log(age.in.months) + 
       log(age.in.months)*da_factor*container.title, data = no_1percent, link = log)

jtools::summ(all_terms_no_1percent)

#this model fits exactly the same with the top 10% removed R^2 = 0.67
no_10percent <-nsd_yes_metadata %>%
    filter(is.referenced.by.count < quantile(nsd_yes_metadata$is.referenced.by.count, 
                                              na.rm = TRUE, prob = 0.90))

all_terms_no_10percent <-glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + container.title + 
      + container.title*da_factor + log(age.in.months)*da_factor + container.title*log(age.in.months) + 
       log(age.in.months)*da_factor*container.title, data = no_10percent, link = log)

jtools::summ(all_terms_no_10percent)

# ok now let's look at cutting it off at 10 years (120 months)
ten_years <- 
  nsd_yes_metadata %>% 
    filter(age.in.months <= 120)

all_terms_ten_years <-glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + container.title + 
      + container.title*da_factor + log(age.in.months)*da_factor + container.title*log(age.in.months) + 
       log(age.in.months)*da_factor*container.title, data = ten_years, link = log)
#fits exactly the same - R^2 = 0.68 
jtools::summ(all_terms_ten_years)


#how about 5 years (60 months )
five_years <- 
  nsd_yes_metadata %>% 
    filter(age.in.months <= 60)

all_terms_five_years <-glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + container.title + 
      + container.title*da_factor + log(age.in.months)*da_factor + container.title*log(age.in.months) + 
       log(age.in.months)*da_factor*container.title, data = five_years, link = log)
#fits a little worse - R^2 = 0.66
jtools::summ(all_terms_five_years)


#ok let's look at this by journal - want to be able to get R^2 out of the model 
str(summ(all_terms_five_years))
pluck_exists(summary, "")
summary<- summ(all_terms_five_years)
unlisted <-unlist(summary)
str(summary)

pluck(summary, "model")
summary$model
attr(summary, "rsq")

journals <-nsd_yes_metadata %>%
  count(journal_abrev) %>% 
  filter(journal_abrev != "jmbe")

journals <-journals %>% 
  mutate(all_journal_data_rsq = NA, no_1percent_rsq = NA, five_years_rsq = NA, ten_years_rsq = NA)



for(i in 1:nrow(journals)) { 
  journal_data <- 
  nsd_yes_metadata %>% 
    filter(journal_abrev == journals[[i,1]])

  journal_fit <-glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + 
       + log(age.in.months)*da_factor + log(age.in.months)*da_factor, data = journal_data, link = log)
  
  journals$all_journal_data_rsq[i] <- jtools::summ(journal_fit) %>% attr(., "rsq")

  no_1percent  <-journal_data %>%
    filter(is.referenced.by.count < quantile(nsd_yes_metadata$is.referenced.by.count, 
                                              na.rm = TRUE, prob = 0.99))
  
  no_1p_fit <-glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + 
       + log(age.in.months)*da_factor + log(age.in.months)*da_factor, data =  no_1percent, link = log)
  
  journals$no_1percent_rsq[i]<-jtools::summ(no_1p_fit) %>% attr(., "rsq")

  five_years <-journal_data %>% 
    filter(age.in.months <= 60)
  if(nrow(five_years) > 0 ) {
  five_years_fit <-glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + 
       + log(age.in.months)*da_factor + log(age.in.months)*da_factor, data =  five_years, link = log)

    journals$five_years_rsq[i]<-jtools::summ(five_years_fit) %>% attr(., "rsq")
  } else {journals$five_years_rsq[i]<-NA}

  if(nrow(ten_years) > 0 ) {
  ten_years <-journal_data %>% 
    filter(age.in.months <= 120)

  ten_years_fit <-glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + 
       + log(age.in.months)*da_factor + log(age.in.months)*da_factor, data =  ten_years, link = log)
  
  journals$ten_years_rsq[i]<-jtools::summ(ten_years_fit) %>% attr(., "rsq")
  }
  else {journals$ten_years_rsq[i] <- NA}
print(i)
}


