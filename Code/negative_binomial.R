#!/usr/bin/env Rscript
# working on negative binomial regression
#
#library statements 
library(tidyverse)
library(MASS)
library(jtools)

#load files with snakemake
# get file input from snakemake
input <- commandArgs(trailingOnly = TRUE)
metadata <- read_csv(input[1])
out_coeftable <- input[2]
out_model <- input[3]


#load metadata (local)
# metadata <- read_csv("Data/final/predictions_with_metadata.csv.gz") 

nsd_yes_metadata <- 
  metadata %>% 
  filter(nsd == "Yes") %>%
  filter(., age.in.months != "NA" & da != "NA" & container.title != "NA") %>% 
  mutate(da_factor = factor(da), 
         container.title = factor(container.title))


nsd_yes_model <-glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + container.title + 
        + container.title*da_factor + log(age.in.months)*da_factor + container.title*log(age.in.months) + 
        log(age.in.months)*da_factor*container.title, data = nsd_yes_metadata, link = log)


#20250627 - making a function for large model with all 3 terms 
three_term_glmnb_table <-function(model, model_name) {

  coefficients <-jtools::summ(model)$model$coefficients %>% names() %>% tibble(coefficients = `.`)

  model_value <- jtools::summ(model)$model$coefficients %>% unname() %>% 
      tibble("{model_name}" := `.`) %>% 
      dplyr::select(!`.`)
    
  pvalue <-jtools::summ(model)$coeftable[,4]

  model_table <- tibble(coefficients, model_value, "{model_name}_pvalue" := pvalue)

  rsquared <-tibble(coefficients = "rsquared", 
                    "{model_name}" := (jtools::summ(model) %>% attr(., "rsq")), 
                    "{model_name}_pvalue" := NA) 

  model_table <-rbind(rsquared, model_table)


  return(model_table)

}

#all three interaction terms and return model table
full_table <- three_term_glmnb_table(nsd_yes_model, "full_nsd_yes")

#save model table and model
write_csv(full_table, file = out_coeftable)

saveRDS(nsd_yes_model, file = out_model)
