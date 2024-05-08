# What's Here?

-   PapersDataCleanup.R shows how the "groundtruth.csv" file was generated to pull in all relevant metadata from necessary files. 

-   TextScraping.R shows the text scraping process using package rvest to collect the text of all papers. 

-   TidyingText.R shows the process of transforming scraped HTML text into R package "tidytext" format. 

-   Webscraping_thrTidyText.R combines TextScraping.R and TidyingText.R for one file that can be run on a high performance computing cluster (See Slurm directory for more details).

-   TextStatistics.R shows the process of working with R package "tidytext" to generate summary statistics from tidytext objects. TextStatistics_SumFigs.R creates summary figures from data generated in TextStatistics.R.

-   Files MLprep.R and TidyModels.R are two parallel development processes for using either mikropml or tidymodels R packages for machine learning models. 
    
-   LinkRot.R uses scraped webpage html to generate a list of author-added external manuscript links for each paper DOI. LinkRot_FigureGenerator.R uses data generated in LinkRot.R to create summary figures. 
    
-   DOIgathering.R and AEM_doigathering.R use the crossref citation API to gather metadata for all ASM papers since 2000 for each of the 12 ASM journals of interest. AEM failed upon first attempt and AEM_doigathering.R was created to re-create the files for journal AEM. 
