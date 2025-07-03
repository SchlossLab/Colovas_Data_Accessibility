#!/usr/bin/env Rscript
# working on negative binomial regression
#
#library statements 
library(tidyverse)
library(MASS)
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

write_csv(first_citation, file = "Data/negative_binomial/first_citation_date.csv")

first_citation_noga <-
first_citation %>% 
  filter(journal_abrev != "genomea")
first_citation_mean <- mean(first_citation_noga$first_citation)

# model_data <-nsd_yes_metadata
# model_name <-"full_model"

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

  rsquared <-tibble(coefficients = "rsquared", 
                    "{model_name}" := (jtools::summ(total_model) %>% attr(., "rsq")), 
                    "{model_name}_pvalue" := NA) 

  model_table <-rbind(rsquared, model_table)


  return(model_table)

}

# # making a function for smaller model with 2 terms
# model_data <-at_one_year_data
# model_name <- "at_one_year_test"

# model_data <-journal_data
# model_name <- "fit_test"
# two_term_glmnb(journal_data, "fit_test")

#smaller model with 2 terms
two_term_glmnb <-function(model_data, model_name) {

  if(nrow(model_data) > 100 & nrow(count(model_data, da_factor)) > 1) {

  total_model <-MASS::glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + 
       + log(age.in.months)*da_factor + log(age.in.months)*da_factor, data = model_data, link = log)

  coefficients <-jtools::summ(total_model)$model$coefficients %>% names() %>% tibble(coefficients = `.`)

  model_value <- jtools::summ(total_model)$model$coefficients %>% unname() %>% 
      tibble("{model_name}" := `.`) %>% 
      dplyr::select(!`.`)

  pvalue <-jtools::summ(total_model)$coeftable[,4]

  model_table <- tibble(coefficients, model_value, "{model_name}_pvalue" := pvalue)

  rsquared <-tibble(coefficients = "rsquared", 
                    "{model_name}" := (jtools::summ(total_model) %>% attr(., "rsq")), 
                    "{model_name}_pvalue" := NA) 

  model_table <-rbind(rsquared, model_table)

  
    } else {
      model_table <- tibble(coefficients = NA, 
                    "{model_name}" := NA, 
                    "{model_name}_pvalue" := NA)
    }

  return(model_table)

}

#models


#all three interaction terms 
full <- three_term_glmnb(nsd_yes_metadata, "full")


#what happens if you create a whole model with an adjustment of the months
citation_adjustment <- 
  nsd_yes_metadata %>% 
  mutate(time_adj_all = (age.in.months - 5), 
        time_adj_all_no_negs = ifelse(time_adj_all <= 0, 1, time_adj_all), 
        age.in.months = time_adj_all_no_negs)

time_adj <- three_term_glmnb(citation_adjustment, "time_adj")


time_adj_comparison <- full_join(full, time_adj)
  write_csv(time_adj_comparison, file = "Data/negative_binomial/time_adjusted_model_comparison.csv")


#graphing with jtools 

# plot_1<-jtools::effect_plot(interaction, da_factor, plot.points = TRUE)
# jtools::effect_plot(interaction, age.in.months, plot.points = TRUE)
# plot_2<-effect_plot(three_terms_int_all, age.in.months, interval = TRUE, int.type = "confidence", 
#                     int.width = 0.8, plot.points = TRUE, data = nsd_yes_metadata, line.colors = "blue", 
#                     outcome.scale = "link")

# plot_2_no_points<-effect_plot(three_terms_0, age.in.months, interval = TRUE, int.type = "confidence", 
#                     int.width = 0.8, data = nsd_yes_metadata, line.colors = "blue", 
#                     outcome.scale = "link")

# plot_3<-effect_plot(three_terms_int_all, da_factor, interval = TRUE, int.type = "confidence", 
#                     int.width = 0.8, plot.points = TRUE, data = nsd_yes_metadata, line.colors = "blue", 
#                     outcome.scale = "link")
# ggsave(plot_2, file = "Figures/test_2.png")
# ggsave(plot_2_no_points, file = "Figures/test_nopoints_2.png")
# ggsave(plot_3, file = "Figures/test_3.png")



