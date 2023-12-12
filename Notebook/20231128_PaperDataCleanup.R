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
#setwd("~/Documents/Schloss/Colovas_Data_Accessibility")

#from downloaded google spreadsheet of manually assessed ASM manuscripts, create a dataframe of manually assessed papers

manually_assessed_papers <- read_csv("Adena_Stuff/ASMSequencingPaperResponses.csv") %>% 
  distinct(paper, .keep_all = TRUE)
  

#Load .RData file containing seq_papers dataframe 

load("~/Documents/Schloss/Colovas_Data_Accessibility/Adena_Stuff/seq_papers_20230505.RData")

#add column with clear statement of data availability
manually_assessed_papers <- 
  mutate(manually_assessed_papers, data_available = ifelse(availability != "No", "Data Available", "No Data Available") )

#clean dataframe manually_assessed_papers to exclude duplicates
manual_papers_byLink <- arrange(manually_assessed_papers, paper) %>% 
  distinct(paper, .keep_all = TRUE)

#find out which papers from seq_papers and manually_assessed_papers are the same, and which are not
seq_papers <- seq_papers %>% distinct(paper, .keep_all = TRUE)

ac_500_papers <- full_join(manually_assessed_papers, seq_papers, by = c("paper", "new_seq_data")) 

#count data
ac_500_papers %>% count(new_seq_data, availability)

write_csv(ac_500_papers, file = "ac_papers_tocheck.csv")
ac_papers_tocheck <- read_csv("ac_papers_tocheck.csv") 

ac_papers_tocheck %>% count(new_seq_data, availability)
#using seq_papers dataframe, arrange by link, and remove duplicates

seq_papers_byLink <- arrange(seq_papers, paper) %>% 
  distinct(doi, .keep_all = TRUE)

#using seq_papers_texts dataframe to pull HTML text, arrange by link, and remove duplicates
papers_HTML_byLink <-  arrange(seq_papers_texts, paper) %>% 
  distinct(paper, .keep_all = TRUE)

#join all 3 dataframes for the most complete record of data for N=192 papers

papers_noDupes_allVars <-  inner_join(manual_papers_byLink, seq_papers_byLink, papers_HTML_byLink, by = "paper") %>% tibble()

#count the number of papers containing new sequence data (No-97, Yes-95, N=192)

count(papers_noDupes_allVars, new_seq_data.x)

#make sure dataframe is grouped by journal title (container.title)
papers_noDupes_allVars %>% 
  group_by(container.title) %>% 
  count()

#use mutate to add data availability column to show text "Data Available" or "Data Not Available" 
#papers_noDupes_allVars <- 
 # mutate(papers_noDupes_allData_allLinks, data_available = ifelse(new_seq_data == "Yes", "Data Available", "No Data Available") )



#now i need to figure out where the text of each paper is located, or how to pull it based on Adena's code
#the text of each paper is in dataframe seq_papers_texts with 500 observations of 2 variables, paper and text