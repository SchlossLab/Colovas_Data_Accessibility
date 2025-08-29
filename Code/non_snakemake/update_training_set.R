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

#20250331 - continuing to update the training set
new_groundtruth <-read_csv("Data/new_groundtruth.csv")
colnames(new_groundtruth)
to_add_1 <- read_csv("Data/spot_check/20250324_mra_spec_nsd_yes_da_no.csv")
to_add_2<-read_csv("Data/spot_check/20250328_2024_no_mra_spec.csv")
colnames_1 <-colnames(to_add_1)
colnames_2 <-colnames(to_add_2)

to_add<- full_join(to_add_1, to_add_2) %>%
mutate_if(is.double, as.character, .vars = vars("issue", "year.published"))


crossref<- 
    crossref %>% 
    mutate_if(is.double, as.character, .vars = vars("issue", "year.published"))

new_groundtruth <-
    new_groundtruth %>% 
    mutate_if(is.double, as.character, .vars = vars("issue", "year.published"))

add_metadata <-inner_join(to_add, crossref) %>% 
    rename(new_seq_data = actual_nsd, data_availability = actual_da) %>%
    mutate_if(lubridate::is.Date, as.character) %>% 
    mutate_if(is.double, as.character, .vars = vars("issue", "year.published"))

#there are 7 that aren't in crossref but i can't use them because i want the
# uniform metadata in the gt
anti_join(to_add, crossref) %>% 
view()

#making sure all nsd nos are da nos, ~50 papers changed from da yes to da no
new_groundtruth <-
new_groundtruth %>%
mutate(data_availability = ifelse(new_seq_data == "No", "No", data_availability)) %>% 
mutate_if(is.double, as.character, .vars = vars("issue", "year.published"))

#combine new_gt with the newest spot check data
newest_gt <- full_join(new_groundtruth, add_metadata)  %>% 
    mutate_if(lubridate::is.Date, as.character) %>% 
    mutate_if(is.double, as.character, .vars = vars("issue", "year.published")) 

write_csv(newest_gt, "Data/new_groundtruth.csv")

new_groundtruth <-read_csv("Data/new_groundtruth.csv") %>%
    mutate(doi_underscore = str_replace_all(doi, "/", "_"))

write_csv(new_groundtruth, "Data/new_groundtruth.csv")
#this means we don't need new_groundtruth_metadata anymore

#20250828 - update training set AGAIN -----------------------------------------------------------------------------------

library(tidyverse)

new_groundtruth <-read_csv("Data/new_groundtruth.csv") %>% 
        mutate_if(is.double, as.character, .vars = vars("issue", "year.published")) %>% 
        mutate_if(is.logical, as.character, .vars = vars("published.online", "page")) %>%
        select(paper:notes)

to_add_3 <-read_csv("Data/spot_check/20250424_spot_check.csv")  %>%
    select(paper, doi_no_underscore, actual_da, actual_nsd, file, da, nsd, predicted, notes) %>%
    rename(new_seq_data = actual_nsd, data_availability = actual_da, 
    doi = doi_no_underscore)

to_add_4 <- read_csv("Data/spot_check/20250429_genome_announcements.csv") %>%
    mutate_if(is.double, as.character, .vars = vars("issue", "year.published")) %>% 
    mutate_if(is.logical, as.character, .vars = vars("published.online", "page")) %>% 
    select(!assertion:funder & !doi_underscore, published.online) 


to_add_5 <-read_csv("Data/spot_check/20250507_spot_check.csv") %>%
    select(paper, doi_no_underscore, actual_da, actual_nsd, file, da, nsd, predicted, notes) %>%
    rename(new_seq_data = actual_nsd, data_availability = actual_da, doi = doi_no_underscore)

colnames_3 <-colnames(to_add_3)
colnames_4 <-colnames(to_add_4)
colnames_5 <-colnames(to_add_5)


crossref<-read_csv("Data/crossref/crossref_all_papers.csv.gz") %>%
    mutate_if(lubridate::is.Date, as.character) %>% 
    mutate(paper = paste0("https://journals.asm.org/doi/", doi)) %>% 
    mutate_if(is.double, as.character, .vars = vars("issue", "year.published"))

metadata_3 <- inner_join(to_add_3, crossref) %>%
    mutate_if(lubridate::is.Date, as.character) %>% 
    mutate_if(is.double, as.character, .vars = vars("issue", "year.published")) %>%
    select(!author:funder)

# metadata_4 <-
# left_join(to_add_4, crossref) %>%  view()#i cannot figure out why this one is so funky and the variable data doesn't match
#     mutate_if(lubridate::is.Date, as.character) %>% 
#     mutate_if(is.double, as.character, .vars = vars("issue", "year.published"))

metadata_5 <-inner_join(to_add_5, crossref) %>% 
    mutate_if(lubridate::is.Date, as.character) %>% 
    mutate_if(is.double, as.character, .vars = vars("issue", "year.published")) %>%
    select(!author:funder)


to_add_345 <- full_join(metadata_3, metadata_5) %>%
            full_join(., to_add_4) %>% 
            mutate_if(is.double, as.character, .vars = vars("issue", "year.published")) %>% 
            mutate_if(is.logical, as.character, .vars = vars("published.online", "page")) 
        



#combine new_gt with the newest spot check data
newest_gt <- full_join(new_groundtruth, to_add_345)  %>% 
    mutate_if(lubridate::is.Date, as.character) %>% 
    mutate_if(is.double, as.character, .vars = vars("issue", "year.published")) %>%
    mutate(doi_underscore = str_replace_all(doi, "/", "_"),
        file = paste0("Data/html", doi_underscore, ".html"),
        predicted = paste0("Data/predicted", doi_underscore, ".csv"))

write_csv(newest_gt, "Data/new_groundtruth.csv")

#20250829 - making sure that the metadata and dois lists are updated
library(tidyverse)

new_groundtruth <-read_csv("Data/new_groundtruth.csv") %>% 
    mutate_if(lubridate::is.Date, as.character) %>% 
    mutate_if(is.double, as.character, .vars = vars("issue", "year.published")) 
colnames(new_groundtruth)

new_groundtruth_metadata <- read_csv("Data/new_groundtruth_metadata.csv.gz")  %>% 
    mutate_if(lubridate::is.Date, as.character) %>% 
    mutate_if(is.double, as.character, .vars = vars("issue", "year.published")) 
gt_dois <-read_csv("Data/new_groundtruth_dois.csv.gz")

anti_join(new_groundtruth, new_groundtruth_metadata, by = join_by("paper" == "scrape_url")) %>%



new_groundtruth %>%
    filter(is.na(new_seq_data) | is.na(data_availability))

view(new_groundtruth)
