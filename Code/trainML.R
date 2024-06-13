#!/usr/bin/env Rscript
# trainML.R
#
#
#
# library statements
library(tidyverse)
library(tidytext)
library(mikropml)


# model="Data/ml_results/{dataset}/runs/{method}_{seed}_{ml_vars}_model.Rds",
# perf="Data/ml_results/{dataset}/runs/{method}_{seed}_{ml_vars}_performance.csv",
# {input.rscript} {input.rds} {params.seed} {wildcards.method} {wildcards.ml_variables} {output.model} {output.perf}
       
input <- commandArgs(trailingOnly = TRUE)
rds <- input[1]
data_processed <- readRDS(rds)
seed <- as.numeric(input[2])
method <- input[3]
ml_var_snake <- input[4]
output_model <- input[5]
output_perf <- input[6]


# run model using mikropml::run_ml
ml_results <- run_ml(data_processed$dat_transformed,
                   method = method,  outcome_colname = ml_var_snake,
                   find_feature_importance = FALSE, 
                   seed = seed)

#write results to files 
write.csv(ml_results$performance, file = output_perf)
#readr::write_csv(ml_results$test_data, snakemake@output[["test"]])
saveRDS(ml_results$trained_model, file = output_model)

