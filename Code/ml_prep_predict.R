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
# {input.rscript} {input.metadata} {input.tokens} {input.ztable} 
# {input.tokenlist} {input.containerlist} {output.rds}
input <- commandArgs(trailingOnly = TRUE)
metadata <- read.csv(input[1])
clean_text <- read.csv(input[2])
ml_var <- c("paper", "container.title")
output_file <- as.character(input[3])
str(output_file)
ztable <- read_csv(input[4])
token_groups <- readRDS(input[5])
container_titles <-readRDS(input[6])

# #local implementation
clean_text <- read_csv("Data/1935-7885_alive.tokens.csv.gz")
metadata <- read_csv("Data/1935-7885_alive.csv")
# ml_var_snake <- "availability"
ml_var <- c("paper", "container.title")
output_file <- "Data/1935-7885_alive.preprocessed.RDS"
#do i have a practice one yet?
ztable_filename <- "Data/groundtruth.data_availability.zscoretable.csv"
token_filename <- "Data/groundtruth.data_availability.tokenlist.RDS"
ztable <- read_csv(ztable_filename)
token_list <- readRDS(token_filename)
container_titles <-
    readRDS("Data/groundtruth.data_availability.container_titles.RDS")


# set up the format of the clean_text dataframe 
# remove near zero variants
total_papers <- n_distinct(clean_text$paper_doi)

#takes ~10 minutes for ground truth (n=500)
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


#save full ml for troubleshooting purposes
#saveRDS(full_ml, file = "Data/JMBE_full_ml.RDS")
full_ml <- readRDS("Data/JMBE_full_ml.RDS")


#pivot full_ml to long------------------------------------ 
long_full_ml <-
    full_ml %>%
        pivot_longer(cols = -c(paper, container.title), 
                    names_to = "tokens", 
                    values_to = "num_appearances")
#sanity check         
head(long_full_ml, 20)


#join long_full_ml to ztable by tokens----------------------------


#find tokens missing from full_ml 
missing_full_ml_tokens <-anti_join(ztable, long_full_ml)

#add columns to full_ml
for (i in 1:nrow(missing_full_ml_tokens)) {

    missing_var <- missing_full_ml_tokens$tokens[i]
   
    full_ml_with_missing <-
        full_ml %>%
            mutate("{missing_var}" := 0)

}

#make full_ml_with_missing long again-------------------------------- 
long_full_ml_with_missing <-
    full_ml_with_missing %>%
        pivot_longer(cols = -c(paper, container.title), 
                    names_to = "tokens", 
                    values_to = "num_appearances")


#join with z table
joined_full_ml_tokens <-semi_join(long_full_ml_with_missing, 
                        ztable, 
                        by = join_by(tokens))
#sanity check 
head(joined_full_ml_tokens)

# pivot back to wide -------------------------------------------------
wide_joined_full_ml_tokens <-
    joined_full_ml_tokens %>%
        pivot_wider(id_cols = c(paper, container.title), 
                    id_expand = TRUE,
                    names_from = tokens, 
                    values_from = num_appearances, 
                    names_repair = "minimal", 
                    values_fill = 0) 


# create dummy variables for each of the journals---------------------

container_titles <-
    container_titles %>% 
        mutate(var_name = paste0("container.title_", container.title)) 

    for (i in 1:nrow(container_titles)) {
    new_var <- container_titles$var_name[i]
    wide_joined_full_ml_tokens <-
        wide_joined_full_ml_tokens %>%
        #vectorized ifelse
        mutate(
        "{new_var}" := ifelse(container.title == container_titles$container.title[i], 1, 0))
    }

# remove container.title 
wide_joined_full_ml_tokens <-
    wide_joined_full_ml_tokens %>%
        select(-container.title)

#sanity check - should be 12
pivoted_colnames <- colnames(wide_joined_full_ml_tokens)
grep("container*", pivoted_colnames, value = TRUE) 


#collapse correlated features from training datasets------------------------------

# iterate through each token group

    keep_groups <- vector("character", length(token_list))
    for(j in 1:length(token_list)){
        #if none of the tokens are found in dataset
            if(!any(token_list[[j]] %in% colnames(wide_joined_full_ml_tokens))) {
            #add grp'i' column to dataset and fill with 0s
            new_var <- paste0("grp", j)
            wide_joined_full_ml_tokens <-
                wide_joined_full_ml_tokens %>%
                    mutate("{new_var}" := 0)
            }
            
            else {
                new_var <- paste0("grp", j)
                #get positions of true tokens in token list j
                position <- which(any(token_list[[j]] %in% colnames(wide_joined_full_ml_tokens)))[1]
                # give you column name
                representative <- token_list[[j]][position]
                wide_joined_full_ml_tokens <-
                    wide_joined_full_ml_tokens %>%
                    mutate("{new_var}" := wide_joined_full_ml_tokens$representative)
            }
    }

#sanity check 
pivoted_colnames2 <- colnames(wide_joined_full_ml_tokens)
grep("grp", pivoted_colnames2, value = TRUE) 


#finally apply z score to the data!--------------------------

# 20241017
# i have no clue what just happened because apparently now none 
# of the colnames are in the ztable?????
# which i swear i added them all 
wide_colnames <- colnames(wide_joined_full_ml_tokens)
wide_colnames == ztable_full$tokens

ztable_full$tokens %in% wide_colnames


for(i in 1:ncol(wide_joined_full_ml_tokens)){
wide_joined_full_ml_tokens[ztable_full[[1]][i]] %>%
    map(., \(x) ((x-ztable_full[[2]][i])/ztable_full[[3]][i]))
}




# eventually - save preprocessed data as an RDS file 
saveRDS(full_ml_pre_prediction, file = output_file)

