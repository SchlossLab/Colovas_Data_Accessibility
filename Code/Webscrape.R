# Webscrape.R
# take paper DOI list and webscrape paper HTML 
#
#
# library statements
library(tidyverse)
library(rvest)
library(tidytext)
library(tibble)
library(xml2)
#library(jsonlite) #shouldn't need jsonlite anymore


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

webscrape_save_html <- function(data, file_path_gz){

  webscraped_data <- lapply(data$paper, webscrape)

  df <- tibble(paper_doi = data$paper,
             paper_html = webscraped_data)

  csv_df <- write.csv(df, file = file_path_gz, 
                    col.names = TRUE, row.names = FALSE)
}