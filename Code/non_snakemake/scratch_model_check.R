#library
library(tidyverse)
library(caret)

da_final <- readRDS("Data/ml_results/groundtruth/rf/data_availability/final/final.rf.data_availability.102899.allfinalModel.RDS")
nsd_final<- readRDS("Data/ml_results/groundtruth/rf/new_seq_data/final/final.rf.new_seq_data.102899.allfinalModel.RDS")

da_model_final <- readRDS("Data/ml_results/groundtruth/rf/data_availability/final/final.rf.data_availability.102899.model.RDS")
nsd_model_final <- readRDS("Data/ml_results/groundtruth/rf/new_seq_data/final/final.rf.new_seq_data.102899.model.RDS")

da_model_best <- readRDS("Data/ml_results/groundtruth/rf/data_availability/best/best.rf.data_availability.102899.model.RDS")
nsd_model_best <- readRDS("Data/ml_results/groundtruth/rf/new_seq_data/best/best.rf.new_seq_data.102899.model.RDS")

da_all <- readRDS("Data/ml_results/groundtruth/rf/data_availability/best/best.rf.data_availability.102899.wholeModel.RDS")

#20250513 - the piece of data that i've been waiting for all day
#actually was not included in the model that i painstakingly retrained and have been waiting 
#all day for to come back 

da_seed_1 <- readRDS("Data/ml_results/groundtruth/rf/data_availability/rf.data_availability.1.model.RDS")
da_seed_1$results

#da = 400, nsd = 300
# now i have to wait for this to finish becasue i thought i needed it to be retrained
da_best_stats<-da_model_best$results[4, ] %>% pivot_longer(1:29, names_to = "key", values_to = "value") %>% 
    rename(da_model = value)
nsd_best_stats<-nsd_model_best$results[3, ] %>% pivot_longer(1:29, names_to = "key", values_to = "value") %>% 
    rename(nsd_model = value)


all_model_stats<-full_join(da_best_stats, nsd_best_stats) %>% view()
write_csv(all_model_stats, file = "Data/final/best_model_stats.csv")
