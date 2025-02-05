# trying to figure out what's wrong with my webscrape jobs
#20241030
#
#
#library calls
library(tidyverse)
library(rvest)
library(tidytext)
library(xml2)

#more library calls from doi_linkrot
library(jsonlite)
library(httr2)

#scrape fails at index 12983
# 11594 in aem 
failed_scrape <- read_csv("Data/doi_linkrot/alive/1098-5336.csv")
colnames(failed_scrape)



failed_doi  <- failed_scrape$paper[11594]
failed_doi

# 20241031 - i&i cleanHTML keeps failing 
library(tidyverse)
library(tidytext)
library(xml2)
library(rvest)
library(textstem) #for stemming text variables
library(tm) 


prep_html_tm <- function(html) {
  html <- as.character(html)
  html <- read_html(html) %>% html_text()
  html <- str_to_lower(html)
  html <- stripWhitespace(html)
  html <- removePunctuation(html)
  # html <- str_remove_all(html, "â")
  # html <- str_remove_all(html, "ã")
  # html <- str_remove_all(html, "ì")
  # html <- str_remove_all(html, "î")
  # html <- removeNumbers(html)
  html <- str_remove_all(html, "[[:digit:]]")
  html <- str_remove_all(html, "[[^a-z ]]")
  # html <- str_remove_all(html, "[[2|3|4|9]]")
  html <- lemmatize_strings(html)
}

webscraped_data <- read_csv("Data/webscrape/1098-5522.html.csv.gz")
colnames(webscraped_data)

grep(webscraped_data$paper_doi, `NA`, value = TRUE)
grep(webscraped_data$paper_html, `NA`, value = TRUE)

#error in index 2948
webscraped_data$paper_doi[2948]
str(webscraped_data$paper_html[2948])

webscraped_data %>%
  na.omit()


webscraped_data$clean_html <- lapply(webscraped_data$paper_html, prep_html_tm)
webscraped_data$clean_html <- map_chr(webscraped_data$paper_html, prep_html_tm)
webscraped_data <- select(webscraped_data, !"paper_html")
webscraped_data$clean_html <- 
  map_chr(webscraped_data$clean_html, as.character)
write.csv(webscraped_data, 
          file = output_file, 
          row.names = FALSE)


