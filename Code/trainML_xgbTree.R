#!/usr/bin/env Rscript
# trainML.R
#
#
#
# library statements
library(tidyverse)
library(tidytext)
library(mikropml)


# model="Data/ml_results/{dataset}/runs/{method}_{seed}_{ml_vars}_model.Rds",
# perf="Data/ml_results/{dataset}/runs/{method}_{seed}_{ml_vars}_performance.csv",
# {input.rscript} {input.rds} {params.seed} {wildcards.ml_variables} {output.model} {output.perf}
       
input <- commandArgs(trailingOnly = TRUE)
rds <- input[1]
data_processed <- readRDS(rds)
seed <- as.numeric(input[2])
ml_var_snake <- input[3]
output_model <- input[4]
output_perf <- input[5]




# run model using mikropml::run_ml
ml_results <- run_ml(data_processed$dat_transformed,
                   method = "xgbTree",  
                   outcome_colname = ml_var_snake,
                   hyperparameters = list( eta = c(0.001, 0.01, 0.015, 0.02, 
                                            0.025, 0.05, 0.075, 0.1, 0.2, 0.25), 
                                            max_depth = 15, 
                                            subsample = c(0.6, 0.7, 0.8, 0.9, 1.0)), 
                   find_feature_importance = FALSE,
                   seed = seed)

#write results to files 
write.csv(ml_results$performance, file = output_perf)
saveRDS(ml_results$trained_model, file = output_model)

