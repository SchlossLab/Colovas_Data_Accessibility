# Webscraping through tidy text
# goals: read html, removal of figures and tables, 
# save html, tokenize paper, send each thing to a json file
#
#library statements
library(tidyverse)
library(rvest)
library(tidytext)
library(tibble)
library(xml2)
library(jsonlite)
library(textstem) #for stemming text variables
library(tm) #for text manipulation
library(tokenizers) #for text tokenization

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
  
  paper_html <- paste0(abstract, body) %>% tibble()
  
  return(paper_html)
  
}

#function to remove all unnecessary HTML characters using pkg tm
prep_html_tm <- function(html) {
  html <- as.character(html)
  html <- read_html(html) %>% html_text()
  html <- stripWhitespace(html)
  html <- removeNumbers(html)
  html <- removePunctuation(html)
  html <- lemmatize_strings(html)
}


# #Function for token creating
# #20240507 - can just lapply this function on the dataset
# create_tokens <- function(paper_text, ngrams = 3) {
#   paper_text %>% 
#     tokenize_ngrams(., n = ngrams, n_min = 1, 
#                     stopwords = stopwords::stopwords("en"))
# }



#function for creating json file of data
#add year published, and journal name 
prepare_data <- function(data, file_path_gz){
  
  webscraped_data <- lapply(data$paper, webscrape)
  clean_text <- lapply(webscraped_data, prep_html_tm)
  paper_tokens <- lapply(clean_text, tokenize_ngrams, n_min = 1, n = 3,
                         stopwords = stopwords::stopwords("en"))
 #20240516 removes unlisted tokens col
 # unlisted_tokens <- lapply(paper_tokens, unlist)
  
 # if ("year.published" %in% colnames(data) == FALSE) {
 #   mutate(data, 
 #   year.published = case_when(
 #     str_detect(published.print, "/") ~ str_c("20", str_sub(published.print, start = -2, -1)), 
 #     str_detect(published.print, "-") ~ substring(published.print, 1, 4))) 
 # }
  
  df <- lst(paper_doi = data$paper,
            paper_html = webscraped_data, 
            paper_tokens = paper_tokens, 
            journal = data$container.title,
            year_published = data$year.published)
  
  csv_df <- write.csv(df, file = file_path_gz, 
                      col.names = TRUE, row.names = FALSE )

}


#call functions on small and large datasets, start with small gt_ss30

gt_ss30 <- read_csv("Data/gt_subset_30.csv")
prepare_data(gt_ss30, "Data/gt_subset_30_data.csv.gz")

#groundtruth <- read_csv("Data/groundtruth.csv")
#prepare_data(groundtruth, "Data/groundtruth.json")


#-----------------------fix code for df assembly and write csv------------------

#load gtss30 file, i want html only pretty much 
jsonfile <- "Data/gt_subset_30_data.json"
json_data <- read_json(jsonfile)  
json_data <- unserializeJSON(json_data[[1]])

json_tibble <- lst(paper_doi = json_data$`paper_doi`,
                      new_seq_data = json_data$`data$new_seq_data`,
                      text_tibble = json_data$`paper_tokens`,
                      journal = json_data$`journal`, 
                      year_published = json_data$`year_published`) 





#---------------------------end-------------------------------------------------