#!/usr/bin/env Rscript
# trainML.R
#
#
#
# library statements
library(tidyverse)
library(tidytext)
library(mikropml)


# model="Data/ml_results/{datasets}/rf/rf.{seeds}.{ml_variables}.model.RDS", 
# perf="Data/ml_results/{datasets}/rf/rf.{seeds}.{ml_variables}.performance.csv"
# dir = "Data/ml_results/{datasets}/rf"
       

# {input.rscript} {input.rds} {wildcards.seeds} {wildcards.ml_variables} {input.dir}
input <- commandArgs(trailingOnly = TRUE)
rds <- input[1]
data_processed <- readRDS(rds)
seed <- as.numeric(input[2])
ml_var_snake <- input[3]
output_dir <- input[4]

##local checks
# rds <- "Data/preprocessed/groundtruth.data_availability.preprocessed.RDS"
# data_processed <- readRDS(rds)
# seed <- 1
# ml_var_snake <- "data_availability"
# output_dir <- paste0("Data/ml_results/groundtruth/rf/{ml_var_snake}")

# run model using mikropml::run_ml
ml_results <- run_ml(data_processed$dat_transformed,
                   method = "rf",  
                   outcome_colname = ml_var_snake,
                   hyperparameters = list(mtry = c(84, 100, 150, 200, 300)),
                   find_feature_importance = TRUE,
                   seed = seed)


# "Data/ml_results/{datasets}/rf/{ml_varaibles}/rf.{ml_variables}.{seeds}.model.RDS",
#output_dir <- paste0("Data/ml_results/groundtruth/rf/{ml_var_snake}"

# write out performance results
performance <- ml_results$performance
write_csv(performance,file = paste0(output_dir, "/rf.", ml_var_snake, ".", seed, ".performance.csv"))


#hyperparameter performance
hyperparameters <- get_hp_performance(ml_results$trained_model)$dat
write_csv(hyperparameters,paste0(output_dir, "/rf.", ml_var_snake, ".", seed, ".hp_performance.csv"))

# write out model
saveRDS(ml_results$trained_model,file = paste0(output_dir, "/rf.", ml_var_snake, ".", seed, ".model.RDS"))