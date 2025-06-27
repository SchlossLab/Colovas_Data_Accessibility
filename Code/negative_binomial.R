#!/usr/bin/env Rscript
# working on negative binomial regression
#
#library statements 
library(tidyverse)
library(MASS)
# library(emmeans)
library(jtools)



#load metadata
nsd_yes_metadata <- read_csv("Data/final/nsd_yes_metadata.csv.gz")

#20250624 - when does the first citation appear in these data? 
first_citation <-
nsd_yes_metadata %>% 
  filter(is.referenced.by.count == 1) %>% 
  count(container.title, journal_abrev, age.in.months) %>% 
  summarize(first_citation = min(age.in.months, na.rm = TRUE), 
            .by = c(container.title, journal_abrev)) 


first_citation_noga <-
first_citation %>% 
  filter(journal_abrev != "genomea")
first_citation_mean <- mean(first_citation_noga$first_citation)



#20250627 - making a function for large model with all 3 terms 
three_term_glmnb <-function(model_data, model_name) {

  total_model <-glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + container.title + 
        + container.title*da_factor + log(age.in.months)*da_factor + container.title*log(age.in.months) + 
        log(age.in.months)*da_factor*container.title, data = model_data, link = log)

  coefficients <-jtools::summ(total_model)$model$coefficients %>% names() %>% tibble(coefficients = `.`)

  model_value <- jtools::summ(total_model)$model$coefficients %>% unname() %>% 
      tibble("{model_name}" := `.`) %>% 
      dplyr::select(!`.`)
    
  pvalue <-jtools::summ(total_model)$coeftable[,4]

  model_table <- tibble(coefficients, model_value, "{model_name}_pvalue" := pvalue)

  return(model_table)

}

# making a function for smaller model with 2 terms

#smaller model with 2 terms
two_term_glmnb <-function(model_data, model_name) {

  total_model <-glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + 
       + log(age.in.months)*da_factor + log(age.in.months)*da_factor, data = model_data, link = log)

  coefficients <-jtools::summ(total_model)$model$coefficients %>% names() %>% tibble(coefficients = `.`)

  model_value <- jtools::summ(total_model)$model$coefficients %>% unname() %>% 
      tibble("{model_name}" := `.`) %>% 
      dplyr::select(!`.`)

  pvalue <-jtools::summ(total_model)$coeftable[,4]

  model_table <- tibble(coefficients, model_value, "{model_name}_pvalue" := pvalue)

  return(model_table)

}

#models

#no journal variable
interaction <-glm.nb(is.referenced.by.count~ da_factor + age.in.months + da_factor * age.in.months, 
                      data = nsd_yes_metadata, link = log)

#all three interaction terms 
full <- three_term_glmnb(nsd_yes_metadata, "full")


#what happens if you create a whole model with an adjustment of the months
citation_adjustment <- 
  nsd_yes_metadata %>% 
  mutate(time_adj_all = (age.in.months - 5), 
        time_adj_all_no_negs = ifelse(time_adj_all <= 0, 1, time_adj_all), 
        age.in.months = time_adj_all_no_negs)

time_adj <- three_term_glmnb(citation_adjustment, "time_adj")


full_join(full, time_adj) %>% 
  write_csv(., file = "Data/negative_binomial/time_adjusted_model_comparison.csv")


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


#skip removal of top 1% 20250624 
# removing the top 1% of data and looking at model fit ---------------------------------------- 
# no_1percent <-nsd_yes_metadata %>%
#     filter(is.referenced.by.count < quantile(nsd_yes_metadata$is.referenced.by.count, 
#                                               na.rm = TRUE, prob = 0.99))

# #this model fits exactly the same with the top 1% removed R^2 = 0.68
# all_terms_no_1percent <-glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + container.title + 
#       + container.title*da_factor + log(age.in.months)*da_factor + container.title*log(age.in.months) + 
#        log(age.in.months)*da_factor*container.title, data = no_1percent, link = log)

# jtools::summ(all_terms_no_1percent)
# no_1percent_value <- jtools::summ(all_terms_no_1percent)$model$coefficients %>% unname() %>% 
#     tibble(no_1percent_value = `.`)

# no_1p_coefficients <-jtools::summ(all_terms_no_1percent)$model$coefficients %>% names() %>% tibble(coefficients = `.`)

