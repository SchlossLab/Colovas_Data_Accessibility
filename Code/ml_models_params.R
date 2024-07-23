#see combine_models.R for graphing

#library statements 
library(tidyverse)
library(mikropml)

# load my files probably 
filepath <-"Data/ml_results/groundtruth/rf"
# filepath  <- "Data/ml_results/gt_subset_30/glmnet"
# gtss30_RDS <- readRDS("Data/ml_results/gt_subset_30/glmnet/glmnet.10.new_seq_data.model.RDS")
# gtss30_RDS$results

# practice with RDS files
# read 2 rds files
one_rds <- readRDS("Data/ml_results/groundtruth/rf/rf.1.data_availability.model.RDS")
two_rds <- readRDS("Data/ml_results/groundtruth/rf/rf.2.data_availability.model.RDS")


# filter feature importance by pvalue <= 0.1
one_rds_feats <-
one_rds$feature_importance %>%
    filter(pvalue <= 0.1)

two_rds_feats <-
two_rds$feature_importance %>%
    filter(pvalue <= 0.1)

# concatenate two test feature sets
feats_list_test <-
    rbind(one_rds_feats, two_rds_feats)

# get lists of files for each model evaluation
seq_files_list <- list.files(filepath, 
                        pattern = str_glue("new_seq_data.*.RDS"), 
                        full.names = TRUE)

avail_files_list <- list.files(filepath, 
                        pattern = str_glue("data_availability.*.RDS"), 
                        full.names = TRUE)

# try and make smaller list to work with using only a subset of the seq_files_list
small_seq_files_list <- head(seq_files_list, 5)
small_seq_results <- map(small_seq_files_list, readRDS)

#map to open RDS files
seq_results <- map(seq_files_list, readRDS)
avail_results <- map(avail_files_list, readRDS)

# trying to create a function that reads in each RDS file and 
# then adds the features that have pvalue <= sig
# 20240723 - this function doesn't work, but it WILL print out the stuff you want in the for loop
get_sig_feats <- function(rds_list, dest, sig) {
    seq_results <- map(rds_list, readRDS)
    for(x in 1:length(rds_list)) {
        y <- seq_results[[x]]$feature_importance %>%
            filter(pvalue <= sig) %>%
            print()
        # dest <- rbind(dest, y)
    }

return(dest)

}

# these also don't work right for the function call 
dest_seq <- get_sig_feats(seq_files_list, dest_seq, 0.0005)
write.csv(dest_seq, file = str_glue("{filepath}/new_seq_data.features.csv"))

dest_avail <- get_sig_feats(avail_files_list, dest_avail, 0.005)
write.csv(dest_avail, file = str_glue("{filepath}/data_availability.features.csv"))

#for loop that works to print data on it's own 
# doesn't concatenate in any way 
for(x in 1:length(small_seq_results)) {
        small_seq_results[[x]]$feature_importance %>%
            filter(pvalue <= 0.05) %>%
            print()
    }



# stuff i tried that also failed

# # just trying to get into the right part of the data structure
# seq_feat_test <-  
#     small_seq_results[[]]$feature_importance %>% 
#         filter(pvalue <= 0.05)
    
# # map function
# map(small_seq_results$feature_importance, \(x) filter(x, pvalue <= 0.05))

# # trying to figure out if the level i need actually exists 
# pluck_exists(small_seq_results[[1]]$feature_importance$pvalue)


# #trying purrr::map_depth
# map_depth(small_seq_results, 3, 
#     filter, pvalue <=0.05)

# # using package collapse
# collapse::ldepth(small_seq_results) #6 
# collapse::has_elem(small_seq_results, 
#    "feature_importance", recursive = TRUE) #TRUE
# #also part of collapse but i'm not quite sure if the syntax is right
# keep(small_seq_results[[]]$feature_importance, 
#     pvalue <= 0.05)









