#20250328 - looking for da statements in html files
#
#
#library
library(tidyverse)
library(rvest)
library(tidytext)
library(xml2)
library(textstem) #for stemming text variables
library(tm) #for text manipulation
library(data.table)
library(randomForest)
library(tokenizers)

# load in dataset of predicted stuff with metadata
metadata <- read_csv("Data/final/predictions_with_metadata.csv.gz")

webscrape <- function(doi) {
  
  abstract <- read_html(doi) %>%
    html_elements("section#abstract") %>%
    html_elements("[role = paragraph]")
  
  body <- read_html(doi) %>%
    html_elements("section#bodymatter") 
  
  side_panel<-read_html(doi) %>% 
    html_elements("#core-collateral-info")
  
  
  paper_html <- paste0(abstract, body, side_panel, collapse = " ") 
  
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

#one paper we know is marked wrong by model
grep("10.1128/spectrum.00886-24", metadata$doi_no_underscore)
html_file <-metadata$file[141934]


#can we just grab the core-data-availability section? yes
html_da<- 
read_html(html_file) %>% 
    html_elements("#core-collateral-info") %>%
    paste0()

html_article<-paste0(webscrape(html_file), html_da, collapse = " ")
prepped_article <-prep_html_tm(html_article)
view(prepped_article)
tokenized_article<-tokenize(prepped_article)

# #what about tokenizing everything between <article> and </article>
# html_article<- read_html(html_file) %>% 
#     html_elements("article") %>%
#     paste0(collapse = " ")

prepped_article <-prep_html_tm(html_article)
view(prepped_article)
tokenized_article<-tokenize(prepped_article)

#we can do this but 15K tokens and kinda funky 
tokenized_article %>%
print(n = 100)


#okay now we're looking at the training set 
training_set <- read_csv("Data/groundtruth/groundtruth.tokens.csv.gz")
gt_metadata<-read_csv("Data/new_groundtruth_metadata.csv.gz")
gt_csv_metadata<-read_csv("Data/new_groundtruth.csv")

#do we have nanopore data? yes
grep("nanopore", training_set$tokens, value = TRUE)


#do we have bioinformatic tools? no
grep("tool", gt_metadata$title, value = TRUE)
grep("info", gt_metadata$title, value = TRUE)


#do we have confirmation seq papers? 
grep("confirmation", training_set$tokens, value = TRUE)
conf_rows<- grep("confirmation", training_set$tokens)

conf_tokens <-training_set[conf_rows,] 

conf_papers <-unique(conf_tokens$doi_underscore) %>% tibble()

conf_metadata<-inner_join(gt_metadata, conf_papers, by = join_by("doi_underscore" == ".")) %>%
    inner_join(., gt_csv_metadata, by = join_by("doi_slash" == "doi"))
    
colnames(conf_metadata)

conf_metadata_filtered<-
    conf_metadata %>%
        select(doi_underscore, doi_slash, container.title.x, new_seq_data, data_availability, title.x)

view(conf_metadata_filtered)


gt_csv_metadata %>%
  select(issued, container.title) %>%
  view()