# no_1p_model <- tibble(no_1p_coefficients, no_1percent_value)
# head(no_1p_model)

# ok now let's look exactly 1 year of data (12 months)
at_one_year <- 
  nsd_yes_metadata %>% 
    filter(age.in.months == 12)

all_terms_at_one_year <-glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + container.title + 
      + container.title*da_factor + log(age.in.months)*da_factor + container.title*log(age.in.months) + 
       log(age.in.months)*da_factor*container.title, data = at_one_year, link = log)

at_one_year_value <- jtools::summ(all_terms_at_one_year)$model$coefficients %>% unname() %>% 
    tibble(at_one_year_value = `.`)

at_one_year_coefficients <-jtools::summ(all_terms_at_one_year)$model$coefficients %>% names() %>% tibble(coefficients = `.`)

at_one_year_pvalue <-jtools::summ(all_terms_at_one_year)$coeftable[,4]

at_one_year_model <- tibble(at_one_year_coefficients, at_one_year_value, at_one_year_pvalue)

# ok now let's look at cutting it off at 10 years (120 months)
ten_years <- 
  nsd_yes_metadata %>% 
    filter(age.in.months <= 120)

all_terms_ten_years <-glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + container.title + 
      + container.title*da_factor + log(age.in.months)*da_factor + container.title*log(age.in.months) + 
       log(age.in.months)*da_factor*container.title, data = ten_years, link = log)

ten_years_value <- jtools::summ(all_terms_ten_years)$model$coefficients %>% unname() %>% 
    tibble(ten_years_value = `.`)

ten_years_coefficients <-jtools::summ(all_terms_ten_years)$model$coefficients %>% names() %>% tibble(coefficients = `.`)

ten_years_pvalue <-jtools::summ(all_terms_ten_years)$coeftable[,4]

ten_years_model <- tibble(ten_years_coefficients, ten_years_value, ten_years_pvalue)


# ok now let's look exactly 10 years of data (120 months)
at_ten_years <- 
  nsd_yes_metadata %>% 
    filter(age.in.months == 120)

all_terms_at_ten_years <-glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + container.title + 
      + container.title*da_factor + log(age.in.months)*da_factor + container.title*log(age.in.months) + 
       log(age.in.months)*da_factor*container.title, data = at_ten_years, link = log)

at_ten_years_value <- jtools::summ(all_terms_at_ten_years)$model$coefficients %>% unname() %>% 
    tibble(at_ten_years_value = `.`)

at_ten_years_coefficients <-jtools::summ(all_terms_at_ten_years)$model$coefficients %>% names() %>% tibble(coefficients = `.`)

at_ten_years_pvalue <-jtools::summ(all_terms_at_ten_years)$coeftable[,4]

at_ten_years_model <- tibble(at_ten_years_coefficients, at_ten_years_value, at_ten_years_pvalue)


#how about 5 years (60 months )
five_years <- 
  nsd_yes_metadata %>% 
    filter(age.in.months <= 60)

all_terms_five_years <-glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + container.title + 
      + container.title*da_factor + log(age.in.months)*da_factor + container.title*log(age.in.months) + 
       log(age.in.months)*da_factor*container.title, data = five_years, link = log)

five_years_value <- jtools::summ(all_terms_five_years)$model$coefficients %>% unname() %>% 
    tibble(five_years_value = `.`)

five_years_coefficients <-jtools::summ(all_terms_five_years)$model$coefficients %>% names() %>% tibble(coefficients = `.`)

five_years_pvalue <-jtools::summ(all_terms_five_years)$coeftable[,4]

five_years_model <- tibble(five_years_coefficients, five_years_value, five_years_pvalue)


# ok now let's look exactly 5 years of data (6- months)
at_five_years <- 
  nsd_yes_metadata %>% 
    filter(age.in.months == 60)

all_terms_at_five_years <-glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + container.title + 
      + container.title*da_factor + log(age.in.months)*da_factor + container.title*log(age.in.months) + 
       log(age.in.months)*da_factor*container.title, data = at_five_years, link = log)

at_five_years_value <- jtools::summ(all_terms_at_five_years)$model$coefficients %>% unname() %>% 
    tibble(at_five_years_value = `.`)

