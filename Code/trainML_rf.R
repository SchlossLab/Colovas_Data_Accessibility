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

# {input.rscript} {input.rds} {wildcards.seeds} {wildcards.ml_variables} {input.dir}
input <- commandArgs(trailingOnly = TRUE)
rds <- input[1]
data_processed <- readRDS(rds)
seed <- as.numeric(input[2])
ml_var_snake <- input[3]
output_dir <- input[4]

##local checks
# rds <- "Data/groundtruth.data_availability.preprocessed.RDS"
# data_processed <- readRDS(rds)
# seed <- 1
# ml_var_snake <- "data_availability"
# output_dir <- "Data/ml_results/groundtruth/rf"

# run model using mikropml::run_ml
ml_results <- run_ml(data_processed$dat_transformed,
                   method = "rf",  
                   outcome_colname = ml_var_snake,
                   hyperparameters = list(mtry =  c(84, 100, 150, 200, 300)),
                   find_feature_importance = TRUE,
                   seed = seed)

data_processed$dat_transformed
# #write results to files (jo og)
# write.csv(ml_results$performance, file = output_perf)
# saveRDS(ml_results, file = output_model)

# perf="Data/ml_results/{datasets}/rf/rf.{seeds}.{ml_variables}.performance.csv"
# write out performance results
performance <- ml_results$performance
write_csv(performance,file = paste0(output_dir, "/rf.", seed, ".", ml_var_snake, ".performance.csv"))

# 20240730 i don't think i need this one yet
# # write out prediction probabilities for sample
# prediction <- predict(results$trained_model,test,type = "prob")  %>% 
#   bind_cols(.,testIDS) %>% 
#   select(Group,dx,cancer,normal)
# write_csv(prediction,file = paste0(outDir, "prediction_", split, ".csv"))

#hyperparameter performance
hyperparameters <- get_hp_performance(ml_results$trained_model)$dat
write_csv(hyperparameters,paste0(output_dir, "/rf.", seed, ".", ml_var_snake, ".hp_performance.csv"))

# write out model
saveRDS(ml_results$trained_model,file = paste0(output_dir, "/rf.", seed, ".", ml_var_snake, ".model.RDS"))