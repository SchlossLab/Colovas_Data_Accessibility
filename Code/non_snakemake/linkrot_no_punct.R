#create df of links to check with removed punctuation at the end 
#
#
#
#library statements
library(tidyverse)

linkrot<-read_csv("Data/final/linkrot_combined.csv.gz")
head(linkrot)

punct <-linkrot %>%
    filter(str_ends(link_address, "\\.")| str_ends(link_address, "\\,") | str_ends(link_address, "\\;") 
    | str_ends(link_address, "\\:") | str_ends(link_address, "\\(") | str_ends(link_address, "\\)") | str_ends(link_address, "[:punct:]")) %>%
    filter(link_status != 200)

punct %>%
    mutate(no_punct = str_remove(link_address, "[\\.\\,\\;\\:\\(\\):punct:$]")) %>% 
    view(no_punct)
