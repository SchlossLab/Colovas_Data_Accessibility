#!/usr/bin/env Rscript
#begin link rot, extract links from pre-scraped website html
#
#
#library statements
library(tidyverse)
library(rvest)
library(xml2)
# library(tidytext)
# library(jsonlite)
library(httr2)
source("Code/utilities.R")

#need to update for snakemake 

# load data from snakemake input
# {input.rscript}  {paras.html_dir} {output}
input <- commandArgs(trailingOnly = TRUE)
html_filename <- input[1]
html_filename <- tibble(html_filename = html_filename)
output_file <- input[2]


#20250806 - grab webscrape function to modify for the parts of html we need
get_html_no_bib <- function(html_filename) {
  
  abstract <- read_html(html_filename) %>%
    html_elements("section#abstract") %>%
    html_elements("[role = paragraph]")
  
  body <- read_html(html_filename) %>%
    html_elements("section#bodymatter") 
  
  side_panel<-read_html(html_filename) %>% 
    html_elements("#core-collateral-info")
  
  all_html <-paste0(abstract, body, side_panel)
  read_html(all_html)

}

# get_html_no_bib(html_filename)

#local testing
# # 20241220 - load from Data/html to test 200 files 
# all_filenames <-tibble(filenames = list.files("Data/html", full.names = TRUE))

# filenames<- 
#   all_filenames %>% 
#   slice_tail(n = 200)

#20250515 - using the lookup table to get files to test
# lookup_table <- read_csv("Data/all_dois_lookup_table.csv.gz")
# filenames<-lookup_table$html_filename[200]

# filenames <-tibble(filenames = list.files(html_dir, full.names = TRUE))
# papers to check 20250806 
# html_filename <- tibble(html_filename = "Data/html/10.1128_microbiolspec.gpp3-0022-2018.html") #none-check
# html_filename <- tibble(html_filename = "Data/html/10.1128_mbio.01923-17.html") # 4 - check
# html_filename <- tibble(html_filename = "Data/html/10.1128_microbiolspec.bad-0006-2016") # none - check
# html_filename <- tibble(html_filename = "Data/html/10.1128_mra.00881-22") #none - check 
# html_filename <- tibble(html_filename = "Data/html/10.1128_microbiolspec.tbtb2-0018-2016") #file does not exist - idk why maybe link redirect
# # file.exists(html_filename)
# str(html_filename)



#function to get links from pre-scraped html
new_extract_links <- function(html_filename) {
  #initialize all_html_tags to NULL
  all_html_tags<-NA
  some_html_tags<-NA
  if(file.size(html_filename[[1]]) > 0 && file.exists(html_filename[[1]])) {
  #read html from snakefile 
  webscraped_data <- get_html_no_bib(html_filename[[1]])

  #get just doi from html_filename
  #"Data/html/10.1128_aac.00005-17.html" > 10.1128/aac.00005-17
  doi<-str_split_i(html_filename, pattern = "/", 3) %>% 
      str_replace(., ".html", "") %>%
      str_replace(., "_", "/")
  

    all_html_tags <-
      #get the html tags <a> for links as characters
      as.character(html_elements(webscraped_data, css = "a")) %>%
      #tibble with each tag and what filename it came from
      tibble(html_tag = .) %>%
      #filter for links that start with http(s)
      filter(str_detect(html_tag, "http")) 
      
      
      #mutate to add more colums link itself, text displayed
    some_html_tags<-
      mutate(all_html_tags, 
        link_address = str_split_i(html_tag, '"', 2), 
        link_text = str_split_i(html_tag, ">", 2), 
        link_text = str_remove(link_text, "</a")) %>%
      #filter for matching links text vs link, unique
      filter(str_equal(link_address, link_text)) %>%
      filter(str_detect(html_tag, doi, negate = TRUE)) %>%
      unique()
  
    }
  
  #returns all links
  return(some_html_tags)
  
}

#function for retrieving the HTML status of a website using httr2 instead of crul 

get_site_status <- function(websiteurl) {
  
  response <- tryCatch( {request(websiteurl) %>% 
      req_options(followlocation = TRUE) %>%
      req_error(is_error = ~ FALSE) %>% 
      req_perform()}, error = \(x){list(status_code = 404) } )
  
  numeric_response <- response$status_code
  return(numeric_response)
  
}

# run function to get all links from dataset, check status, and write to file
all_links <- html_filename %>%
  mutate(link_tibble = map(html_filename, new_extract_links)) %>% 
  unnest(cols = link_tibble)


all_links$link_status <- map_int(all_links$link_address, get_site_status)



#want to count number of links that have .com, .org, .gov, .edu, etc
all_links <- all_links %>% 
  mutate(hostname = map_chr(link_address, \(x)url_parse(x)$hostname), 
         hostname = str_replace(hostname, "^www.", ""),
         domain = str_replace(hostname, ".*\\.(.*)", "\\1"), 
         website_type = case_when(str_detect(hostname, "\\.com") ~ "com", 
                                  str_detect(hostname,"\\.edu") ~ "edu",
                                  str_detect(hostname,"\\.gov") ~ "gov",
                                  str_detect(hostname,"\\.org") ~ "org",
                                  TRUE ~ "other"), 
        binary_status = ifelse(link_status == 200, "Alive", "Dead"), 
        is_alive = link_status == 200
        )


write_csv(all_links, file = output_file)





