#see combine_models.R for graphing

#library statements 
library(tidyverse)
library(mikropml)

# load my files probably 
filepath <-"Data/ml_results/groundtruth/rf"
# filepath  <- "Data/ml_results/gt_subset_30/glmnet"
# gtss30_RDS <- readRDS("Data/ml_results/gt_subset_30/glmnet/glmnet.10.new_seq_data.model.RDS")
# gtss30_RDS$results

#what if i just want to open one of the RDS files to see what's in it
one_rds <- readRDS("Data/ml_results/groundtruth/rf/rf.1.data_availability.model.RDS")
two_rds <- readRDS("Data/ml_results/groundtruth/rf/rf.1.new_seq_data.model.RDS")

#20240722 looking for the feature importance table by p value
one_rds
str(one_rds)
head(one_rds$feature_importance$feat, 10)
head(two_rds$feature_importance, 10)
two_rds$feature_importance

# one_rds_feats <-
one_rds$feature_importance %>%
    filter(pvalue <= 0.2)

two_rds$feature_importance %>%
    filter(pvalue <= 0.2)

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
head(seq_combined, 2)





