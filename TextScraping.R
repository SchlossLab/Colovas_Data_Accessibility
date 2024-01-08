
library(tidyverse)
library(rvest)
library(polite)

groundtruth <- read_csv("Data/groundtruth.csv")


#read_html("test.html") %>% html_text()

#read_html("test.html") %>% html_text2()


#example paper https://journals.asm.org/doi/10.1128/aac.47.7.2125-2130.2003 
#Persistent Bacteremia in Rabbit Fetuses despite Maternal Antibiotic Therapy in a Novel Intrauterine-Infection Model

#this doesn't get the abstract of the paper, do we want it separate or together?

test_url <- "https://journals.asm.org/doi/10.1128/aac.47.7.2125-2130.2003"

#use polite package to introduce yourself to the web host

bow(test_url,
    user_agent = "University of Michigan Resercher, joannacolovas@gmail.com", 
    verbose = TRUE)

test_abstract <- read_html(test_url, verbose = TRUE) %>%
  html_elements("section#abstract") %>%
  html_elements("[role = paragraph]")

test_abstract_text <- html_text(test_abstract)

test_body <- read_html(test_url) %>%
  html_elements("section#bodymatter") %>%
  html_elements("[role = paragraph]")

test_body_text <- html_text(test_body)

all_text <- c(test_abstract_text, test_body_text)
all_text_string <- paste(all_text, collapse = " ")
