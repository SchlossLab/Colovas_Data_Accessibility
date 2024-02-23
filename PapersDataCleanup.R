# data cleaning for unique papers from spreadsheets of ~500 hand-assigned papers 

#load seq_papers_20230505.Rdata from Adena Collins repository https://github.com/SchlossLab/Data_Accessibility/blob/main/data/seq_papers_20230505.RData
#.RData contains 4 data frames, we will use seq_papers (500 papers)

# Replicate creation of papers dataframe from data from google drive file of 200  manually checked papers
#https://docs.google.com/spreadsheets/d/1D9lx5gpamhryRRdo7mZrlEzLMfOTFN0rT5UnR3a9omo/edit?usp=sharing

# merge data frame seq_papers(500 papers) from AC .RData file seq_papers_202340505.RData with
# dataframe manually_assessed_papers, constructed from google sheet link above

#load necessary packages
library(tidyverse)
#library(purrr)
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

#filter dataset to remove MCB papers (ASM sold MCB) 
groundtruth <- read_csv("Data/groundtruth.csv")

count(groundtruth, container.title)

groundtruth <-  arrange(groundtruth, container.title)

groundtruth <- 
  filter(groundtruth, container.title != "Molecular and Cellular Biology") %>% 
  filter(groundtruth, container.title != "is.na()")

#rewrite csv for trusted "ground truth" file
write_csv(groundtruth, file = "Data/groundtruth.csv")

#add year published column 
groundtruth_year <- groundtruth %>% 
  mutate(year.published = case_when(str_detect(published.print, "/") ~ str_c("20", str_sub(published.print, start = -2, -1)), str_detect(published.print, "-") ~ substring(published.print, 1, 4) ))      

groundtruth_year$year.published <- as.character(groundtruth_year$year.published)

write_csv(groundtruth_year, file = "Data/groundtruth.csv")

groundtruth$year.published <- as.character(groundtruth$year.published)

write_csv(groundtruth, file = "Data/groundtruth.csv")

#add more papers to groundtruth dataset from papers with metadata from seq_papers_bib

#load AC .RData file 
load("~/Documents/Schloss/Colovas_Data_Accessibility/Adena_Stuff/seq_papers_20230505.RData")

#make sure papers are distinct
seq_papers_bib <- seq_papers_bib %>% distinct(paper, .keep_all = TRUE)

#antijoin with groundtruth
seq_papers_bib_nogroundtruth <- anti_join(seq_papers_bib, groundtruth, by = join_by(paper))

#write dataset to .csv file for manual manipulation
write_csv(seq_papers_bib_nogroundtruth, file = "Data/seq_papers_bib_1300.csv")

#manually add 54 papers from seq_papers_bib_nogroundtruth (aka 1300 papers dataset) to a second sheet of the doc
groundtruth_toadd <- read_csv("Data/add_to500.csv")

#full join of datasets
groundtruth_500 <- full_join(groundtruth, groundtruth_toadd) 

#add year published and write to file to 

groundtruth_500 <- groundtruth_500 %>% 
  mutate(year.published = case_when(str_detect(published.print, "/") ~ str_c("20", str_sub(published.print, start = -2, -1)), str_detect(published.print, "-") ~ substring(published.print, 1, 4) ))      

write_csv(groundtruth_500, file = "Data/groundtruth_500.csv")

# to be done after columns manually coded and loaded back into R
groundtruth_500 <- read_csv("Data/groundtruth_500.csv") 

groundtruth_500 <- groundtruth_500 %>% 
  mutate(data_available = ifelse(availability != "No", "Data Available", "No Data Available") )

#load groundtruth_500 into the groundtruth file 
write_csv(groundtruth_500, file = "Data/groundtruth.csv")


#subset groundtruth to 30 observations as a test case
groundtruth <- read_csv("Data/groundtruth.csv")
gt_subset_30 <- slice_sample(groundtruth, n = 30)
write_csv(gt_subset_30, file = "Data/gt_subset_30.csv")
