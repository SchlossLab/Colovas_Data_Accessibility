#SummaryFigureGenerator.R

#Joanna Colovas

#This file will generate summary figures from data frames created in file PaperDataCleanup.R

#load necessary packages
library(tidyverse)

groundtruth <- read_csv("Data/groundtruth.csv")

#create and save graph showing number of sequencing/non sequencing papers across ASM journals
NewSequencingDataPlot <- 
  ggplot(data = groundtruth, aes(x = container.title,
           fill = new_seq_data)) + 
    geom_bar(position= "dodge") +
    theme(axis.text.x = element_text(angle = 75, vjust = 1, hjust=1)) +
    labs( y = "Manuscript Count", 
          x = "ASM Journal", 
          fill = "Is there new 
  sequencing data?",
          title = "Status of Manually-Assessed Sequencing Manuscripts
  Across ASM Journals Containing New Sequencing Data (N=446)")  +
  scale_fill_manual(values = c("red", "blue"))

NewSequencingDataPlot
ggsave(NewSequencingDataPlot, filename = "Adena_Stuff/NewSequencingDataPlot.png" )

#create and save graph showing number of sequencing papers across ASM journals with data available

#filter for only papers with data available 
papers_data_available <-  filter(groundtruth, new_seq_data == "Yes") 
count(papers_data_available, container.title)

NewSequencingData_AvailablePlot <- 
    ggplot(data = papers_data_available, aes( x = container.title,
                                               fill = data_available)) + 
    geom_bar(position = "dodge") +
    theme(axis.text.x = element_text(angle = 75, vjust = 1, hjust=1)) +
    labs( y = "Manuscript Count", 
          x = "ASM Journal", 
          fill = "Is the new sequencing
      data available?",
          title = "Subset of Manually-Assessed Sequencing 
Manuscripts Across ASM Journals Containing New 
Sequencing Data (N=181)") +
 scale_fill_manual(values = c("blue", "red"))

NewSequencingData_AvailablePlot
ggsave(NewSequencingData_AvailablePlot, filename = "Adena_Stuff/NewSequencingData_AvailablePlot.png" )
        

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
Sequencing Data with Data Available (N=181)") +
  scale_fill_manual(values = c("blue", "red"))

NewSequencingData_AvgCitationsPlot
ggsave(NewSequencingData_AvgCitationsPlot, filename = "Adena_Stuff/NewSequencingData_AvgCitationsPlot.png" )


#create and save graph showing average number of citations if data is presented and is/not available, by year
sortbyYear <-  arrange(papers_data_available, by = year.published)
sortbyYear$year.published <- as.character(sortbyYear$year.published)

NewSequencingData_AvgCitationsPlot_byYear <- 
  ggplot(data = sortbyYear, aes( x = year.published,
                                            fill = data_available,
                                            y = is.referenced.by.count)) + 
  geom_boxplot() +
  theme(axis.text.x = element_text(angle = 75, vjust = 1, hjust=1)) +
  labs( y = "Number of Citations via CrossRef", 
        x = "Year Published", 
        fill = "Is there sequencing
      data available?",
        title = "Average Number of Citations for Subset of Manually-Assessed 
Sequencing Manuscripts Across ASM Journals Containing New 
Sequencing Data with Data Available (N=181)") +
  scale_fill_manual(values = c("blue", "red"))

NewSequencingData_AvgCitationsPlot_byYear
ggsave(NewSequencingData_AvgCitationsPlot_byYear, filename = "Adena_Stuff/NewSequencingData_AvgCitationsPlot_byYear.png" )

#filter for only papers with data available, count data by year 

NewSequencingData_AvailablePlot_byYear <- 
  ggplot(data = sortbyYear, aes( x = year.published,
                                            fill = data_available)) + 
  geom_bar(position = "dodge") +
  theme(axis.text.x = element_text(angle = 75, vjust = 1, hjust=1)) +
  labs( y = "Manuscript Count", 
        x = "Year Published", 
        fill = "Is the new sequencing
      data available?",
        title = "Subset of Manually-Assessed Sequencing 
Manuscripts Across ASM Journals Containing New 
Sequencing Data (N=181)") +
  scale_fill_manual(values = c("blue", "red"))

NewSequencingData_AvailablePlot_byYear
ggsave(NewSequencingData_AvailablePlot_byYear, filename = "Adena_Stuff/NewSequencingData_AvailablePlot_byYear.png" )


#filter for only papers without data available 
papers_nodata_available <-  filter(groundtruth, new_seq_data == "No") 
count(papers_nodata_available, container.title)

#create and save graph showing average number of citations if data is presented and is/not available, by year
sortbyYear_no <-  arrange(papers_nodata_available, by = year.published)
sortbyYear_no$year.published <- as.character(sortbyYear_no$year.published)

NoNewSequencingData_AvgCitationsPlot_byYear <- 
  ggplot(data = sortbyYear_no, aes( x = year.published,
                                 fill = data_available,
                                 y = is.referenced.by.count)) + 
  geom_boxplot() +
  theme(axis.text.x = element_text(angle = 75, vjust = 1, hjust=1)) +
  labs( y = "Number of Citations via CrossRef", 
        x = "Year Published", 
        fill = "Is there sequencing
      data available?",
        title = "Average Number of Citations for Subset of Manually-Assessed 
Sequencing Manuscripts Across ASM Journals NOT Containing New 
Sequencing Data with Data Available (N=265)") +
  scale_fill_manual(values = c("blue", "red"))

NoNewSequencingData_AvgCitationsPlot_byYear
ggsave(NoNewSequencingData_AvgCitationsPlot_byYear, filename = "Adena_Stuff/NoNewSequencingData_AvgCitationsPlot_byYear.png" )

#filter for only papers without new seuqencing data, count data by year 

NoNewSequencingData_AvailablePlot_byYear <- 
  ggplot(data = sortbyYear_no, aes( x = year.published,
                                 fill = data_available)) + 
  geom_bar(position = "dodge") +
  theme(axis.text.x = element_text(angle = 75, vjust = 1, hjust=1)) +
  labs( y = "Manuscript Count", 
        x = "Year Published", 
        fill = "Is there new sequencing
      data available?",
        title = "Subset of Manually-Assessed Sequencing 
Manuscripts Across ASM Journals NOT Containing New 
Sequencing Data (N=265)") +
  scale_fill_manual(values = c("blue", "red"))

NoNewSequencingData_AvailablePlot_byYear
ggsave(NoNewSequencingData_AvailablePlot_byYear, filename = "Adena_Stuff/NoNewSequencingData_AvailablePlot_byYear.png" )


#filter for only papers without new seuqencing data, count data by journal
NoNewSequencingData_AvailablePlot <- 
  ggplot(data = papers_nodata_available, aes( x = container.title,
                                            fill = data_available)) + 
  geom_bar(position = "dodge") +
  theme(axis.text.x = element_text(angle = 75, vjust = 1, hjust=1)) +
  labs( y = "Manuscript Count", 
        x = "ASM Journal", 
        fill = "Is there new sequencing
      data available?",
        title = "Subset of Manually-Assessed Sequencing 
Manuscripts Across ASM Journals Containing New 
Sequencing Data (N=265)") +
  scale_fill_manual(values = c("blue", "red"))

NoNewSequencingData_AvailablePlot
ggsave(NoNewSequencingData_AvailablePlot, filename = "Adena_Stuff/NoNewSequencingData_AvailablePlot.png" )
