# in case i need to load stuff for how these files look 


library(tidyverse)

one_csv_file <- read_csv("Data/papers/1935-7885.csv")

head(one_csv_file$unique_id)

select(one_csv_file, c(paper, unique_id)) %>%
    tail()
