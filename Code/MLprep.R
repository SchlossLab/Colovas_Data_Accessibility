#!/usr/bin/env Rscript
#prep dataset for ML modeling 
#
#
#library statements
library(tidyverse)
library(tidytext)
library(jsonlite)
library(mikropml)
# options(future.globals.maxSize = 768 * 1024^3)
# options(expressions = 5e5)


# load files

#for snakemake implementation
#{input.rscript} {input.metadata} {input.tokens} {wildcards.ml_variables} {wildcards.ncores} {output.rds}
input <- commandArgs(trailingOnly = TRUE)
metadata <- input[1]
ml_var_snake <- input[3]
ml_var <- c("paper", ml_var_snake, "container.title")
clean_csv <- input[2]
threads <- as.numeric(input[4])
str(threads)
output_file <- as.character(input[5])
str(output_file)
clean_text <- read.csv(clean_csv)
metadata <- read.csv(metadata)


# doFuture::registerDoFuture()
# future::plan(future::multicore, workers = 100)

# #other implementation
# clean_text_small <- read_csv("Data/gt_subset_30.tokens.csv.gz")
# metadata <- read.csv("Data/gt_subset_30.csv")
# ml_var_snake <- "new_seq_data"
# ml_var <- c("paper", ml_var_snake, "container.title")

# clean_text <- read_csv("Data/groundtruth.tokens.csv.gz")
# metadata <- read_csv("Data/groundtruth.csv")
# ml_var_snake <- "new_seq_data"
# ml_var <- c("paper", ml_var_snake, "container.title")
# output_file <- "Data/groundtruth.new_seq_data.preprocessed.RDS"


# set up the format of the clean_text dataframe 
# need to remove: 
    # singleton columns
    # columns with nzv- this should also remove singletons
        # could count the number of papers that each token shows up in 
        # know total number of papers, can add missing papers to have 0s
        # add that to nearZeroVar
    # columns with absolute value of correlation of 1
total_papers <- n_distinct(clean_text$paper_doi)

clean_tibble <-
    clean_text %>% 
        mutate(n_papers = n(), .by = paper_tokens) %>%
        filter(n_papers > 1 ) %>%
        nest(data= -paper_tokens) %>%
        mutate(nzv = map_dfr(data, \(x) {z = c(x$frequency, rep(0,total_papers - nrow(x))); caret::nearZeroVar(z, saveMetrics = TRUE)})) %>%
        unnest(nzv) %>%
        filter(!nzv) %>% 
        unnest(data) %>% 
        select(paper_doi, paper_tokens, frequency) %>%
        pivot_wider(id_cols = c(paper_doi),
                            names_from = paper_tokens, values_from = frequency,
                            values_fill = 0) 
   
# each token is a column 
# clean_tibble <- pivot_wider(clean_text_small, id_cols = c(paper_doi),
#                            names_from = paper_tokens, values_from = frequency,
#                            names_sort = TRUE, values_fill = 0) 


# need metadata for the papers
need_meta <- select(metadata, all_of(ml_var))

# join clean_tibble and need_meta 
full_ml <- left_join(need_meta, clean_tibble, by = join_by(paper == paper_doi))

# remove paper doi
full_ml <- select(full_ml, !paper)

# use mikropml::preprocess_data on dataset
full_ml_pre <- preprocess_data(full_ml, outcome_colname = ml_var_snake, 
                                remove_var = NULL)
full_ml_pre$dat_transformed

# save preprocessed data as an RDS file 
saveRDS(full_ml_pre, file = output_file)





