#20231130_SummaryFigureGenerator.R

#Joanna Colovas

#This file will generate summary figures from data frames created in file 20231128_PaperDataCleanup.R

#load necessary packages
library(tidyverse)

#create graph showing number of sequencing/non sequencing papers across ASM journals
ggplot(data = papers_noDupes_allData_allLinks, aes( x = container.title,
         fill = new_seq_data)) + 
  geom_bar(position= "dodge") +
  theme(axis.text.x = element_text(angle = 75, vjust = 1, hjust=1)) +
  labs( y = "Manuscript Count", 
        x = "ASM Journal", 
        fill = "Is there new 
sequencing data?",
        title = "Subset of Manually-Assessed Sequencing 
Manuscripts Across ASM Journals (n=192)") 

ggsave()
 

 
        

  
          
    


