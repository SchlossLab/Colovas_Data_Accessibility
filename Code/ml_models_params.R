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

one_rds_feats <-
one_rds$feature_importance %>%
    filter(pvalue <= 0.1)

two_rds_feats <-
two_rds$feature_importance %>%
    filter(pvalue <= 0.1)

feats_list_test <-
    rbind(one_rds_feats, two_rds_feats)

    
seq_files_list <- list.files(filepath, 
                        pattern = str_glue("new_seq_data.*.RDS"), 
                        full.names = TRUE)
small_seq_files_list <- head(seq_files_list, 5)

avail_files_list <- list.files(filepath, 
                        pattern = str_glue("data_availability.*.RDS"), 
                        full.names = TRUE)

    
# 20240723 - function doesn't work because it doesn't append correctly to add all data together
get_sig_feats <- function(rds_list, dest, sig) {
    seq_results <- map(rds_list, readRDS)
    dest <- tibble()
    for(x in 1:length(rds_list)) {
        y <- seq_results[[x]]$feature_importance %>%
            filter(pvalue <= sig)
        dest <- rbind(dest, y)
    }

return(dest)

}


# these also don't work right 
dest_seq <- get_sig_feats(seq_files_list, dest_seq, 0.0005)
write.csv(dest_seq, file = str_glue("{filepath}/new_seq_data.features.csv"))

dest_avail <- get_sig_feats(avail_files_list, dest_avail, 0.005)
write.csv(dest_avail, file = str_glue("{filepath}/data_availability.features.csv"))




# seq_feat_test <- for(x in 1:5) {
#     seq_results[[x]]$feature_importance %>% 
#         filter(pvalue <= 0.1) %>% 
#         print()
#     }

seq_feats_test <- seq_results[[1]]$feature_importance %>%
    filter(pvalue <= 0.1) 
y <- bind_rows(seq_feats_test)

seq_results$feature_importance %>% 
    filter(pvalue <= 0.1) %>% 
    head(2)

head(seq_results, 2)
avail_results <- map(avail_files_list, readRDS)
head(avail_results, 2)





