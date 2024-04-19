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

#------------------dataset prep and formatting-----------------------

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

#check status to make sure column is not still a list
str(json_tibble$paper_html)

#remove HTML tags, punctuation, digits from text 
#tokenize using hunspell with format = html and then paste
#is there a better way to remove this and 
#actually get rid of the space characters? >> for mob code weds? 
prep_html <- function(html) {
  tokens <- hunspell_parse(html, format = "html") %>%  
    unlist() %>% 
    paste0(collapse = " ")
  return(tokens)
}

json_tibble$paper_html <- map_chr(json_tibble$paper_html, prep_html)

#------------------split and nesting of data/folds--------------------

#set seed
set.seed(102899)

#set new_seq_data and availability as factors
gt_data <- json_tibble %>% 
  mutate(new_seq_data = factor(new_seq_data), 
         availability = factor(availability))


#initial split of data into training and test data 
#20240419- i think i still need this even though it's a nested sample
data_split <- initial_split(gt_data, strata = new_seq_data)
gt_train <- training(data_split)
gt_test <- testing(data_split)

#nested resampling of data using methods from mikropml
#20240419- can we specify what proportion goes into each re-sample? ie 80/20?
nested_resample <- nested_cv(gt_train, 
                             outside = vfold_cv(repeats = 10, strata = new_seq_data), 
                             inside = bootstraps(times = 10))
nested_resample


#---------------------modeling-------------------------------

#------recipes for dataset prep-------

#can tune num_tokens = tune()
#20240419 - do i need to use data = nested_resample?  
#OR is there a test/training set to use for this? 
#20240419 - why can't the recipe find the cols it needs? 
gt_recipe <- 
  recipe(new_seq_data ~ paper_html, data = nested_resample) %>% 
  # Do not use paper_doi and availability as predictors
  update_role(paper_doi, new_role = "id") %>%
  update_role(availability, new_role = "id") %>%
  step_tokenize(paper_html, engine = "spacyr") %>% 
  step_stopwords(paper_html, stopword_source = "smart") %>% 
  step_lemma(paper_html) %>% 
  step_ngram(paper_html, min_num_tokens = 1, num_tokens = tune()) %>% 
  show_tokens(paper_html)

head(gt_recipe, 2) 
  
#-----------model(s)------------

