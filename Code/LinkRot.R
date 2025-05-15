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

#need to update for snakemake 

# load data from snakemake input
# {input.rscript}  {paras.html_dir} {output}
input <- commandArgs(trailingOnly = TRUE)
html_filename <- input[1]
output_file <- input[2]


#local testing
# # 20241220 - load from Data/html to test 200 files 
# all_filenames <-tibble(filenames = list.files("Data/html", full.names = TRUE))

# filenames<- 
#   all_filenames %>% 
#   slice_tail(n = 200)

#20250515 - using the lookup table to get files to test
# lookup_table <- read_csv("Data/all_dois_lookup_table.csv.gz")
# filenames<-lookup_table$html_filename[200:300]

# filenames <-tibble(filenames = list.files(html_dir, full.names = TRUE))
# html_filename <- filenames[1,]

#function to get links from pre-scraped html
new_extract_links <- function(html_filename) {
  #initialize all_html_tags to NULL
  all_html_tags<-NA
  some_html_tags<-NA
  if(file.size(html_filename) > 0 && file.exists(html_filename)) {
  #read html from snakefile 
  webscraped_data <- read_html(html_filename)

  #get just doi from html_filename
  #"Data/html/10.1128_aac.00005-17.html" > 10.1128/aac.00005-17
  doi<-str_split_i(html_filename, pattern = "/", 3) %>% 
      str_replace(., ".html", "") %>%
      str_replace(., "_", "/")
  
    all_html_tags <-
      #get the html tags <a> for links as characters
      as.character(html_elements(webscraped_data, css = "a")) %>%
      #tibble with each tag and what filename it came from
      tibble(html_tag = ., html_filename = html_filename) %>%
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
  unnest(link_tibble)


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





