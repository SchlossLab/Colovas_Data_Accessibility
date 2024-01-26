library(tidyverse)
library(rvest)
library(tidytext)
library(tibble)
library(xml2)
#library(polite)

#groundtruth <- read_csv("Data/groundtruth.csv")


#example papers for testing the scraping functions
test1_url <- "https://journals.asm.org/doi/10.1128/aac.47.7.2125-2130.2003"
test2_url <- "https://journals.asm.org/doi/10.1128/aac.00169-21"


test_abstract <- read_html(test1_url) %>%
  html_elements("section#abstract") %>%
  html_elements("[role = paragraph]") 


main_body <- read_html(test1_url) %>%
 html_elements("section#bodymatter")

test_body <- main_body %>%
  html_elements(css = ".table > *") %>%
  html_children() %>%
  xml_remove()

test_body_without_figures <- main_body %>%
   html_elements(css = ".figure-wrap > *") %>%
   html_children() %>%
   xml_remove()

cleanHTML <- function(htmlString) {
  return(gsub("<.*?>", "", htmlString))
}
text_string_main_body <- cleanHTML(as.character(main_body))
text_string_abstract <- cleanHTML(as.character(test_abstract))

all_text_string <- paste(
    text_string_abstract, text_string_main_body, collapse = " ") %>%
        stringr::str_remove_all(
            pattern = regex("[[:digit:]]|[[:punct:]]|\\(.*\\)|=|\u00a0")
         )

print(all_text_string)
writeChar(all_text_string, "test1_textscraping.txt")



# scraped_text <- read_xml("test_textscraping.txt")
# scraped_text_tibble <- as_tibble(scraped_text)
# toTidyText <- unnest_tokens(scraped_text)