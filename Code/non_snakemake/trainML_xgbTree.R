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
                   hyperparameters = list( eta = c(0.05, 0.06, 0.07, 0.075, 0.08, 0.09),
                                            max_depth = 15,
                                            subsample = c(0.6, 0.65, 0.7, 0.75, 0.8),
                                            nrounds = 100,
                                            gamma = 0,
                                            colsample_bytree = 0.8,
                                            min_child_weight = 1),
                   find_feature_importance = FALSE,
                   seed = seed)

#write results to files 
write.csv(ml_results$performance, file = output_perf)
saveRDS(ml_results$trained_model, file = output_model)

