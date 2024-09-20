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
              cursor_max = 50000,
              cursor = "*", 
              filter = list(from_pub_date = "2000"))
 
  #get only metadata part of the list 
  metadata <- metadata_list[["data"]]
  
  #save as an RDS file
  saveRDS(metadata, str_glue("Data/{issn_no}_metadata.RDS"))
  
}

walk(asm_journals$issn, gather_dois)

#redo doi gathering for 1098-5336, AEM
gather_dois(asm_journals$issn[2])

#add column in df for the metadata filename
asm_journals <- mutate(asm_journals,
  metadata_file = paste0("Data/", asm_journals$issn, "_metadata.RDS")
)

# for (i in asm_journals$issn[]) {
#   assign(i, asm_journals$issn[i])
#   
# }

# for (i in 1:12) {
#   name <- str_glue_data("{asm_journals$issn[i]}_metadata") 
#   name <- readRDS(asm_journals$metadata_file[i])
# }

# metadata_1098_6596 <- readRDS("Data/1098-6596_metadata.RDS")
# metadata_1098_5336 <- readRDS("Data/1098-5336_metadata.RDS")
# metadata_1098_5522 <- readRDS("Data/1098-5522_metadata.RDS")
# metadata_1098_5530 <- readRDS("Data/1098-5530_metadata.RDS")
# metadata_0095_1137 <- readRDS("Data/0095-1137_metadata.RDS")
# metadata_1935_7885 <- readRDS("Data/1935-7885_metadata.RDS")
# metadata_1098_5514 <- readRDS("Data/1098-5514_metadata.RDS")
# metadata_2150_7511 <- readRDS("Data/2150-7511_metadata.RDS")
# metadata_2576_098X <- readRDS("Data/2576-098X_metadata.RDS")
# metadata_2165_0497 <- readRDS("Data/2165-0497_metadata.RDS")
# metadata_2379_5042 <- readRDS("Data/2379-5042_metadata.RDS")
# metadata_2379_5077 <- readRDS("Data/2379-5077_metadata.RDS")

