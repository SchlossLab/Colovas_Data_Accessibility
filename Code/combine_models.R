#!/usr/bin/env Rscript
# combine_models_glmnet.R
#
#
#library statements
library(tidyverse)
library(mikropml)

#snakemake
# {input.rscript} {input.filepath} {wildcards.method} {wildcards.ml_variables} {output}

input <- commandArgs(trailingOnly = TRUE)
in_filepath <- input[1]
method <- as.character(input[2])
ml_var <- input[3]
out_filepath <- input[4]

#practice locally
# filepath <-"Data/ml_results/groundtruth/rf/data_availability"
# method <- "rf"
# ml_var <- "data_availability"


files_list <- list.files(in_filepath, 
                        #pattern = str_glue("{ml_var}\\.[0-9]{1,3}$\\.(.RDS)*"),
                        pattern = str_glue("{ml_var}.*.RDS"), 
                        full.names = TRUE)


results <- map(files_list, readRDS)

combined <- combine_hp_performance(results)

if (method == "glmnet") {
    lambda <- plot_hp_performance(combined$dat, lambda, AUC)
    alpha <- plot_hp_performance(combined$dat, alpha, AUC) 
    plot <- cowplot::plot_grid(lambda, alpha, 
                               labels = c("lambda", "alpha")) 
    ggsave(plot, filename = out_filepath)
}

if (method == "rf") {
    plot_hp_performance(combined$dat, mtry, AUC) %>%
        ggsave(filename = out_filepath)  
}

if (method == "xgbTree") {
    max <- plot_hp_performance(combined$dat, max_depth, AUC)
    eta <- plot_hp_performance(combined$dat, eta, AUC) 
    sub <- plot_hp_performance(combined$dat, subsample, AUC) 
    
    plot <- cowplot::plot_grid(max, eta, sub, 
                    labels = c("max_depth", "eta", "subsample"))
    ggsave(plot, filename = out_filepath)  
}

