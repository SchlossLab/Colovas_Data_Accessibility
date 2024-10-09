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
#{input.rscript} {input.metadata} {input.tokens} {wildcards.ml_variables}
# {resources.cpus} {output.rds} {output.ztable} {output.token_list}
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
ztable_filename <- as.character(input[6])
token_filename <- as.character(input[7])


# #local implementation
clean_text <- read_csv("Data/groundtruth.tokens.csv.gz")
metadata <- read_csv("Data/groundtruth.csv")
ml_var_snake <- "data_availability"
ml_var <- c("paper", ml_var_snake, "container.title")

#don't run this unless you really need it so that you don't
# accidentally save a file over this
# output_file <- "Data/groundtruth.data_availability.preprocessed.RDS"
# ztable_filename <- "Data/groundtruth.data_availability.zscoretable.csv"
# features_filename <- 


# set up the format of the clean_text dataframe
total_papers <- n_distinct(clean_text$paper_doi)

clean_tibble <-
    clean_text %>%
        mutate(n_papers = n(), .by = paper_tokens) %>% #n papers contain token
        filter(n_papers > 1 ) %>% #filter - tokens n_papers>1
        nest(data = -paper_tokens) %>% #nest everything except paper tokens?
        # mutate to find near zero variants
        mutate(nzv = map_dfr(data, \(x) {z = c(x$frequency, 
                                        rep(0,total_papers - nrow(x)));
                                        caret::nearZeroVar(z, saveMetrics = TRUE)})) %>%
        unnest(nzv) %>% #pull the nzv column out
        filter(!nzv) %>% # filter for things without nzv
        unnest(data) %>%  #unnest all the data
        select(paper_doi, paper_tokens, frequency) %>% #select these columns
        pivot_wider(id_cols = c(paper_doi),
                    names_from = paper_tokens, values_from = frequency,
                    values_fill = 0) #pivot wider and fill in zeros

# make 3 col df of token, mean, sd for the z scoring --------------------------

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

# save out z score table 
write_csv(z_score_table, file = ztable_filename)

# grab the needed metadata for the papers
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



#make a vector of the names of the grouped variables 
# that are collapsed by preprocess_data
token_groups <- vector(mode="list")
for(i in 1:8) {
    grp_var <- paste0("grp", i)
    token_groups[i] <- full_ml_pre$grp_feats[grp_var]
}
# save token groups out 
saveRDS(token_groups, file = token_file)






