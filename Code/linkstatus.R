#!/usr/bin/env Rscript
#get link status using linkrot fxns for website urls
#
#
#library statements
library(tidyverse)
library(rvest)
library(tidytext)
library(jsonlite)
library(httr2)
# source("Code/LinkRot.R", .supress) # load fxn get_site_status

#function for retrieving the HTML status of a website using httr2 instead of crul 

get_site_status <- function(websiteurl) {
  
  response <- tryCatch( {request(websiteurl) %>% 
      req_options(followlocation = TRUE) %>%
      req_error(is_error = ~ FALSE) %>% 
      req_perform()}, error = \(x){list(status_code = 404) } )
  
  numeric_response <- response$status_code
  return(numeric_response)
  
}

get_site_status_no_follow <- function(websiteurl) {
  
  response <- tryCatch( {request(websiteurl) %>% 
      req_options(followlocation = FALSE) %>%
      req_error(is_error = ~ FALSE) %>% 
      req_perform()}, error = \(x){list(status_code = 404) } )
  
  numeric_response <- response$status_code
  return(numeric_response)
  
}


#look at rds file for 1935-7885 jmbe metadata
rds_jmbe <- "Data/1935-7885_metadata.RDS"
data_processed_jmbe <- readRDS(rds_jmbe)

#rds for msphere
rds_msph <- "Data/2379-5042_metadata.RDS"
data_processed_msph <- readRDS(rds_msph)

#rds for msystems
rds_msys <- "Data/2379-5077_metadata.RDS"
data_processed_msys <- readRDS(rds_msys)

#20240919 i am going to start screaming because all these links are rotten 
# which means i probably need to re-scrape them all them from crossref which
# is going to be an afternoon problem 

data_processed_jmbe$link_status <- map_int(data_processed_jmbe$url, get_site_status)
data_processed_msph$link_status <- map_int(data_processed_msph$url, get_site_status)
data_processed_msys$link_status <- map_int(data_processed_msys$url, get_site_status)

data_processed_jmbe %>%
    count(link_status)

data_processed_msph %>%
  count(link_status)

data_processed_msys %>%
  count(link_status)

good_urls <-
    urls_to_check %>% 
        filter(link_status == 200)


alive <-
    inner_join(data_processed,
               good_urls, 
               by = c("url", "doi", "title"))

alive <-
    alive %>%
        mutate(paper = url)

write_csv(alive, file = "Data/1935-7885_alive.csv")

#20240920 - check status of links from re-loaded RDS file 

rds_jb <- "Data/1098-5530_metadata.RDS"
data_processed_jb <- readRDS(rds_jb)

data_processed_jb_small <-
  data_processed_jb %>% 
    slice_sample(n = 250)


# okay even with the datasets that have been updated the urls don't work... great

# takes a lot longer to get_site_status with redrection
data_processed_jb_small$link_status <- 
  map_int(data_processed_jb_small$url, get_site_status)

data_processed_jb_small %>%
    count(link_status)

# is faster without redirection
data_processed_jb_small$link_status_no_follow <- 
  map_int(data_processed_jb_small$url, get_site_status_no_follow)

data_processed_jb_small %>%
    count(link_status_no_follow)

data_processed_jb_small <-
  data_processed_jb_small %>% 
    mutate(
      paper_altid = paste0("https://journals.asm.org/doi/", alternative.id), 
      paper_doi = paste0("https://journals.asm.org/doi/", doi)
    )

data_processed_jb_small$ls_no_follow_altid <- 
  map_int(data_processed_jb_small$paper_altid, get_site_status_no_follow)

#13/250 links are aliive with the altid and no follow
data_processed_jb_small %>%
    count(ls_no_follow_altid)

data_processed_jb_small$ls_no_follow_doi <- 
  map_int(data_processed_jb_small$paper_doi, get_site_status_no_follow)

# allegedly this one all of the links work with the updated dois? 
#let's save this version and try a webscrape 
data_processed_jb_small %>%
    count(ls_no_follow_doi)

data_processed_jb_small <-
  data_processed_jb_small %>%
    rename(paper = paper_doi)

write_csv(data_processed_jb_small,
          file = "Data/1098-5530_small.csv")
