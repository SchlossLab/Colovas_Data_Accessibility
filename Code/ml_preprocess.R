#!/usr/bin/env Rscript
#prep dataset for ML modeling by hand
#
#
#library statements
library(tidyverse)
library(tidytext)
library(jsonlite)
library(mikropml)

# load files
#for snakemake implementation
#{input.rscript} {input.metadata} {input.tokens} {wildcards.ml_variables} {resources.cpus} {output.rds}
input <- commandArgs(trailingOnly = TRUE)
metadata <- input[1]
clean_csv <- input[2]
ml_var_snake <- input[3]
ml_var <- c("paper", ml_var_snake, "container.title")
threads <- as.numeric(input[4])
str(threads)
output_file <- as.character(input[5])
str(output_file)
clean_text <- read.csv(clean_csv)
metadata <- read.csv(metadata)


# #local implementation
clean_text <- read_csv("Data/groundtruth.tokens.csv.gz")
metadata <- read_csv("Data/groundtruth.csv")
ml_var_snake <- "availability"
ml_var <- c("paper", ml_var_snake, "container.title")
output_file <- "Data/groundtruth.availability.preprocessed.RDS"


# set up the format of the clean_text dataframe 
total_papers <- n_distinct(clean_text$paper_doi)

clean_tibble <-
    clean_text %>% 
        mutate(n_papers = n(), .by = paper_tokens) %>% # number of papers a token appears in 
        filter(n_papers > 1 ) %>% # filter for tokens that appear in more than one paper
        nest(data= -paper_tokens) %>% #nest everything except paper tokens?
        # mutate to find near zero variants
        mutate(nzv = map_dfr(data, \(x) {z = c(x$frequency, 
                                        rep(0,total_papers - nrow(x))); 
                                        caret::nearZeroVar(z, saveMetrics = TRUE)})) %>%
        unnest(nzv) %>% #pull the nzv column out
        filter(!nzv) %>% # filter for things without near zero variance
        unnest(data) %>%  #unnest all the data
        select(paper_doi, paper_tokens, frequency) %>% #select only these colums
        pivot_wider(id_cols = c(paper_doi),
                            names_from = paper_tokens, values_from = frequency,
                            values_fill = 0) #pivot wider and fill in zeros


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





