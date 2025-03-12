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
#  {input.rscript} {input.metadata} {input.tokens} {wildcards.ml_variables} 
# {output.rds} {output.ztable} {output.tokenlist} {output.containerlist}
input <- commandArgs(trailingOnly = TRUE)
metadata <- input[1]
clean_csv <- input[2] 
ml_var_snake <- input[3]
ml_var <- c("doi_underscore", ml_var_snake, "container.title")
output_file <- as.character(input[4])
clean_text <- read.csv(clean_csv)
metadata <- read.csv(metadata) %>%
    mutate(doi_underscore = str_replace(doi, "\\/", "_"))
metadata <-metadata[-202, ]
ztable_filename <- as.character(input[5])
token_filename <- as.character(input[6])
container_title_filename <-as.character(input[7])



 # #local implementation
clean_text <- read_csv("Data/groundtruth/groundtruth.tokens.csv.gz") 
metadata <- read_csv("Data/new_groundtruth.csv") %>%
    mutate(doi_underscore = str_replace(doi, "\\/", "_")) 
metadata <-metadata[-202, ]
ml_var_snake <- "data_availability"
ml_var <- c("doi_underscore", ml_var_snake, "container.title")
# #don't run this unless you really need it so that you don't
# # accidentally save a file over this
# # output_file <- "Data/preprocessed/groundtruth.new_seq_data.preprocessed.RDS"
# # str(output_file)
# ztable_filename <- "Data/ml_prep/groundtruth.new_seq_data.zscoretable.csv"
# token_filename <- "Data/ml_prep/groundtruth.data_availability.tokenlist.RDS"
# container_title_filename <- "Data/ml_prep/groundtruth.data_availability.container_titles.csv"





# set up the format of the clean_text dataframe
total_papers <- n_distinct(clean_text$doi_underscore)

#this is the most computationally intensive part takes approx 10 mins
clean_tibble <-
    clean_text %>%
        mutate(n_papers = n(), .by = tokens) %>% #n papers contain token
        filter(n_papers > 1 ) %>% #filter - tokens n_papers>1
        nest(data = -tokens) %>% #nest everything except paper tokens?
        # mutate to find near zero variants
        mutate(nzv = map_dfr(data, \(x) {z = c(x$frequency, 
                                        rep(0,total_papers - nrow(x)));
                                        caret::nearZeroVar(z, saveMetrics = TRUE)}))
clean_tibble <- 
    clean_tibble %>% 
        unnest(nzv) %>% #pull the nzv column out
        filter(!nzv) %>% # filter for things without nzv
        unnest(data) %>%  #unnest all the data
        select(doi_underscore, tokens, frequency) %>% #select these columns
        pivot_wider(id_cols = doi_underscore,
                    names_from = tokens, values_from = frequency, 
                    values_fill = 0) #pivot wider and fill in zeros

# #20250312 - saved clean_tibble for testing
clean_tibble <- read_csv("Data/clean_tibble_testing.csv.gz")
# ct_colnames<-colnames(clean_tibble)
# #ok so this step does not introduce the underscores
# grep("_", ct_colnames, value = TRUE) 
# grep("interest", ct_colnames, value = TRUE) 
# grep("material", ct_colnames, value = TRUE) 

#i need to find the version that has the regular data_availability in it ---- everything above this works 
# grab the needed metadata for the papers
# colnames(metadata)
need_meta <- select(metadata, all_of(ml_var))



# join clean_tibble and need_meta 
full_ml <- left_join(clean_tibble, need_meta, by = join_by(doi_underscore))

# remove paper doi
full_ml <- select(full_ml, !doi_underscore)
# why is this column getting multiples in the training set



# # #lets look for the underscores here
# fml_colnames<-colnames(full_ml)
# any(duplicated(fml_colnames))
# #ok so this step does not introduce the underscores
# grep("_", fml_colnames, value = TRUE) 
# grep("interest", fml_colnames, value = TRUE) 
# grep("material", fml_colnames, value = TRUE) 


# use mikropml::preprocess_data on dataset
full_ml_pre <- preprocess_data(full_ml, outcome_colname = ml_var_snake, 
                                remove_var = NULL)
full_ml_pre$dat_transformed

# pre_colnames<-colnames(full_ml_pre$dat_transformed)
# #ok so this step does not introduce the underscores
# grep("_", pre_colnames, value = TRUE) 
# grep("interest", pre_colnames, value = TRUE) 
# grep("material", pre_colnames, value = TRUE) 


full_ml_pre$grp_feats

#20250307 - maybe i am just losing my mind and this was always here and i need to bring this code back 
# full_ml_pre$grp_feats

# save preprocessed data as an RDS file 
saveRDS(full_ml_pre, file = output_file)


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


#for loop to create container.titles to add to z score table
container_titles <- full_ml %>%
    count(container.title) %>%
    mutate(token_mean = (`n`/total_papers), 
            token_sd = sqrt(token_mean*(1-token_mean)), 
            tokens = paste0("container.title_", container.title)) %>%
    select(-`n`, -container.title)


write_csv(container_titles, file = container_title_filename)




#20250307 - bringing this back because apparently i need it
#make a vector of the names of the grouped variables 
# that are collapsed by preprocess_data

#looking to always get the right number of groups out of this

names<- names(full_ml_pre$grp_feats)
n_groups <-length(grep("grp", names, value = TRUE))


# #where is grp4?
# lengths <- vector(mode="list", length = length(full_ml_pre$grp_feats))
# for (i in 1:length(full_ml_pre$grp_feats)) {
#     lengths[[i]] <- length(full_ml_pre$grp_feats[[i]])
# }

# tail(lengths)

token_groups <- vector(mode="list")
for(i in 1:n_groups) {
    grp_var <- paste0("grp", i)
    token_groups[i] <- full_ml_pre$grp_feats[grp_var]
}
# save token groups out 
saveRDS(token_groups, file = token_filename)


#looking at categorical vars
clean_tibble$`interest importance` %>% table()
