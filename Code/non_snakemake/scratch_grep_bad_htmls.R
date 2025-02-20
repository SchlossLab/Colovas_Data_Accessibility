


#library 
library(tidyverse)

#get list of all html files
list_files <- list.files("Data/html", full.names = TRUE)

#look for illegal filenames 
grep("10.1128", list_files, invert = TRUE, value = TRUE)


grep("10.1128/\\d", list_files, value = TRUE) # this one is 0
grep("10.1128/\\.", list_files, value = TRUE)


unique_dois <-tibble(all_dois) %>% 
    filter(!str_detect("10.1128/\\.", all_dois) & !str_detect("10.1128/\\d", all_dois)) %>%
    unique()