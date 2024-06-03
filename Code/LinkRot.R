#begin link rot, extract links from pre-scraped website html
#
#
#library statements
library(tidyverse)
library(rvest)
library(tidytext)
library(jsonlite)
library(httr2)


# load data from snakemake input
input <- commandArgs(trailingOnly = TRUE)
html <- input[1]
output_file <- input[2]


# load data for local trials
# html <- "Data/groundtruth.csv.gz"

#load data function from json file 
#extract links from pre-scraped html
extract_links <- function(html) {
  
  #read html from snakefile 
  webscraped_data <- read.csv(html)
  
  # turns paper_html into a html readable format using read_html
  webscraped_data$paper_html <- map(webscraped_data$paper_html, read_html)
  
  # extracts the links into their own two column nested list using html_elements
  paper_links <- tibble(paper = webscraped_data$paper_doi,  
                        html_tag = map(webscraped_data$paper_html, 
                                       html_elements, css = "a"))
  paper_links$html_tag <- map(paper_links$html_tag, paste0)
  
  
  #unnests and pivots list to have each link as a row with the parent paper
  links_list <- unnest_longer(paper_links, col = html_tag)
  
  #extract only papers with 'https' in the link
  csv_links_list_short <- links_list %>% 
    filter(str_detect(html_tag, "https"))
  
  #split links into the link itself, and the text displayed on the website
  csv_links_list_short <- mutate(csv_links_list_short, 
                                 link_address = str_split_i(
                                   csv_links_list_short$html_tag, '"', 2), 
                                 link_text = str_split_i(
                                   csv_links_list_short$html_tag, ">", 2))
  
  csv_links_list_short <- mutate(csv_links_list_short, 
                                 link_text = str_remove(
                                   csv_links_list_short$link_text, "</a"))
  
  #filters for only links with the same text as link address
  csv_links <- csv_links_list_short %>% 
    filter(str_equal(csv_links_list_short$link_address, csv_links_list_short$link_text))
  
  #gets only unique links
  csv_links <- unique(csv_links)
  
  #returns unique links
  return(csv_links)
  
}


groundtruth_links <- extract_links(html)
write_csv(groundtruth_links, "Data/groundtruth_links.csv")

link_count <- count(groundtruth_links, by = paper)
link_count <- rename(link_count, paper = "by", link_count = "n")
groundtruth <- read_csv("Data/groundtruth.csv")
groundtruth_linkcount <- left_join(link_count, groundtruth, by = "paper")
write_csv(groundtruth_linkcount, "Data/groundtruth_linkcount.csv")


#function for retrieving the HTML status of a website using httr2 instead of crul 

get_site_status <- function(websiteurl) {

  response <- tryCatch( {request(websiteurl) %>% 
    req_options(followlocation = TRUE) %>%
    req_error(is_error = ~ FALSE) %>% 
    req_perform()}, error = \(x){list(status_code = 404) } )
  
  numeric_response <- response$status_code
  return(numeric_response)
  
}

#load files 
groundtruth_linkcount <- read_csv("Data/groundtruth_linkcount.csv")
groundtruth_links <- read_csv("Data/groundtruth_links.csv")
gt_all_links_with_metadata <- read_csv("Data/gt_all_links_with_metadata.csv")

groundtruth_links$link_status <- map_int(groundtruth_links$link_address, get_site_status)
write_csv(groundtruth_links, "Data/groundtruth_links.csv")

#create dataset joining groundtruth_links and groundtruth_linkcount 
#to have all paper metadata in the same place
gt_all_links_with_metadata <- left_join(groundtruth_links, groundtruth_linkcount, by = "paper")
write_csv(gt_all_links_with_metadata, "Data/gt_all_links_with_metadata.csv")


# 20240508 - count data for types of links using groundtruth_links.csv
#want to count number of links that have .com, .org, .gov, .edu, etc
#also want to count website type git, doi, zenodo, figshare, datadryad
groundtruth_links <- groundtruth_links %>% 
  mutate(hostname = map_chr(link_address, \(x)url_parse(x)$hostname), 
         hostname = str_replace(hostname, "^www.", ""),
         domain = str_replace(hostname, ".*\\.(.*)", "\\1"), 
         website_type = case_when(str_detect(hostname, "\\.com") ~ "com", 
                                  str_detect(hostname,"\\.edu") ~ "edu",
                                  str_detect(hostname,"\\.gov") ~ "gov",
                                  str_detect(hostname,"\\.org") ~ "org",
                                  TRUE ~ "other")
         )
#write to file
write_csv(groundtruth_links, "Data/groundtruth_links.csv")


#count links of each website type 
status_type <- count(gt_all_links_with_metadata, hostname, link_status, website_type) %>% arrange(-n)
error_only <- filter(status_type, link_status != 200)

#filter for "long lasting" website types
#also want to count website type git, doi, zenodo, figshare, datadryad, and asm
long_lasting <- select(gt_all_links_with_metadata, paper, link_address, link_status, domain, hostname, container.title) %>% 
  filter(grepl("doi|git|figshare|datadryad|zenodo|asm", hostname))

count(long_lasting, link_status)
long_lasting_bypaper <- count(long_lasting, container.title, link_status)





