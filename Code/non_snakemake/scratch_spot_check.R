#scratch spot check predictions
#
#
#
#library
library(tidyverse)

# load in dataset of predicted stuff
predicted_files <- read_csv("Data/final/predicted_results.csv.gz")

head(predicted_files)

#okay need to make column with the link in it or join with other table 

lookup_table <-read_csv("Data/papers/lookup_table.csv.gz")
head(lookup_table)

joined_predictions <- full_join(predicted_files, lookup_table, by = join_by("file" == "html_filename")) %>%
    mutate(actual_da = 0, actual_nsd = 0)


#slice however many n 150 maybe? 
sliced <-slice_sample(joined_predictions, by = c(da, nsd), n = 30)

#save it so that i can spot check them using excel 
write_csv(sliced, file = "Data/spot_check/spot_check.csv")

