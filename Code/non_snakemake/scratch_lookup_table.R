# no shebang, doesn't need to be run on the cluster
#
#
#library statements
library(tidyverse)

#need to import all the metadata files
papers_dir <- "Data/papers"
csv_files <- list.files(papers_dir, "*.csv")


all_papers <- tribble(~paper, ~html_filename, ~container.title)

for (i in 1:12) {
    csv_file <- read_csv(paste0(papers_dir, "/", csv_files[i])) %>%
        select(., c(`paper`, `container.title`, `html_filename`))
    all_papers <- full_join(all_papers, csv_file)
}


write_csv(all_papers, file = "Data/papers/lookup_table.csv.gz")


#20241202 - how diff are the 2 ztables
# they are the same it doesn't matter - great amazing

ztable_da <- read_csv("Data/ml_prep/groundtruth.data_availability.zscoretable_filtered.csv")
ztable_nsd <- read_csv("Data/ml_prep/groundtruth.new_seq_data.zscoretable_filtered.csv")


total <- full_join(ztable_da, ztable_nsd)
view(total)

