#!/usr/bin/env Rscript
# working on negative binomial regression
#
#library statements 
library(tidyverse)
library(MASS)
library(jtools)



#load metadata
metadata <- read_csv("Data/final/predictions_with_metadata.csv.gz") 

metadata <- 
  metadata %>% 
  filter(nsd == "Yes") %>%
  filter(., age.in.months != "NA" & da != "NA" & container.title != "NA") %>% 
  mutate(da_factor = factor(da), 
         container.title = factor(container.title))




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

#all three interaction terms 
full <- three_term_glmnb(metadata, "full")


