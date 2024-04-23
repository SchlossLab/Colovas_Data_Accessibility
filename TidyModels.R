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

#20240422 - this one doesn't actually work even though it worked last week
#remove HTML tags, punctuation, digits from text 
#tokenize using hunspell with format = html and then paste
# 1+ hour benchmark, does not work? microbenchmark::microbenchmark
prep_html_hunspell <- function(html) {
  tokens <- hunspell_parse(html, format = "html") %>%  
    unlist() %>% 
    paste0(collapse = " ")
  return(tokens)
}

#str_replace_all- remove HTML tags, punctuation, digits from text 
# 1 min benchmark using microbenchmark::microbenchmark
prep_html_str <- function(html) {
  
  html <- read_html(html) %>% html_text()
  html <- str_replace_all(html, '[[:punct:]]', " ")
  html <- str_replace_all(html, '[[:digit:]]', " ")
  html <- str_replace_all(html, '[[:space:]]', " ")
}

#clean up html text 
json_tibble$paper_html <- map_chr(json_tibble$paper_html, prep_html_str)


#------------------split and nesting of data/folds--------------------

#set seed
set.seed(102899)

#set new_seq_data and availability as factors
gt_data <- json_tibble %>% 
  mutate(new_seq_data = factor(new_seq_data), 
         availability = factor(availability))

#--------------initial split of data----------------

#initial split of data into training and test data 
data_split <- initial_split(gt_data, strata = new_seq_data, prop = 0.8)
gt_train <- training(data_split)
gt_test <- testing(data_split)
head(gt_train, 3)


#------recipes for dataset prep--------------------

#i think that i need to do the recipe BEFORE i do all the folds 

#20240423 - update_role provides an error 
#"Error in `update_role()`: ! Can't select columns that don't exist.
#commented out show_tokens() : cannot bake a tuneable recipe

library(text2vec)

gt_recipe <- 
  recipe(new_seq_data ~ paper_html, data = gt_train) %>% 
  # Do not use paper_doi and availability as predictors
  # update_role(paper_doi, new_role = "id") %>%
  # update_role(availability, new_role = "id") %>%
  step_tokenize(paper_html, engine = "spacyr") %>% 
  step_stopwords(paper_html, stopword_source = "smart") %>% 
  step_lemma(paper_html) %>% 
  #can change num_tokens = tune()
  step_ngram(paper_html, min_num_tokens = 1, num_tokens = tune()) %>% 
  step_texthash(paper_html)

#%>% #show_tokens(paper_html)

head(gt_recipe, 2) 

# ------------------tune recipe----------------------------------

#generate set of tuning values (only will tune 1, 2, 3 tokens)
tuning_grid <- crossing(num_tokens = c(1, 2, 3), 
                        penalty = 10^seq(-3, 0, length = 5), 
                        mixture = c(0.01, 0.25, 0.50, 0.75, 1))
tuning_grid

#create tuning folds to tune parameter
tuning_folds <- vfold_cv(gt_train)
tuning_folds

#need a model + workflow object to tune parameter
#logistic regression using glmnet
tuning_model <- 
  logistic_reg(penalty = tune(), 
               mixture = tune()) %>% 
  set_engine("glmnet") 
tuning_model
  
tuning_wf <- workflow() %>% 
  add_recipe(gt_recipe) %>% 
  add_model(tuning_model)
  
#libary(sparklyr)

# #tune the parameter
# tuned_tokens <- tune_grid(tuning_wf,
#   resamples = tuning_folds, 
#   grid = tuning_grid)


# -----------------nested resampling--------------------------------

#nested resampling of data using methods from mikropml
#20240419 - can we specify what proportion goes into each re-sample? ie 80/20?
#20240423 - "! Nested resampling is not currently supported with tune."
nested_resample <- nested_cv(gt_train, 
                             outside = vfold_cv(repeats = 5, 
                                                strata = new_seq_data), 
                             inside = vfold_cv(repeats = 5, 
                                               strata = new_seq_data))
nested_resample


#---------------------modeling------------------------------------------
# #tune the parameter
#20240423 - warning: No event observations were detected in `truth` with event level 'No'.
#There were issues with some computations A: x1
tuned_tokens <- tune_grid(tuning_wf,
  resamples = tuning_folds,
  grid = tuning_grid)

  
#-----------model(s)------------

