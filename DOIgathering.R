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

#function to gather all DOIs from Y2K

gather_dois <- function(issn_no) {
 #crossref query
  metadata_list <- cr_journals(issn = issn_no, 
              works = TRUE,
              sort = "published-print",
              order = "asc",
              cursor_max = 25000,
              cursor = "*", 
              filter = list(from_pub_date = "2000"))
 
  #get only metadata part of the list 
  metadata <- metadata_list[["data"]]
  
  #save as an RDS file
  saveRDS(metadata_list, str_glue("Data/{issn_no}_metadata.RDS"))
  
}

walk(asm_journals$issn, gather_dois)



