# Colovas_Data_Accessibility

New repository for Data Accessibility project begun by Adena Collens. This project, funded by the Office of Research Integrity (ORI), aims to determine the extent of data availability, number of citations, and "link rot" in papers published in the ASM family of journals beginning in year 2000.

## Where Do I Go in the Repository? 

1.  PaperDataCleanup.R shows how the "groundtruth.csv" file was generated to pull in all relevant metadata from necessary files. 

2.  TextScraping.R shows the text scraping process using package rvest to collect the text of all papers. 

3.  TidyingText.R shows the process of transforming scraped HTML text into R package "tidytext" format. 

4.  Webscraping_thrTidyText.R combines TextScraping.R and TidyingText.R for one file that can be run on a high performance computing cluster (See Slurm directory for more details).

5. TextStatistics.R shows the process of working with R package "tidytext" to generate summary statistics from tidytext objects. 

### Other:

-    See most recently dated \*.Rmd file for any relevant project updates.

-   File seq_papers_20230505.RData has been downloaded from github repository Data_Accessibility begun by Adena Collens in 2022 (<https://github.com/SchlossLab/Data_Accessibility/tree/main/data>).

-   This \*.RData file contains many data frames with previously generated data that will be re-generated in the future, but are useful for testing and piloting purposes.
