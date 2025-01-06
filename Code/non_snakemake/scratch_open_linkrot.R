#opening linkrot files
#20241028

#library calls
library(tidyverse)

#load files

jmbe_all_links <- read_csv("Data/linkrot/1935-7885/1935-7885.alllinks.csv.gz")
jmbe_links_metadata <- read_csv("Data/linkrot/1935-7885/1935-7885.linksmetadata.csv.gz")

mra_all_links <- read_csv("Data/linkrot/2576-098X/2576-098X.alllinks.csv.gz")
mra_links_metadata <- read_csv("Data/linkrot/2576-098X/2576-098X.linksmetadata.csv.gz")

colnames(jmbe_all_links)
colnames(jmbe_links_metadata)

count(jmbe_all_links, is_alive)
count(jmbe_links_metadata, unique_link_count)

count(mra_all_links, is_alive)
count(mra_links_metadata, unique_link_count)
