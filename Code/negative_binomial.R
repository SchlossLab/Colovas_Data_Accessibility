#!/usr/bin/env Rscript
# working on negative binomial regression
#
#library statements 
library(tidyverse)
library(MASS)
library(jtools)
library(emmeans)
library(sjPlot)


#load files with snakemake
# get file input from snakemake
input <- commandArgs(trailingOnly = TRUE)
metadata <- read_csv(input[1])
out_coeftable <- input[2]
out_model <- input[3]
out_contrast_plot <-input[4]
out_predicted_plot <- input[5]


#load metadata (local)
# metadata <- read_csv("Data/final/predictions_with_metadata.csv.gz") 
# out_contrast_plot <-"Figures/negative_binomial/emmeans_contrast_plot.png"

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


#do the emmeans contrasts - must do in same file as model

# Define the age values you want to examine (in months)
age_values <- seq(5, 120, 5) #c(12, 36, 60, 120)  # Adjust these as needed
# Get emmeans on the link scale for all combinations
emm <- emmeans(model,  ~ da_factor + age.in.months | container.title,
        at = list(age.in.months = age_values), CIs = TRUE,
        type = "response")
# Get pairwise comparisons (differences) between da_factor levels
differences <- contrast(
    emm, by = c("age.in.months", "container.title"),
    method = "revpairwise",
    ratios = TRUE, CIs = TRUE
)
# See the contrasts
# summary(differences)
# Plot the contrasts
# plot(differences, ratios = TRUE)

# Plot the contrasts
ratios_df <- as.data.frame(plot(differences, ratios = TRUE)$data)  %>% 
 filter(container.title != "Journal of Microbiology &amp; Biology Education" &
        container.title != "Genome Announcements" & 
        container.title != "Microbiology Resource Announcements")


ggplot(
    data = ratios_df,
    mapping = aes(x = age.in.months, y = the.emmean)
) +
   geom_hline(yintercept = 1.0, linetype = 2, linewidth = 0.25) + 
    geom_line() +
    geom_ribbon(
        mapping = aes(ymin = lcl, ymax = ucl),
        alpha = 0.3 # transparency of confidence intervals
    ) +
    facet_wrap(~ container.title, nrow = 2, 
               labeller = label_wrap_gen(width = 20)) +
    labs(x = 'Age in months', y = 'Ratio of daYes/daNo') +
    coord_cartesian(ylim = c(0.25, 2.5)) + 
    theme_classic() + 
    scale_x_continuous(breaks = seq(12, 120, 24)) %>%
    ggsave(out_contrast_plot)


## predicted number of citations for each journal 
# make plots for each journal 
  p <-  get_model_data(model = nsd_yes_model, type = "pred", 
                    terms = c("da_factor", "age.in.months[age_values]", "container.title"), 
                    colors = "bw") %>%  
      tibble(da_factor = ifelse(.$x == 1, "Data not available", "Data available"), predicted_citations = .$predicted, 
          age.in.months = .$group, container.title = .$facet) %>%   
          filter(container.title != "Journal of Microbiology &amp; Biology Education" &
        container.title != "Genome Announcements" & 
        container.title != "Microbiology Resource Announcements")
        
  
  
    
  ggplot(data = p, mapping = aes(x = as.numeric(age.in.months), y = predicted_citations,
                                color = da_factor)) + 
   geom_line(aes(x = age.in.months, y = predicted_citations, group = da_factor)) +
   geom_ribbon(mapping = aes(ymin = conf.low, ymax = conf.high, 
                             group = da_factor, fill = da_factor), alpha = 0.2) +
  facet_wrap(~ container.title, nrow = 2, 
               labeller = label_wrap_gen(width = 18), 
               scale = "free_y") +
   labs(title = "Predicted Number of Citations from GLM.NB",
        x = "Age in Months", 
        y = "Predicted Number Citations", 
        color = "Data availability\nwith 95% CI", 
        fill = "Data availability\nwith 95% CI") + 
    scale_x_discrete(breaks = seq(12, 120, 12)) + 
    theme_classic() + 
    theme(legend.position = "bottom" ) %>% 
        ggsave(out_predicted_plot)
  
  
  
  