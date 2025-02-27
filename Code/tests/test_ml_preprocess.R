#!/usr/bin/env Rscript
#20250227
#test of prep dataset for ML modeling by hand
#
#
#library statements
library(tidyverse)
library(tidytext)
library(jsonlite)
library(mikropml)

# load files
#for snakemake implementation
#      {input.rscript} {input.metadata} {input.tokens} 
# {wildcards.ml_variables} {output.rds} {output.ztable} {output.tokenlist} 
# input <- commandArgs(trailingOnly = TRUE)
# metadata <- input[1]
# clean_csv <- input[2] 
# ml_var_snake <- input[3]
# ml_var <- c("paper", ml_var_snake, "container.title")
# output_file <- as.character(input[4])
# str(output_file)
# clean_text <- read.csv(clean_csv) %>%
#     rename(doi_underscore = doi_underscore)
# metadata <- read.csv(metadata)
# ztable_filename <- as.character(input[5])
# # token_filename <- as.character(input[])
# container_title_filename <-as.character(input[6])


 # #local implementation
# clean_text <- read_csv("Data/groundtruth/groundtruth.tokens.csv.gz") %>%
#     rename(doi_underscore = doi_underscore)
metadata <- read_csv("Data/new_groundtruth.csv") %>%
    mutate(doi_underscore = str_replace(doi, "\\/", "_"))
ml_var_snake <- "new_seq_data"
ml_var <- c("doi_underscore", ml_var_snake, "container.title")
# #don't run this unless you really need it so that you don't
# # accidentally save a file over this
# output_file <- "Data/preprocessed/groundtruth.new_seq_data.preprocessed.RDS"
# str(output_file)
# ztable_filename <- "Data/ml_prep/groundtruth.new_seq_data.zscoretable.csv "
# token_filename <- "Data/ml_prep/groundtruth.new_seq_data.tokenlist.RDS"
# container_title_filename <- "Data/groundtruth.data_availability.container_titles.RDS"


#20250227 - testing of old and new token files
old_tokens <-read_csv("Data/tests/train_html_tokens/old_token_list.csv") 
new_tokens <-read_csv("Data/tests/train_html_tokens/new_token_list.csv")


#testing with 10 papers and old tokens


# set up the format of the clean_text dataframe
old_total_papers <- n_distinct(old_tokens$doi_underscore)

#this is the most computationally intensive part takes 10 mins probs 
old_clean_tibble <-
    old_tokens %>%
        mutate(n_papers = n(), .by = tokens) %>% #n papers contain token
        filter(n_papers > 1 ) %>% #filter - tokens n_papers>1
        nest(data = -tokens) %>% #nest everything except paper tokens?
        # mutate to find near zero variants
        mutate(nzv = map_dfr(data, \(x) {z = c(x$frequency, 
                                        rep(0,old_total_papers - nrow(x)));
                                        caret::nearZeroVar(z, saveMetrics = TRUE)}))
old_clean_tibble <- 
    old_clean_tibble %>% 
        unnest(nzv) %>% #pull the nzv column out
        filter(!nzv) %>% # filter for things without nzv
        unnest(data) %>%  #unnest all the data
        select(doi_underscore, tokens, frequency) %>% #select these columns
       # unique() %>%
        pivot_wider(id_cols = doi_underscore,
                    names_from = tokens, values_from = frequency, 
                    values_fill = 0) 



#testing with 10 papers and new tokens 

# set up the format of the clean_text dataframe
new_total_papers <- n_distinct(new_tokens$doi_underscore)

#this is the most computationally intensive part takes 10 mins probs 
new_clean_tibble <-
    new_tokens %>%
        mutate(n_papers = n(), .by = tokens) %>% #n papers contain token
        filter(n_papers > 1 ) %>% #filter - tokens n_papers>1
        nest(data = -tokens) %>% #nest everything except paper tokens?
        # mutate to find near zero variants
        mutate(nzv = map_dfr(data, \(x) {z = c(x$frequency, 
                                        rep(0,new_total_papers - nrow(x)));
                                        caret::nearZeroVar(z, saveMetrics = TRUE)}))
new_clean_tibble <- 
    new_clean_tibble %>% 
        unnest(nzv) %>% #pull the nzv column out
        filter(!nzv) %>% # filter for things without nzv
        unnest(data) %>%  #unnest all the data
        select(doi_underscore, tokens, frequency) %>% #select these columns
       # unique() %>%
        pivot_wider(id_cols = doi_underscore,
                    names_from = tokens, values_from = frequency, 
                    values_fill = 0) #pivot wider and fill in zeros


# make 3 col df of token, mean, sd for the z scoring --------------------------

# get tokens from the names of the columns
# remove doi_underscore from tokens list
tokens <- names(clean_tibble)
tokens <-
    tokens[!tokens == "doi_underscore"]

#initialize vectors for the loop 
token_mean <- vector(mode="double")
token_sd <- vector(mode="double")

#for loop to make the mean and sd vectors 
 for (i in 2:ncol(clean_tibble)) {
    token_mean[[i-1]] <- mean(clean_tibble[[i]])
    token_sd[[i-1]] <- sd(clean_tibble[[i]])
 }

z_score_table <- tibble(tokens, token_mean, token_sd)


# save out z score table 
write_csv(z_score_table, file = ztable_filename)

#i need to find the version that has the regular data_availability in it ---- everything above this works 
# grab the needed metadata for the papers
colnames(metadata)
need_meta <- select(metadata, all_of(ml_var)) 

# join clean_tibble and need_meta 
old_full_ml <- left_join(need_meta, old_clean_tibble, by = join_by(doi_underscore))
new_full_ml <-left_join(need_meta, new_clean_tibble, by = join_by(doi_underscore))

#20241016 - for loop to create container.titles table 
# i don't think this is right honestly... 
# but we will have to open this script to do it all 
container_titles <- full_ml %>%
    count(container.title) %>%
    mutate(token_mean = (`n`/500), 
            token_sd = sqrt(token_mean*(1-token_mean))) 

saveRDS(container_titles, file = container_title_filename)


# remove paper doi
old_full_ml <- select(old_full_ml, !doi_underscore)
new_full_ml <- select(new_full_ml, !doi_underscore)

# use mikropml::preprocess_data on dataset
old_full_ml_pre <- preprocess_data(old_full_ml, outcome_colname = ml_var_snake, 
                                remove_var = NULL)
old_full_ml_pre$dat_transformed
str(old_full_ml_pre)

new_full_ml_pre <- preprocess_data(new_full_ml, outcome_colname = ml_var_snake, 
                                remove_var = NULL)
new_full_ml_pre$dat_transformed

# save preprocessed data as an RDS file 
saveRDS(full_ml_pre, file = output_file)


old_full_ml_pre$removed_feats
new_full_ml_pre$removed_feats

#20250225 - plot twist there aren't any grouped variables
#make a vector of the names of the grouped variables 
# that are collapsed by preprocess_data
# token_groups <- vector(mode="list")
# for(i in 1:8) {
#     grp_var <- paste0("grp", i)
#     token_groups[i] <- full_ml_pre$grp_feats[grp_var]
# }
# # save token groups out 
# saveRDS(token_groups, file = token_filename)






