# cleanHTML.R
# take webscraped HTML and clean html tags 
#
#
#
# load packages
library(tidyverse)
library(tidytext)
library(xml2)
library(textstem) #for stemming text variables
library(tm) #for text manipulation

# function to prep HTML using package tm
prep_html_tm <- function(html) {
  html <- as.character(html)
  html <- read_html(html) %>% html_text()
  html <- stripWhitespace(html)
  html <- removeNumbers(html)
  html <- removePunctuation(html)
  html <- lemmatize_strings(html)
}

webscraped_data <- read.csv(snakemake.input[0])
clean_text <- lapply(webscraped_data, prep_html_tm)
write.csv(df, file = snakemake.output[0], row.names = FALSE)