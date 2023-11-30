#20231128 data cleaning for unique papers from spreadsheet of 200 hand-assigned papers 
#load seq_papers_20230505.Rdata from Adena Collins repository https://github.com/SchlossLab/Data_Accessibility/blob/main/data/seq_papers_20230505.RData
#.RData contains 4 data frames

#20231130 Replicate creation of papers dataframe from data from google drive file 
#https://docs.google.com/spreadsheets/d/1D9lx5gpamhryRRdo7mZrlEzLMfOTFN0rT5UnR3a9omo/edit?usp=sharing

#load necessary packages
library(tidyverse)
library(purrr)
library(tidytext)

#set working directory to directory "Colovas_Data_Accessibility"
setwd("~/Documents/Schloss/Colovas_Data_Accessibility")

#from downloaded google spreadsheet of manually assessed ASM manuscripts, create a dataframe of papers

#manually_assessed_papers <- read_csv("ASMSequencingPaperResponses.csv")

#clean dataframe to exclude duplicates
#papers_by_link <- arrange(manually_assessed_papers, paper) %>% 
 # distinct(paper, .keep_all = TRUE)



#Load .RData file containing seq_papers dataframe 

load("~/Documents/Schloss/Colovas_Data_Accessibility/seq_papers_20230505.RData")

#using seq_papers dataframe, arrange by DOI, and remove duplicates

papers_byDOI <- arrange(seq_papers, doi) %>% 
  distinct(doi, .keep_all = TRUE)

paper_text_byLink <-  arrange(seq_papers_texts, paper) %>% 
  distinct(paper, .keep_all = TRUE)

papers_noDupes_allData_allLinks <-  inner_join(papers_byDOI, paper_text_byLink, by = "paper") %>% tibble()
#papers_byDOI is a dataframe sorted by DOI with duplicates removed, removed 22 observations from the dataset

#count the number of papers containing new sequence data (No-273, Yes-205)

count(papers_noDupes_allData_allLinks, new_seq_data)

#make sure dataframe is grouped by journal title (container.title)
papers_noDupes_allData_allLinks %>% 
  group_by(container.title) %>% 
  count()

#use mutate to add data availability column to show text "Data Available" or "Data Not Available" 
papers_noDupes_allData_allLinks <- 
  mutate(papers_noDupes_allData_allLinks, data_available = ifelse(new_seq_data == "Yes", "Data Available", "No Data Available") )



#now i need to figure out where the text of each paper is located, or how to pull it based on Adena's code
#the text of each paper is in dataframe seq_papers_texts with 500 observations of 2 variables, paper and text