#20231128 data cleaning for unique papers from spreadsheet of 200 hand-assigned papers 
#load seq_papers_20230505.Rdata from Adena Collins repository https://github.com/SchlossLab/Data_Accessibility/blob/main/data/seq_papers_20230505.RData
#.RData contains 4 data frames

#20231130 Replicate creation of papers dataframe from data from google drive file 
#https://docs.google.com/spreadsheets/d/1D9lx5gpamhryRRdo7mZrlEzLMfOTFN0rT5UnR3a9omo/edit?usp=sharing

# 202312-- merge data frame seq_papers(500 papers) from AC .RData file seq_papers_202340505.RData with
# dataframe manually_assessed_papers, constructed from google sheet above

#load necessary packages
library(tidyverse)
library(purrr)
library(tidytext)


#from downloaded google spreadsheet of manually assessed ASM manuscripts, create a dataframe of manually assessed papers

manually_assessed_papers <- read_csv("Adena_Stuff/ASMSequencingPaperResponses.csv") %>% 
  distinct(paper, .keep_all = TRUE)
  

#Load .RData file containing seq_papers dataframe 

load("~/Documents/Schloss/Colovas_Data_Accessibility/Adena_Stuff/seq_papers_20230505.RData")


#find out which papers from seq_papers and manually_assessed_papers are the same, and which are not
seq_papers <- seq_papers %>% distinct(paper, .keep_all = TRUE)

ac_500_papers <- full_join(manually_assessed_papers, seq_papers, by = c("paper", "new_seq_data")) 

#count data
ac_500_papers %>% count(new_seq_data, availability)


#write files to CSV to continue checking papers for data availability
write_csv(ac_500_papers, file = "ac_papers_tocheck.csv")

#read in finished csv file to manipulate and continue cleaning columns 
ac_papers_tocheck <- read_csv("Data/ac_papers_tocheck.csv") 

ac_papers_tocheck %>% count(new_seq_data, availability)


#add column with clear statement of data availability for all data in column "data_available"
ac_papers_tocheck <- 
  mutate(ac_papers_tocheck, data_available = ifelse(availability != "No", "Data Available", "No Data Available") )

#move papers column to the beginning of the dataset
ac_papers_tocheck <- 
  ac_papers_tocheck %>% relocate(paper)

#write csv for trusted "ground truth" file
write_csv(ac_papers_tocheck, file = "Data/groundtruth.csv")
