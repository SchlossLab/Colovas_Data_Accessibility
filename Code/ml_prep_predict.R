#!/usr/bin/env Rscript
#prep dataset for ML model predictions
#
#
#library statements
library(tidyverse)
library(tidytext)
library(jsonlite)
library(mikropml)


# load files

#for snakemake implementation
#{input.rscript} {input.metadata} {input.tokens} {resources.cpus} {output.rds}
input <- commandArgs(trailingOnly = TRUE)
metadata <- input[1]
clean_csv <- input[2]
# ml_var_snake <- input[3]
ml_var <- c("paper", "container.title")
threads <- as.numeric(input[3])
str(threads)
output_file <- as.character(input[4])
str(output_file)
clean_text <- read.csv(clean_csv)
metadata <- read.csv(metadata)
ztable_filename <- as.character(input[5])
ztable <- read_csv(ztable_filename)
token_filename <- as.character(input[6])
token_groups <- readRDS(token_filename)

# #local implementation
clean_text <- read_csv("Data/1935-7885_alive.tokens.csv.gz")
metadata <- read_csv("Data/1935-7885_alive.csv")
# ml_var_snake <- "availability"
ml_var <- c("paper", "container.title")
output_file <- "Data/1935-7885_alive.preprocessed.RDS"
#do i have a practice one yet?
# ztable_filename <- as.character(input[6])
# ztable <- read_csv(ztable_filename)
# token_filename <- 


# set up the format of the clean_text dataframe 

# 20240923 - need to check if this is still the header in the files
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


# need metadata for the papers
need_meta <- select(metadata, all_of(ml_var))

# join clean_tibble and need_meta 
full_ml <- left_join(need_meta, clean_tibble, by = join_by(paper == paper_doi))

# DO NOT remove paper doi
#full_ml <- select(full_ml, !paper)

# create dummy variables for each of the journals
container_titles <- unique(full_ml$container.title)

for (i in 1:12) {
new_var <- paste0("container.title_", container_titles[i])
full_ml <-
    full_ml %>%
    #vectorized ifelse
    mutate("{new_var}" := ifelse(container.title == container_titles[i], 1, 0))
}

#collapse correlated features from training datasets


# iterate through each token group
for(j in 1:length(token_groups)){
    #if there are any of them in the dataset
   if(token_groups[j] %in% full_ml_practice) {
    #pseudocode
    # keep 1 of them (ie the first one)
    # rename to grp`j`(see below for renaming to variable of variables)
    #save out to dataset
   } 
   
}

# 


# use mikropml::preprocess_data on dataset
full_ml_pre <- preprocess_data(full_ml, outcome_colname = "paper", 
                                remove_var = NULL)
full_ml_pre$dat_transformed

# save preprocessed data as an RDS file 
saveRDS(full_ml_pre, file = output_file)

# 20240925 - abstracting data from model 

da_model_rds <- "Data/ml_results/groundtruth/rf/data_availability/final/final.rf.data_availability.102899.finalModel.RDS"
da_model <- readRDS(da_model_rds)
names(da_model)
head(da_model$xNames, 15)
tokens <- readRDS("Data/1935-7885_alive.preprocessed.RDS")

model_tokens <- da_model$xNames
str(tokens)
names(tokens)

head(tokens)
