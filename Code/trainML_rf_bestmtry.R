#!/usr/bin/env Rscript
# trainML_rf_bestmtry.R
#
#
#
# library statements
library(tidyverse)
library(tidytext)
library(devtools)
#library(mikropml)
install_github("joannacolovas/mikropml", 
                quiet = TRUE)



# # {input.rscript} {input.rds} {wildcards.ml_variables} {input.dir}

input <- commandArgs(trailingOnly = TRUE)
rds <- input[1]
data_processed <- readRDS(rds)
best_seed <- 102899
ml_var_snake <- input[2]
output_dir <- input[3]

#local checks data_availability 
# rds <- "Data/groundtruth.data_availability.preprocessed.RDS"
# data_processed <- readRDS(rds)
# best_seed <- 102899
# ml_var_snake <- "data_availability"
# output_dir <- paste0("Data/ml_results/groundtruth/rf/", ml_var_snake)

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
## practice model with small dataset 
# results_cv <- mikropml::run_ml(mikropml::otu_mini_bin,
#                    method = "rf",  
#                    training_frac = 1.0,
#                    kfold = 5, 
#                    cv_times = 100, 
#                    seed = 102899, 
#                    calculate_performance = FALSE)


# run model using mikropml::run_ml
results_cv <- mikropml::run_ml(data_processed$dat_transformed,
                   method = "rf",  
                   outcome_colname = ml_var_snake,
                   training_frac = 1.0,
                   kfold = 5, 
                   cv_times = 100, 
                   hyperparameters = list(mtry =  c(84, 100, 150, 200, 300)),
                   seed = best_seed, 
                   calculate_performance = FALSE)
# save besttune
best_tune <- results_cv$trained_model$bestTune
write_csv(best_tune,file = paste0(output_dir, "/best/best.rf.", ml_var_snake, ".", best_seed, ".bestTune.csv"))

#hyperparameter performance
hyperparameters <- mikropml::get_hp_performance(results_cv$trained_model)$dat
write_csv(hyperparameters,paste0(output_dir, "/best/best.rf.", ml_var_snake, ".", best_seed, ".hp_performance.csv"))

# write out model
saveRDS(results_cv$trained_model,file = paste0(output_dir, "/best/best.rf.", ml_var_snake, ".", best_seed, ".model.RDS"))



