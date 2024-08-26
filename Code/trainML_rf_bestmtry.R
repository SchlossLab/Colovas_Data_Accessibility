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
       
# input:
#    rds = "Data/{datasets}.{ml_variables}.preprocessed.RDS", 
#    rscript = "Code/trainML_rf.R",
#    dir = "Data/ml_results/{datasets}/rf"
# output:
#    model="Data/ml_results/{datasets}/rf/rf.{seeds}.{ml_variables}.model.RDS", 
#    perf="Data/ml_results/{datasets}/rf/rf.{seeds}.{ml_variables}.performance.csv", 
#    #prediction="Data/ml_results/{datasets}/rf/rf.{seeds}.{ml_variables}.prediction.csv", 
#    hp_performance="Data/ml_results/{datasets}/rf/rf.{seeds}.{ml_variables}.hp_performance.csv"

# # {input.rscript} {input.rds} {wildcards.seeds} {wildcards.ml_variables} {input.dir}
# input <- commandArgs(trailingOnly = TRUE)
# rds <- input[1]
# data_processed <- readRDS(rds)
# seed <- as.numeric(input[2])
# ml_var_snake <- input[3]
# output_dir <- input[4]

#local checks data_availability 
rds <- "Data/groundtruth.data_availability.preprocessed.RDS"
data_processed <- readRDS(rds)
best_seed <- 44
ml_var_snake <- "data_availability"
output_dir <- paste0("Data/ml_results/groundtruth/rf/{ml_var_snake}")

## from kelly 
# # 2. We can do 5-fold cross validation for a single seed to get the best mtry value.
# results_cv <- run_ml(
#   train_data,
#   method = "rf",
#   outcome_colname = "your_outcome",
#   training_frac = 1.0,
#   seed = best_seed,
#   kfold = 5,
#   cv_times = 100,
#   calculate_performance = FALSE # don't calc performance, there's no test data
# )


# run model using mikropml::run_ml
results_cv <- run_ml(data_processed$dat_transformed,
                   method = "rf",  
                   outcome_colname = ml_var_snake,
                   training_frac = 1.0,
                   kfold = 5, 
                   cv_times = 100, 
                   hyperparameters = list(mtry =  c(84, 100, 150, 200, 300)),
                   find_feature_importance = TRUE,
                   seed = best_seed, 
                   calculate_performance = FALSE)
# save besttune
best_tune <- results_cv$trained_model$bestTune
write_csv(performance,file = paste0(output_dir, "/best.rf.", ml_var_snake, ".", seed, ".bestTune.csv"))

# "Data/ml_results/{datasets}/rf/{ml_varaibles}/rf.{ml_variables}.{seeds}.model.RDS",
#output_dir <- paste0("Data/ml_results/groundtruth/rf/{ml_var_snake}"

# there is no performance
# # write out performance results
# performance <- results_cv$performance
# write_csv(performance,file = paste0(output_dir, "/best.rf.", ml_var_snake, ".", seed, ".performance.csv"))


# #hyperparameter performance
# hyperparameters <- get_hp_performance(results_cv$trained_model)$dat
# write_csv(hyperparameters,paste0(output_dir, "/best.rf.", ml_var_snake, ".", seed, ".hp_performance.csv"))

# write out model
saveRDS(results_cv$trained_model,file = paste0(output_dir, "/best.rf.", ml_var_snake, ".", seed, ".model.RDS"))

#new_seq_data

rds <- "Data/groundtruth.new_seq_data.preprocessed.RDS"
data_processed <- readRDS(rds)
best_seed <- 49
ml_var_snake <- "new_seq_data"
output_dir <- paste0("Data/ml_results/groundtruth/rf/{ml_var_snake}")


# run model using mikropml::run_ml
results_cv <- run_ml(data_processed$dat_transformed,
                   method = "rf",  
                   outcome_colname = ml_var_snake,
                   training_frac = 1.0,
                   kfold = 5, 
                   cv_times = 100, 
                   hyperparameters = list(mtry =  c(84, 100, 150, 200, 300)),
                   find_feature_importance = TRUE,
                   seed = best_seed, 
                   calculate_performance = FALSE)
# save besttune
best_tune <- results_cv$trained_model$bestTune
write_csv(performance,file = paste0(output_dir, "/best.rf.", ml_var_snake, ".", seed, ".bestTune.csv"))

# "Data/ml_results/{datasets}/rf/{ml_varaibles}/rf.{ml_variables}.{seeds}.model.RDS",
#output_dir <- paste0("Data/ml_results/groundtruth/rf/{ml_var_snake}"

# there is no performance
# # write out performance results
# performance <- results_cv$performance
# write_csv(performance,file = paste0(output_dir, "/best.rf.", ml_var_snake, ".", seed, ".performance.csv"))


# #hyperparameter performance
# hyperparameters <- get_hp_performance(results_cv$trained_model)$dat
# write_csv(hyperparameters,paste0(output_dir, "/best.rf.", ml_var_snake, ".", seed, ".hp_performance.csv"))

# write out model
saveRDS(results_cv$trained_model,file = paste0(output_dir, "/best.rf.", ml_var_snake, ".", seed, ".model.RDS"))