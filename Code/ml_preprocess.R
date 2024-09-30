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

#don't run this unless you really need it so that you don't accidentally save a file over this
#output_file <- "Data/groundtruth.availability.preprocessed.RDS"


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

# make 3 col df of token, mean, sd

# get tokens from the names of the columns 
# remove paper_doi from tokens list
tokens <- names(clean_tibble)
tokens <-
    tokens[!tokens == "paper_doi"]

#initialize vectors for the loop 
token_mean <- vector(mode="list")
token_sd <- vector(mode="list")

#for loop to make the mean and sd vectors 
 for (i in 2:ncol(clean_tibble)) {
    token_mean[[i-1]] <- mean(clean_tibble[[i]])
    token_sd[[i-1]] <- sd(clean_tibble[[i]])
 }

z_score_table <- tibble(tokens, token_mean, token_sd)


  # This is how you create an environment (hash map)
  z_score_hash <- new.env(hash=TRUE)

  #for loop to fill the hash environment 
  for(i in seq_along(z_score_table$tokens)) {
    # You have to use a double bracket to add to the hash map
    z_score_hash[[z_score_table$tokens[[i]]]] <- 
        list(mean = z_score_table$token_mean[i], 
            sd = z_score_table$token_sd[i])
  }

#20240930- need filenames somewhere that makes sense
#  but this will work great to save and then load/apply 
saveRDS(z_score_hash, file = "zscore_availability.RDS")
zscore_loaded <- readRDS("zscore_availability.RDS")

# 20240927 - need to save the z_score_table for easy access to the tokens? 
# can we use the hash map list
# also need to save the hash map
# need to filter the tokens from other datasets to the tokens from the training sets
# each model will need to be diff preprocessing 


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





