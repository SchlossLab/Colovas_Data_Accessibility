# 20240513 mikropml investigation 
# data preprocessing "no data preprocessing" message

# load packages
library(tidyverse)
library(mikropml)

# look at function preprocess_data for small example dataset from documentation

# load unprocessed dataset otu_mini_bin
otu_mini_bin <- otu_mini_bin

# pre-process dataset, and assign to new variable  
otu_mini_bin_preproc <- preprocess_data(otu_mini_bin, 
                                       outcome_colname = "dx")

otu_mini_bin_preproc_dat <- otu_mini_bin_preproc$dat_transformed

# load already pre-processed dataset "otu_data_preproc" from documentation 
otu_data_preproc <- otu_data_preproc


#"no preprocessing" when you use non-preprocessed data 
otu_mini_bin_no_preproc_ml<- run_ml(otu_mini_bin, 
                                 "glmnet", outcome_colname = "dx")
otu_mini_bin_no_preproc_ml$trained_model

#"no preprocessing" when you use the "$dat_transformed" notation
otu_mini_bin_preproc_ml<- run_ml(otu_mini_bin_preproc$dat_transformed, 
                       "glmnet", outcome_colname = "dx")
otu_mini_bin_preproc_ml$trained_model

#"no preprocessing" when you use the "$dat_transformed" notation
# AND the dataset which is given to you transformed
otu_data_preproc_ml <- run_ml(otu_data_preproc$dat_transformed, "glmnet", 
                              outcome_colname = "dx")
otu_data_preproc_ml$trained_model

#"no pre-processing" when you assign pre-processed data to a new variable
otu_mini_bin_preproc_dat_ml <- run_ml(otu_mini_bin_preproc_dat, "glmnet", 
                                      outcome_colname = "dx")
otu_mini_bin_preproc_dat_ml$trained_model

