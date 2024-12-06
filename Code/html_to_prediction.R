#!/usr/bin/env Rscript
#take scraped html and end with a tibble of predictions
#
#
#
# library statements
library(tidyverse)
library(rvest)
library(tidytext)
library(xml2)
library(httr2)
library(textstem) #for stemming text variables
library(tm) #for text manipulation
# library(data.table) #unclear if i need this one yet
# library(mikropml)
library(randomForest)
library(tokenizers)


# load static files 
lookup_table <-read_csv("Data/papers/lookup_table.csv.gz")
lookup_table <-
  lookup_table %>%
    mutate(da_prediction = NA, 
          nsd_prediction = NA)

tokens_to_collapse <-read_csv("Data/ml_prep/tokens_to_collapse.csv")
ztable <- read_csv("Data/ml_prep/groundtruth.data_availability.zscoretable_filtered.csv")
da_model <- 
    readRDS("Data/ml_results/groundtruth/rf/data_availability/final/final.rf.data_availability.102899.finalModel.RDS")
nsd_model <- 
    readRDS("Data/ml_results/groundtruth/rf/new_seq_data/final/final.rf.new_seq_data.102899.finalModel.RDS")



#functions

#function for reading html, remove figs/tables, 
#and concatenate abstract and body (using rvest, xml2)
webscrape <- function(doi) {
  
  abstract <- read_html(doi) %>%
    html_elements("section#abstract") %>%
    html_elements("[role = paragraph]")
  
  body <- read_html(doi) %>%
    html_elements("section#bodymatter") 
  
  body_notables <- body %>%
    html_elements(css = ".table > *") %>%
    html_children() %>%
    xml_remove()
  
  body_nofigures <- body %>%
    html_elements(css = ".figure-wrap > *") %>%
    html_children() %>%
    xml_remove()
  
  paper_html <- paste0(abstract, body, collapse = " ") 
  
  return(paper_html)
  
}

# function to prep HTML using package tm
prep_html_tm <- function(html) {
  html <- as.character(html)
  html <- read_html(html) %>% html_text()
  html <- str_to_lower(html)
  html <- stripWhitespace(html)
  html <- removePunctuation(html)
  html <- str_remove_all(html, "[[:digit:]]")
  html <- str_remove_all(html, "[[^a-z ]]")
  html <- lemmatize_strings(html)
}



# tokenize paper with snowball stopwords

tokenize <- function(clean_html) {

  tokens <- tokenize_ngrams(clean_html, 
                  n_min = 1, n = 3,
                  stopwords = stopwords::stopwords("en", source = "snowball")) 
  token_tibble <-tibble(tokens = unlist(tokens))
  token_tibble <- add_count(token_tibble, tokens, name = "frequency")
  token_tibble <- unique(token_tibble)

}


#collapse correlated variables for z scoring
collapse_correlated <- function(token_tibble) {
  for(i in 1:nrow(token_tibble)){
    for(j in 1:nrow(tokens_to_collapse)){
      if (token_tibble$tokens[i] == tokens_to_collapse$tokens[j]){
        token_tibble$tokens[i] <-tokens_to_collapse$grpname[j]
      } 
    }
  }
  return(unique(token_tibble))
}


zscore <-function(all_tokens) {

  while(anyDuplicated(all_tokens$tokens) > 1){
  index<-anyDuplicated(all_tokens$tokens)
  value<-all_tokens$tokens[index]
  all_dups<-grep(value, all_tokens$tokens)
  dups_table<-all_tokens[all_dups,]
  max_freq<-which.max(dups_table$frequency)
  to_remove<-all_dups[-max_freq]
  all_tokens<-all_tokens[-to_remove,]
}

  zscored <-all_tokens %>%
  mutate(zscore = (frequency - token_mean)/token_sd) %>% 
  select(c(tokens, zscore))  



  wide_tokens <- 
    pivot_wider(zscored, 
                id_cols = NULL,
                names_from = tokens, 
                values_from = zscore, 
                names_repair = "minimal", 
                values_fill = 0)

  wide_tokens <-
  wide_tokens %>% 
      rename("paper.y" = "paper",
          "`interest importance`_1" = "interest importance",
          "`material method bacterial`_1" = "material method bacterial")

  return(wide_tokens)
}



get_predictions<-function(zscored){

da_prediction <-
     predict(da_model, newdata = zscored, type = "response")

nsd_prediction <-
     predict(da_model, newdata = zscored, type = "response")

  return(c(da_prediction, nsd_prediction))
}


total_pipeline<-function(filename){
  if(file.size(filename) > 0 && file.exists(filename)) {
    index <- grep(filename, lookup_table$html_filename)
    container.title <-lookup_table$container.title[index]
    update_journal <-paste0("container.title_", container.title)

    webscrape_results <- webscrape(filename)

    if(webscrape_results != ""){
      clean_html <- prep_html_tm(webscrape_results)

      token_tibble <- tokenize(clean_html) 

      collapsed <-collapse_correlated(token_tibble) 
        

      #get only variables in the model
      all_tokens <- full_join(collapsed, ztable, by = "tokens") %>%
        filter(!is.na(token_mean)) %>%
        replace_na(list(frequency = 0)) 
        

      #fill journal name 
      journal_index <-which(all_tokens$tokens %in% update_journal)
      all_tokens$frequency[journal_index] <-1

        zscored <- zscore(all_tokens)

        predictions <- as.character(get_predictions(zscored))

      } 
      else{
        predictions <- c(NA, NA)
      }
    }
  return(predictions)
}


#need to benchmark this !!! a few seconds for 20, but something ain't right
for(i in 1:nrow(lookup_table)) { 
  print(i)
  predictions <-total_pipeline(lookup_table$html_filename[i])
  lookup_table$da_prediction[i] <-predictions[1]
  lookup_table$nsd_prediction[i] <-predictions[2]
}



write_csv(lookup_table, file = "Data/predicted/final_predictions.csv.gz")


#20241205 - error in no.9485 with pivoting wider
# i<-9485
# filename<-lookup_table$html_filename[9485]
#   # too many tokens 1829 instead of 1828- what duplicate
# all_tokens %>% count(tokens) %>% arrange(-n)
# #values are diff but not unique 
# grep("grp6", all_tokens$tokens)
# all_tokens[c(338, 362),]

# #20241206 - error in [1] 78614- Error in `path_to_connection()`:
# i<-78614
# filename<-lookup_table$html_filename[i]
# #file was actually empty after 'webscrape' - return NA 
# lookup_table$paper[i]

