#library statements 
library(tidyverse)
library(mikropml)

# load my files probably 
filepath <-"Data/ml_results/groundtruth/glmnet"
# filepath  <- "Data/ml_results/gt_subset_30/glmnet"
# gtss30_RDS <- readRDS("Data/ml_results/gt_subset_30/glmnet/glmnet.10.new_seq_data.model.RDS")
# gtss30_RDS$results

#what if i just want to open one of the RDS files to see what's in it
one_rds <- readRDS("Data/ml_results/groundtruth/glmnet/glmnet.1.data_availability.model.RDS")


seq_files_list <- list.files(filepath, 
                        pattern = str_glue("new_seq_data.*.RDS"), 
                        full.names = TRUE)

avail_files_list <- list.files(filepath, 
                        pattern = str_glue("data_availability.*.RDS"), 
                        full.names = TRUE)

seq_results <- map(seq_files_list, readRDS)
head(seq_results, 2)
avail_results <- map(avail_files_list, readRDS)
head(avail_results, 2)
# let's try and graph these after we read them all in as csvs
# instead of trying to read in the RDS files
#this works!!! yay, you just have to graph diff ones ased on which type of results you want to see

seq_combined <- combine_hp_performance(seq_results)
#seq_combined <- combine_hp_performance(gtss30_RDS)

#for glmnet
plot_hp_performance(seq_combined$dat, lambda, AUC)
plot_hp_performance(seq_combined$dat, alpha, AUC)

#for gtss30 test
gtp <- get_hp_performance(gtss30_RDS)
gtss30_RDS$results
plot_hp_performance(gtss30_RDS$results, lambda, AUC)
plot_hp_performance(gtss30_RDS$results, alpha, AUC)

#for rf
plot_hp_performance(seq_combined$dat, mtry, AUC)

#for xgboost
plot_hp_performance(seq_combined$dat, max_depth, AUC)
plot_hp_performance(seq_combined$dat, eta, AUC)


avail_combined <- combine_hp_performance(avail_results)

plot_hp_performance(avail_combined$dat, lambda, AUC)
plot_hp_performance(avail_combined$dat, alpha, AUC)

plot_hp_performance(avail_combined$dat, mtry, AUC)

plot_hp_performance(avail_combined$dat, max_depth, AUC)
plot_hp_performance(avail_combined$dat, eta, AUC)
plot_hp_performance(avail_combined$dat, subsample, AUC)