# ok now let's look exactly 1 year of data (12 months)----------------------------------------------------
at_one_year_data <- 
  nsd_yes_metadata %>% 
    filter(age.in.months == 12)

at_one_year <- three_term_glmnb(at_one_year_data, "at_one_year")


# ok now let's look at cutting it off at 10 years (120 months)
ten_years_data <- 
  nsd_yes_metadata %>% 
    filter(age.in.months <= 120)

ten_years <- three_term_glmnb(ten_years_data, "ten_years")


# ok now let's look exactly 10 years of data (120 months)
at_ten_years_data <- 
  nsd_yes_metadata %>% 
    filter(age.in.months == 120)

at_ten_years <- three_term_glmnb(at_ten_years_data, "at_ten_years")


#how about 5 years (60 months )
five_years_data <- 
  nsd_yes_metadata %>% 
    filter(age.in.months <= 60)

five_years <- three_term_glmnb(five_years_data, "five_years")


# ok now let's look exactly 5 years of data (6- months)
at_five_years_data <- 
  nsd_yes_metadata %>% 
    filter(age.in.months == 60)

at_five_years <- three_term_glmnb(at_five_years_data, "at_five_years")

#let's combine all the coefficients 
all_data_models <- full_join(full, time_adj) %>%
  full_join(., at_one_year) %>%
  full_join(., at_five_years) %>% 
  full_join(., five_years) %>% 
  full_join(., at_ten_years) %>% 
  full_join(., ten_years)


#save all data model coefficients table 
write_csv(all_data_models, file = "Data/negative_binomial/all_data_glmnb_models.csv")


#ok let's look at this by journal 

journals <-nsd_yes_metadata %>%
  count(journal_abrev) %>% 
  filter(journal_abrev != "jmbe") %>%
  mutate(values = NA)


each_journal_model <- as.vector(1:12, mode = "list") 
names(each_journal_model) <-journals$journal_abrev


i<-4
for(i in 1:nrow(journals)) { 
  journal_data <- 
  nsd_yes_metadata %>% 
    filter(journal_abrev == journals[[i,1]])

# #20250627 - i don't think the names work either? 
#   names(journals)[[i]] <- journals[[i,1]]

  journal_fit <- two_term_glmnb(journal_data, "journal")

# at one year
  at_one_year_data <- journal_data %>% 
    filter(age.in.months == 12)
  at_one_year <- two_term_glmnb(at_one_year_data, "at_one_year")
 

# at five years
  at_five_years_data <-journal_data %>% 
    filter(age.in.months == 60)
  at_five_years <- two_term_glmnb(at_five_years_data, "at_five_years")


# 0 to five years
  five_years_data <-journal_data %>% 
    filter(age.in.months <= 60)
  five_years <- two_term_glmnb(five_years_data, "five_years")

#0 to 10 years 
  ten_years_data <-journal_data %>% 
      filter(age.in.months <= 120)
  ten_years <- two_term_glmnb(ten_years_data, "ten_years")
    

#at ten years
 at_ten_years_data <-journal_data %>% 
      filter(age.in.months == 120)
  at_ten_years <- two_term_glmnb(at_ten_years_data, "at_ten_years")
 

#concatenate and save
  each_journal_model[[i]] <- full_join(journal_fit, at_one_year, by = join_by(coefficients)) %>%
  full_join(., at_five_years, by = join_by(coefficients)) %>% 
  full_join(., five_years, by = join_by(coefficients)) %>% 
  full_join(., at_ten_years, by = join_by(coefficients)) %>% 
  full_join(., ten_years, by = join_by(coefficients))


  print(i)
}

each_journal_model %>% tibble(names = names(each_journal_model)) %>% 
  unnest(., cols = `.`) %>% relocate(names) %>%
  write_csv(., file = "Data/negative_binomial/negative_binomial_models_each_journal.csv")




