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
ztable <- read_csv(input[3])
token_groups <- readRDS(input[4])
container_titles <-readRDS(input[5])
output_file <- as.character(input[6])
str(output_file)

# # #local implementation
# clean_text <- read_csv("Data/1935-7885_alive.tokens.csv.gz")
# metadata <- read_csv("Data/1935-7885_alive.csv")
# # ml_var_snake <- "availability"
# ml_var <- c("paper", "container.title")
# output_file <- "Data/1935-7885_alive.preprocessed.RDS"
# #do i have a practice one yet?
# ztable_filename <- "Data/groundtruth.data_availability.zscoretable_filtered.csv"
# token_filename <- "Data/groundtruth.data_availability.tokenlist.RDS"
# ztable <- read_csv(ztable_filename)
# token_list <- readRDS(token_filename)
# container_titles <-
#     readRDS("Data/groundtruth.data_availability.container_titles.RDS")


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
full_ml <- left_join(need_meta, clean_tibble, by = join_by(paper == paper_doi)) %>%
            rename(paper_doi = paper)


#sanity check - make sure paper_doi is first column 
head(full_ml)


# #save full ml for troubleshooting purposes
# #saveRDS(full_ml, file = "Data/JMBE_full_ml.RDS")
full_ml <- readRDS("Data/JMBE_full_ml.RDS") %>%
    rename(paper_doi = paper)



#pivot full_ml to long------------------------------------ 
long_full_ml <-
    full_ml %>%
        pivot_longer(cols = -c(paper_doi, container.title), 
                    names_to = "tokens", 
                    values_to = "num_appearances")
#sanity check         
head(long_full_ml, 20)
nrow(full_ml)

#join long_full_ml to ztable by tokens----------------------------


#find tokens missing from full_ml 
missing_full_ml_tokens <-anti_join(ztable, long_full_ml)

#sanity check
head(missing_full_ml_tokens, 20)
nrow(missing_full_ml_tokens)


#add missing columns to full_ml
full_ml_with_missing <- full_ml
for (i in 1:nrow(missing_full_ml_tokens)) {

    missing_var <- missing_full_ml_tokens$tokens[[i]]
    
    full_ml_with_missing <-
        full_ml_with_missing %>%
            mutate("{missing_var}" := 0)

}

#sanity check, more columns 
ncol(full_ml)
ncol(full_ml_with_missing)
head(full_ml_with_missing)

#make full_ml_with_missing long again-------------------------------- 
long_full_ml_with_missing <-
    full_ml_with_missing %>%
        pivot_longer(cols = -c(paper_doi, container.title),
                    names_to = "tokens",
                    values_to = "num_appearances")

head(long_full_ml_with_missing, 20)

#join with z table
joined_full_ml_tokens <-semi_join(long_full_ml_with_missing, 
                        ztable, 
                        by = join_by(tokens))
#sanity check 
head(joined_full_ml_tokens)

# pivot back to wide -------------------------------------------------
wide_joined_full_ml_tokens <-
    joined_full_ml_tokens %>%
        pivot_wider(id_cols = c(paper_doi, container.title), 
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


#finally apply z score to the data!--------------------------

#sanity check that all colnames are in ztable 
#and all ztable are in the colnames 
#except for paper_doi of course
wide_colnames <- colnames(wide_joined_full_ml_tokens)
ztable$tokens %in% wide_colnames
wide_colnames %in% ztable$tokens

#check for NAs
any(is.na.data.frame(wide_joined_full_ml_tokens))

ncol(wide_joined_full_ml_tokens)
nrow(ztable)


#apply z scoring!!!
zscored_table <- tibble(.rows = nrow(wide_joined_full_ml_tokens))
zscored_table[1] <- wide_joined_full_ml_tokens[1]

for(i in 1:nrow(ztable)){
    zscored_table[ztable[[1]][[i]]] <-
    wide_joined_full_ml_tokens[ztable[[1]][[i]]] %>%
        modify(., \(x) ((x-ztable[[2]][[i]])/ztable[[3]][[i]]))
}


wide_joined_full_ml_tokens[ztable[[1]][[1]]]
head(zscored_table, 20)



# eventually - save preprocessed data as an RDS file 
saveRDS(zscored_table, file = output_file)

