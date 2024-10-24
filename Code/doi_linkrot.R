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

get_site_status_no_follow <- function(websiteurl) {
  
  response <- tryCatch( {request(websiteurl) %>% 
      req_options(followlocation = FALSE) %>%
      req_error(is_error = ~ FALSE) %>% 
      req_perform()}, error = \(x){list(status_code = 404) } )
  
  numeric_response <- response$status_code
  return(numeric_response)
  
}

# inport data snakemake 
# "Data/doi_linkrot/alive/{datasets}"
# {input.rscript} {input.csv} {params.filepath} {wildcards.datasets}
input <- commandArgs(trailingOnly = TRUE)
csv <- input[1]
data_processed <- read_csv(csv)
filepath <- input[2]
datasets <- input[3]

# local practice
# data_processed <- read_csv("Data/1935-7885_alive.csv")
# filepath <- "Data/1935-7885"

data_processed$link_status_no_follow <- 
    map_int(data_processed$paper, get_site_status_no_follow)

data_processed %>%
    count(link_status_no_follow)

alive <- 
  data_processed %>%
     filter(link_status_no_follow == 200)

dead <-
  data_processed %>%
     filter(link_status_no_follow != 200)


alive_filepath  <- paste0(filepath, "/alive/", datasets, ".csv")
dead_filepath   <- paste0(filepath, "/dead/", datasets, ".csv")

write_csv(alive, file = alive_filepath)
write_csv(dead, file = dead_filepath)
