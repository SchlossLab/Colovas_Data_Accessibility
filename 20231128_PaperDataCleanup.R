#20231128 data cleaning for unique papers
#load seq_papers_20230505.Rdata from Adena Collins repository https://github.com/SchlossLab/Data_Accessibility/blob/main/data/seq_papers_20230505.RData
#.RData contains 4 data frames



library(tidyverse)

#Load .RData file containing seq_papers dataframe

load("~/Documents/Schloss/Colovas_Data_Accessibility/seq_papers_20230505.RData")

#using seq_papers dataframe, arrange by DOI, and remove duplicates
#where did the duplicates come from? i have no idea

papers_byDOI <- arrange(seq_papers, doi) %>% 
  distinct(doi, .keep_all = TRUE)
#papers_byDOI is a dataframe sorted by DOI with duplicates removed, removed 22 observations from the dataset

#count the number of papers containing new sequence data (No-273, Yes-205)

count(papers_byDOI, new_seq_data)

#now i need to figure out where the text of each paper is located, or how to pull it based on Adena's code