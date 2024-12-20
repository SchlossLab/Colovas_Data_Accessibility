#!/usr/bin/env Rscript
#begin link rot, extract links from pre-scraped website html
#
#
#library statements
library(tidyverse)
library(rvest)
library(xml2)
library(tidytext)
library(jsonlite)
library(httr2)


# load data from snakemake input
# {input.rscript}  {input.html} {input.metadata} {output.all_links} {output.metadata_links}
input <- commandArgs(trailingOnly = TRUE)
html <- input[1]
metadata_file <- input[2]
alllinks_output <- input[3]
#uniquelinks_output <- input[4]
metadatalinks_output <- input[4]



#function for retrieving the HTML status of a website using httr2 instead of crul 

get_site_status <- function(websiteurl) {
  
  response <- tryCatch( {request(websiteurl) %>% 
      req_options(followlocation = TRUE) %>%
      req_error(is_error = ~ FALSE) %>% 
      req_perform()}, error = \(x){list(status_code = 404) } )
  
  numeric_response <- response$status_code
  return(numeric_response)
  
}

# run function to get all links from dataset, chekc status, and write to file
# don't want just the unique ones because that's easy to re-generate

file_links <- extract_links(html)

file_links$link_status <- map_int(file_links$link_address, get_site_status)

#want to count number of links that have .com, .org, .gov, .edu, etc
file_links <- file_links %>% 
  mutate(hostname = map_chr(link_address, \(x)url_parse(x)$hostname), 
         hostname = str_replace(hostname, "^www.", ""),
         domain = str_replace(hostname, ".*\\.(.*)", "\\1"), 
         website_type = case_when(str_detect(hostname, "\\.com") ~ "com", 
                                  str_detect(hostname,"\\.edu") ~ "edu",
                                  str_detect(hostname,"\\.gov") ~ "gov",
                                  str_detect(hostname,"\\.org") ~ "org",
                                  TRUE ~ "other")
  )

file_links <- file_links %>% 
    mutate(binary_status = ifelse(link_status == 200, "Alive", "Dead"), 
          is_alive = link_status == 200)

write_csv(file_links, alllinks_output)



# getting the link count by paper is also easy----------------------------------
# will be saved with the paper metadata 

# link count by paper (total) 
link_count_total_by_paper <- count(file_links, by = paper)
link_count_total_by_paper <-
  rename(link_count_total_by_paper, paper_doi = "by", total_link_count = "n")

#unique link count 
unique_links <- unique(file_links)

unique_link_count <- count(unique_links, by = paper)
unique_link_count <-
  rename(unique_link_count, paper_doi = "by", unique_link_count = "n")

#join full and unique link count
link_count_with_metadata <- full_join(link_count_total_by_paper,
unique_link_count, by = "paper_doi")

link_count_with_metadata <- link_count_with_metadata %>%
  mutate(link_count_difference = total_link_count - unique_link_count)

#join with metadata-and save

# load metadata 
metadata <- read_csv(metadata_file)
# local trials
# metadata_file <- "Data/groundtruth.csv"

# join metadata with the link count data and write to file 
# with regular and unique link counts
links_metadata <- inner_join(link_count_with_metadata,
                              metadata, by = join_by("paper_doi" == "paper"))
write_csv(links_metadata, metadatalinks_output)

#20241206 - re-write program with all html pre-scraped---------------------------------------------------

#load from Data/html
file_list <-list.files("Data/html", full.names = TRUE)
#they're all zeros until 275, why? idk 
one_file <-file_list[300]
html_filename<-one_file

some_files<-tibble(file_list = file_list[300:400])


#i think this is correct so we will have to try it on multiples
try1<-new_extract_links(html_filename)

whole_tibble<-some_files %>%
  mutate(links = map(file_list, new_extract_links)) %>% 
  unnest(links)

whole_tibble %>%
  count(html_filename) %>% 
  filter(`n` > 1)

head(some_files)

#we're gonna try and re-write this so that we don't have to run webscrape
new_extract_links <- function(html_filename) {
  #initialize all_html_tags to NULL
  all_html_tags<-NA
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


