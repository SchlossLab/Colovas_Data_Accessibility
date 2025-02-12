#20250212 - 
#update training set to include spot check and spot check for mra 
# need to grab metadata for these papers as well, and make sure that 
#i have all of the right webscrapes (will update the webscrapes)
#
#
#library
library(tidyverse)

#load files - ground truth, spot check, mra 
groundtruth <- read_csv("Data/groundtruth.csv") %>% 
    select(paper:data_availability, alternative.id:year.published) %>% 
    mutate_if(lubridate::is.Date, as.character) %>% 
    mutate_if(is.double, as.character, .vars = vars("issue"))
spot_check <- read_csv("Data/spot_check/spot_check.csv")
mra_2024 <-read_csv("Data/spot_check/mra_2024_nsd_yes_da_no.csv")

#load crossref to get metadata for spot checked data
crossref<-read_csv("Data/crossref/crossref_all_papers.csv.gz")

#make sure there's a variable in common - here paper 
crossref <-
crossref %>%
    mutate(paper = paste0("https://journals.asm.org/doi/", doi))

#join with metadata and give correct names to columns
sc_metadata <-inner_join(spot_check, crossref) %>% 
    rename(new_seq_data = actual_nsd, data_availability = actual_da) %>%
    mutate_if(lubridate::is.Date, as.character) %>% 
    mutate_if(is.double, as.character, .vars = vars("issue"))

mra_metadata <-inner_join(mra_2024, crossref) %>% 
    rename(new_seq_data = actual_nsd, data_availability = actual_da) %>% 
    mutate_if(lubridate::is.Date, as.character) %>% 
    mutate_if(is.double, as.character, .vars = vars("issue"))

#join with groundtruth, remove NAs
new_groundtruth <- full_join(groundtruth, sc_metadata) %>% 
    full_join(., mra_metadata) %>% 
    filter(!is.na(new_seq_data))


write_csv(new_groundtruth, "Data/new_groundtruth.csv")


#ok so i want to know if all the gt files are in crossref so that they will be scraped with the normal rule 
#why is there literally 1 missing 

groundtruth <- 
groundtruth %>%
    mutate_if(lubridate::is.Date, as.character) %>% 
    mutate_if(is.double, as.character, .vars = vars("issue"))

crossref <-
crossref %>%
    mutate_if(lubridate::is.Date, as.character) %>% 
    mutate_if(is.double, as.character, .vars = vars("issue"))

inner <-inner_join(groundtruth, crossref)
left <- left_join(groundtruth, crossref)

view(inner)
view(left)
