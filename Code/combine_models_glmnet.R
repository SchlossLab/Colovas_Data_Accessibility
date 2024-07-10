#!/usr/bin/env Rscript
# combine_models_glmnet.R
#
#
#library statements
library(tidyverse)
library(mikropml)

#snakemake params from trainML
# model="Data/ml_results/{dataset}/{method}_{seed}_{ml_vars}_model.Rds",
# perf="Data/ml_results/{dataset}/{method}_{seed}_{ml_vars}_performance.csv",
# {input.rscript} {input.rds} {params.seed} {wildcards.ml_variables} {output.model} {output.perf}