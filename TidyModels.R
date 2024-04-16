#TidyModels 
#
#
#libraries
library(tidymodels)
library(jsonlite)
library(textrecipes)
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



#set up dataset for 1 ML model; paper, new_seq_data, text_tibble
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
str(json_tibble)


#set seed
set.seed(1028)

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
  step_tokenize(paper_html) %>% 
  step_lemma(paper_html) %>% 
  step_stopwords(paper_html) %>% 
  step_ngram(paper_html, min_num_tokens = 1, num_tokens = 3) %>% 
  show_tokens(paper_html)

head(gt_recipe, 2) 
  
  