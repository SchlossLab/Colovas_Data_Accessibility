library(tidyverse)
library(rvest)
library(tidytext)
library(tibble)
library(xml2)
#library(polite)

#groundtruth <- read_csv("Data/groundtruth.csv")


#example papers for testing the scraping functions, using DOI or downloaded HTML file 
#test1_url <- "https://journals.asm.org/doi/10.1128/aac.47.7.2125-2130.2003"
test2_url <- "https://journals.asm.org/doi/10.1128/aac.00169-21"

test1_url <- "https-::journals.asm.org:doi:10.1128:aac.47.7.2125-2130.2003.html"

#pull abstract from the HTML of the paper, pipe in html_text() if needed, see below
test_abstract <- read_html(test1_url) %>%
  html_elements("section#abstract") %>%
  html_elements("[role = paragraph]") 
#%>% html_text()

#pull all main body text from the HTML of the paper, pipe in html_text() if needed, see below
main_body <- read_html(test1_url) %>%
 html_elements("section#bodymatter") 
#%>% html_text()


#remove all nested table and figure elements using xml_remove(), which writes over main_body
test_body <- main_body %>%
  html_elements(css = ".table > *") %>%
  html_children() %>%
  xml_remove()

test_body_without_figures <- main_body %>%
   html_elements(css = ".figure-wrap > *") %>%
   html_children() %>%
   xml_remove()

#function for cleaning of HTML text from previous code refactor to remove all html tags, greedy function
#not needed using the unnest_tokens() function on html 
# cleanHTML <- function(htmlString) {
#   return(gsub("<.*?>", "", htmlString))
# }
# text_string_main_body <- cleanHTML(as.character(main_body))
# text_string_abstract <- cleanHTML(as.character(test_abstract))
# 
# all_text_string <- paste(
#     text_string_abstract, text_string_main_body, collapse = " ") %>%
#         stringr::str_remove_all(
#             pattern = regex("[[:digit:]]|[[:punct:]]|\\(.*\\)|=|\u00a0")
#          )

# print(all_text_string)
# writeChar(all_text_string, "test1_textscraping.txt")

cleaned_tokenized_paper <- tibble(text = c(as.character(test_abstract), as.character(main_body))) %>% 
  unnest_tokens(word, text, format = "html") %>% 
  arrange() %>% 
  filter(nchar(word) > 3) %>% 
  anti_join(., stop_words, by = "word") %>% 
  count(word)

#Function for token counting pipeline (from TidyingText.R)
count_words <- function(file_name, min_word_length = 3) {
  readLines(file_name) %>% 
    as_tibble() %>% 
    unnest_tokens(word, value) %>% 
    arrange() %>% 
    filter(nchar(word) > min_word_length) %>% 
    anti_join(., stop_words, by = "word") %>% 
    count(word)
}
