#!/usr/bin/env Rscript
#prep ztable to collapse variables and add container titles
#
#
#library statements
library(tidyverse)
# library(tidytext)
# library(jsonlite)

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
da_model <- 
    readRDS("Data/ml_results/groundtruth/rf/data_availability/final/final.rf.data_availability.102899.finalModel.RDS")


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
        left_join(., ztable, by = "tokens") %>%
        mutate(token_mean = ifelse(is.na(token_mean), 0, token_mean), 
                token_sd = ifelse(is.na(token_sd), 1, token_sd)) 

ztable_without_collapsed <-
    ztable %>% 
        anti_join(., tokens_withdata, by = "tokens")

tokens_toz <- 
    tokens_withdata %>%
        group_by(grpname) %>% 
        select(-tokens) %>% 
        rename(tokens = grpname) %>%
        summarize(token_mean = mean(token_mean),
                token_sd = mean(token_sd)) 

ztable_withgrps <-
    tokens_toz %>% 
        full_join(., ztable_without_collapsed) 
    

for(i in 1:length(token_list)){
    print(token_list[i] %in% ztable_withgrps$tokens)
}


ztable_full <-
container_titles %>% 
    full_join(., ztable_withgrps) 

#20250423 - combine with the model so that you can truly be sure 
# model_names<-da_model$xNames
model_names<-tibble(model_names = da_model$xNames, in_model = "Yes")
ztable_stuff<-mutate(ztable_full, in_ztable = "Yes")

everything<-full_join(model_stuff, ztable_stuff, by = join_by(model_names == tokens)) %>% 
    filter(., in_model == "Yes") %>% 
    mutate(token_mean = ifelse(is.na(token_mean), 0, token_mean), 
                token_sd = ifelse(is.na(token_sd), 1, token_sd)) %>%
    select(model_names, token_mean, token_sd) %>%
    rename(tokens = model_names)

#sanity check 
filter(everything, is.na(token_sd))
which(is.na(everything), arr.ind = TRUE)
view(everything)

write_csv(everything, file = output_ztable)
write_csv(tokens_withdata, file = output_tokens)


