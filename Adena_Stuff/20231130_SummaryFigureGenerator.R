#20231130_SummaryFigureGenerator.R

#Joanna Colovas

#This file will generate summary figures from data frames created in file 20231128_PaperDataCleanup.R

#load necessary packages
library(tidyverse)

#create and save graph showing number of sequencing/non sequencing papers across ASM journals
NewSequencingDataPlot <- 
  ggplot(data = papers_noDupes_allVars, aes( x = container.title,
           fill = new_seq_data.x)) + 
    geom_bar(position= "dodge") +
    theme(axis.text.x = element_text(angle = 75, vjust = 1, hjust=1)) +
    labs( y = "Manuscript Count", 
          x = "ASM Journal", 
          fill = "Is there new 
  sequencing data?",
          title = "Subset of Manually-Assessed Sequencing Manuscripts
  Across ASM Journals Containing New Sequencing Data (n=192)")  +
  scale_fill_manual(values = c("red", "blue"))

ggsave(NewSequencingDataPlot, filename = "20231201_NewSequencingDataPlot.tiff" )

#create and save graph showing number of sequencing papers across ASM journals with data available

#filter for only papers with data available 
papers_data_available <-  filter(papers_noDupes_allVars, new_seq_data.x == "Yes") 
count(papers_data_available, container.title)

NewSequencingData_AvailablePlot <- 
    ggplot(data = papers_data_available, aes( x = container.title,
                                               fill = data_available)) + 
    geom_bar(position = "dodge") +
    theme(axis.text.x = element_text(angle = 75, vjust = 1, hjust=1)) +
    labs( y = "Manuscript Count", 
          x = "ASM Journal", 
          fill = "Is there sequencing
      data available?",
          title = "Subset of Manually-Assessed Sequencing 
Manuscripts Across ASM Journals Containing New 
Sequencing Data with Data Available (n=95)") +
 scale_fill_manual(values = c("blue", "red"))

NewSequencingData_AvailablePlot
ggsave(NewSequencingData_AvailablePlot, filename = "20231201_NewSequencingData_AvailablePlot.tiff" )
        

#create and save graph showing average number of citations if data is presented and is/not available
NewSequencingData_AvgCitationsPlot <- 
  ggplot(data = papers_data_available, aes( x = container.title,
                                            fill = data_available,
                                            y = is.referenced.by.count)) + 
  geom_boxplot() +
  theme(axis.text.x = element_text(angle = 75, vjust = 1, hjust=1)) +
  labs( y = "Number of Citations via CrossRef", 
        x = "ASM Journal", 
        fill = "Is there sequencing
      data available?",
        title = "Average Number of Citations for Subset of Manually-Assessed 
Sequencing Manuscripts Across ASM Journals Containing New 
Sequencing Data with Data Available (n=95)") +
  scale_fill_manual(values = c("blue", "red"))

NewSequencingData_AvgCitationsPlot
ggsave(NewSequencingData_AvgCitationsPlot, filename = "20231201_NewSequencingData_AvgCitationsPlot.tiff" )
          
    


