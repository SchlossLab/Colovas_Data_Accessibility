#TidyModels 
#
#
#libraries
library(tidymodels)
library(jsonlite)
library(textrecipes)
library(stringr)
library(rvest) #for text cleanup
library(hunspell) #may need as a tokenizer
library(spacyr) #for lemmatization 

#may or may not need the following packages, IDK yet
#library(discrim) #may need for bayes model
#library(broom.mixed) #converting bayesian models to tidy tibble
#library(dotwhisker) #visualize regression results
#library(rpart) #may need for visualization?
#library(rpart.plot) #may need for visualization?
#library(vip) #may need for visualization?


#read and unserialize json file (gtss30)
jsonfile <- "Data/gt_subset_30_data.json"
json_data <- read_json(jsonfile)  
json_data <- unserializeJSON(json_data[[1]])

#set up dataset for 1 ML model; 4 vars
#paper, new_seq_data, availability text_tibble
json_tibble <- tibble(paper_doi = json_data$`data$paper`,
                      new_seq_data = json_data$`data$new_seq_data`,
                      availability = json_data$`data$availability`,
                      paper_html = json_data$`webscraped_data`)

#fixed unnesting 20240416
json_tibble <- unnest_wider(json_tibble, paper_html, names_sep = "") %>% 
  unnest_wider(paper_html., names_sep = "") %>% 
  mutate(paper_html = paste0(paper_html.1, paper_html.2)) %>% 
  select(c(-paper_html.1, -paper_html.2))

#check status
str(json_tibble$paper_html)

#remove HTML tags, punctuation, digits from text 
#20240418 - this function doesn't work because the whitespace 
# characters still exist and become tokens
prep_html <- function(html) {
  
  html <- read_html(html) %>% html_text()
  html <- str_replace_all(html, '[[:punct:]]', " ")
  html <- str_replace_all(html, '[[:digit:]]', " ")
  html <- str_replace_all(html, '[[:space:]]', " ")
}

json_tibble_prepped <- json_tibble
json_tibble_prepped$paper_html <- map_chr(json_tibble$paper_html, prep_html)

# -------------trying to fix function prep_html-----------------------

#unnest_tokens(format = "html") uses tokenizer "hunspell" 
#hunspell_parse generates tokens with pkg hunspell
tokens <- hunspell_parse(one_html, format = "html") %>% 
  cbind() 
one_chr <- unnest_wider(tokens)

#hunspell_stem stems(actually looks more like a lemm to me)
#hunspell_stem REMOVES words that it cannot find the stems for!
stems <- hunspell_stem(tokens)

#rvest support to remove html tags before we tokenize instead

one_html <- json_tibble$paper_html[1]

clean_html <- read_html(one_html) %>% html_text()

#--------------end of function troubleshooting------------------------

#set seed
set.seed(102899)

#set new_seq_data and availability as factors
gt_data <- json_tibble %>% 
  mutate(new_seq_data = factor(new_seq_data), 
         availability = factor(availability))

#initial split of data into training and test data 
data_split <- initial_split(gt_data, strata = new_seq_data)
gt_train <- training(data_split)
gt_test <- testing(data_split)


#begin recipes
gt_recipe <- 
  recipe(new_seq_data ~ paper_html, data = gt_train) %>% 
  step_tokenize(paper_html, engine = "spacyr") %>% 
  # step_stem(paper_html, custom_stemmer = hunspell_parse, 
  #           options = list(format = "html")) %>% 
  step_stopwords(paper_html) %>% 
  step_lemma(paper_html) %>% 
  step_ngram(paper_html, min_num_tokens = 1, num_tokens = 3) %>% 
  show_tokens(paper_html)

head(gt_recipe, 1) 
  


