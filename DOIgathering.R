# DOI gathering 
#
#
#library statements
library(tidyverse)
library(rcrossref)


#make tibble of ISSNs and journal names for 12 ASM journals 
issn <-  c("1098-6596", "1098-5336", "1098-5522", "1098-5530", "0095-1137", "1935-7885", 
           "1098-5514", "2150-7511", "2576-098X", "2165-0497", "2379-5042", "2379-5077") 

journal_name <- c("Antimicrobial Agents and Chemotherapy", "Applied and Envrionmental Microbiology",
                  "Infection and Immunity", "Journal of Bacteriology", "Journal of Clinical Microbiology", 
                  "Journal of Microbiology & Biology Education", "Journal of Virology", "mBio",
                  "Microbiology Resource Announcements", "Microbiology Spectrum", "mSphere", "mSystems" )
journal_acronym <- c("AAC", "AEM", "I&I", "JB", "JCB", "JMBE", "JV", "mBio", "MRA", "MS", "mSph", "mSys")

asm_journals <- tibble(journal_name, journal_acronym, issn)

#crossref query for 1 journal for 1 years worth of papers
#AAC for year 2000

aac_y2000 <- cr_journals(issn = asm_journals$issn[1], 
                         .progress = "time", 
                         limit=20, 
                         works = TRUE,
                filter = list(from_pub_date = "2000", until_pub_date = "2001"))


