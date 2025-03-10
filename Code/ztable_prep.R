#!/usr/bin/env Rscript
#prep ztable to collapse variables and add container titles
#
#
#library statements
library(tidyverse)
library(tidytext)
library(jsonlite)

# load files

#for snakemake implementation
# {input.rscript} {input.ztable} {input.tokenlist} {input.containerlist} {output.ztable} {output.tokens}
input <- commandArgs(trailingOnly = TRUE)
ztable <- read_csv(input[1])
token_list <- readRDS(input[2])
container_titles <-read_csv(input[3])
output_ztable <- as.character(input[4])
output_tokens <- as.character(input[5])
# str(output_file)


# # #local implementation
# # {input.rscript} {input.ztable} {input.tokenlist} {input.containerlist} {output}
# ztable_filename <- "Data/ml_prep/groundtruth.data_availability.zscoretable.csv.gz"
# token_filename <- "Data/ml_prep/groundtruth.data_availability.tokenlist.RDS"
# ztable <- read_csv(ztable_filename)
# token_list <- readRDS(token_filename)
# container_titles <-
#     read_csv("Data/ml_prep/groundtruth.data_availability.container_titles.csv")
# output_file <- "Data/groundtruth.data_availability.zscoretable_filtered.csv"


#collapse correlated variables in ztable --------------------------------------

token_unlist <-
    token_list %>% 
        unlist() %>% 
        tibble() %>%
        mutate(grpname = NA)


for(i in 1:nrow(token_unlist)){
    for(j in 1:length(token_list)){
        if(any(token_unlist$.[i] == token_list[[j]])){
           token_unlist$grpname[i] <-paste0("grp", j) 
        }
    }
}

token_unlist <-
    token_unlist %>%
        rename(., tokens = `.`)

tokens_withdata <-
    token_unlist %>% 
        left_join(., ztable, by = "tokens")

ztable_without_collapsed <-
    ztable %>% 
        anti_join(., tokens_withdata, by = "tokens")

tokens_toz <- 
    tokens_withdata %>%
        select(-tokens) %>% 
        rename(tokens = grpname) %>%
        unique()  

ztable_withgrps <-
    tokens_toz %>% 
        full_join(., ztable_without_collapsed) 
    


#sanity checks 
grep("grp", ztable_withgrps$tokens, value = TRUE)
for(i in 1:length(token_list)){
    print(token_list[i] %in% ztable_withgrps$tokens)
}

#sanity check for one specific thing
grep("creative common", ztable_withgrps$tokens, value = TRUE)

#add container.titles to the z score table-----------------------------------
# container_titles <-
#     container_titles %>% 
#         mutate(var_name = paste0("container.title_", container.title)) 

# containers_toz <-
# container_titles %>% 
#     select(var_name, token_mean, token_sd) %>% 
#     rename(tokens = var_name) 

ztable_full <-
container_titles %>% 
    full_join(ztable_withgrps) 
    
#sanity check    
grep("container", ztable_full$tokens, value = TRUE)

write_csv(ztable_full, file = output_ztable)
write_csv(tokens_withdata, file = output_tokens)