at_five_years_coefficients <-jtools::summ(all_terms_at_five_years)$model$coefficients %>% names() %>% tibble(coefficients = `.`)

at_five_years_pvalue <-jtools::summ(all_terms_at_five_years)$coeftable[,4]

at_five_years_model <- tibble(at_five_years_coefficients, at_five_years_value, at_five_years_pvalue)

#let's combine all the coefficients - not working as of 20250612 
#why are they different lengths???? bruh.....
all_data_models <- full_join(full_data_model, at_one_year_model) %>%
  full_join(., at_five_years_model) %>% 
  full_join(., five_years_model) %>% 
  full_join(., at_ten_years_model) %>% 
  full_join(., ten_years_model)



#save all data model coefficients table 
write_csv(all_data_models, file = "Data/negative_binomial/all_data_glmnb_models.csv")


#ok let's look at this by journal 


journals <-nsd_yes_metadata %>%
  count(journal_abrev) %>% 
  filter(journal_abrev != "jmbe")


each_journal_model <- list()

#20250625 - i have no idea why the names don't work anymore for this and how they worked before? 
#did i forget to run something? 
# did i delete something i shouldn't have? 
#need to make this looping better
#need to add exactly 1 year, 5 years, 10 years
 
i<-1
for(i in 1:nrow(journals)) { 
  journal_data <- 
  nsd_yes_metadata %>% 
    filter(journal_abrev == journals[[i,1]])

  names(each_journal_model)[[i]] <- journals[[i,1]]

  journal_fit <-glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + 
       + log(age.in.months)*da_factor + log(age.in.months)*da_factor, data = journal_data, link = log)
  
  journals$all_journal_data_rsq[i] <- jtools::summ(journal_fit) %>% attr(., "rsq")

  journal_coefficients <-jtools::summ(journal_fit)$model$coefficients %>%
                          names() %>% 
                          tibble(coefficients = `.`)
  journal_value <- jtools::summ(journal_fit)$model$coefficients %>% 
                          unname() %>% 
                          tibble(journal_value = `.`)
  journal_pvalue <- jtools::summ(journal_fit)$coeftable[,4]
  journal_model <- tibble(journal_coefficients, journal_value)


  five_years <-journal_data %>% 
    filter(age.in.months <= 60)
  if(nrow(five_years) > 0 ) {
  five_years_fit <-glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + 
       + log(age.in.months)*da_factor + log(age.in.months)*da_factor, data =  five_years, link = log)

    journals$five_years_rsq[i]<-jtools::summ(five_years_fit) %>% attr(., "rsq")

     five_years_coefficients <-jtools::summ(five_years_fit)$model$coefficients %>%
                          names() %>% 
                          tibble(coefficients = `.`)
      five_years_value <- jtools::summ(five_years_fit)$model$coefficients %>% 
                          unname() %>% 
                          tibble(five_years_value = `.`)
  five_years_model <- tibble(five_years_coefficients, five_years_value)

  } else {journals$five_years_rsq[i]<-NA}

  ten_years <-journal_data %>% 
      filter(age.in.months <= 120)
  if(nrow(ten_years) > 0 ) {
  
  ten_years_fit <-glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + 
       + log(age.in.months)*da_factor + log(age.in.months)*da_factor, data =  ten_years, link = log)
  
  journals$ten_years_rsq[i]<-jtools::summ(ten_years_fit) %>% attr(., "rsq")

   ten_years_coefficients <-jtools::summ(ten_years_fit)$model$coefficients %>%
                          names() %>% 
                          tibble(coefficients = `.`)
      ten_years_value <- jtools::summ(ten_years_fit)$model$coefficients %>% 
                          unname() %>% 
                          tibble(ten_years_value = `.`)
  ten_years_model <- tibble(ten_years_coefficients, ten_years_value)
  }
  else {journals$ten_years_rsq[i] <- NA}

  
  each_journal_model[[i]] <- full_join(journal_model, no1p_model) %>%
  full_join(., five_years_model) %>% 
  full_join(., ten_years_model)

print(i)
}

each_journal_model %>% enframe() %>% unnest(cols = value) %>% 
  write_csv(., "Data/negative_binomial/negative_binomial_byjournal.csv.gz")

# read_journal<-read_csv("Data/negative_binomial/negative_binomial_byjournal.csv.gz")
