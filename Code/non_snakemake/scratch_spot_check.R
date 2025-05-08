#scratch spot check predictions
#
#
#
#library
library(tidyverse)
library(caret)

# load in dataset of predicted stuff
predicted_files <- read_csv("Data/final/predicted_results.csv.gz")

head(predicted_files)

#okay need to make column with the link in it or join with other table 

lookup_table <-read_csv("Data/all_dois_lookup_table.csv.gz")
head(lookup_table)
#yes i know these are backwards for da/nsd but the model are in that order so it's easier to see
joined_predictions <- full_join(predicted_files, lookup_table, by = join_by("file" == "html_filename")) %>%
    mutate(actual_da = 0, actual_nsd = 0, notes = NA)


#slice however many n 150 maybe? 
sliced <-slice_sample(joined_predictions, by = c(container.title), n = 10)
view(sliced)
#save it so that i can spot check them using excel 
# write_csv(sliced, file = "Data/spot_check/20250507_spot_check.csv")

#20250110 - spot check metrics
#read in spot check file
# spot_check <- read_csv("Data/spot_check/spot_check.csv")
# spot_check <- read_csv("Data/spot_check/20250324_mra_spec_nsd_yes_da_no.csv")
spot_check <- read_csv("Data/spot_check/20250424_spot_check.csv")

#find rows where da!=actual_da and same for nsd

#8/130 = 
spot_check_da <- 
    spot_check %>% 
    filter(da != actual_da)

#8/130 rows
spot_check_nsd <- 
    spot_check %>% 
    filter(nsd != actual_nsd)

#16/130
spot_check_all <- 
    spot_check %>% 
    filter(nsd != actual_nsd | da != actual_da)

confusion_matrix_nsd <- confusionMatrix(data = factor(spot_check$nsd), reference = factor(spot_check$actual_nsd))
confusion_matrix_da <- confusionMatrix(data = factor(spot_check$da), reference = factor(spot_check$actual_da))
str(spot_check$nsd)
str(spot_check$actual_nsd)


#filter for only nsd = yes

nsd_yes <- 
    spot_check %>%
    filter(nsd == "Yes" | actual_nsd == "Yes")

confusion_matrix_nsd_only_nsd <- confusionMatrix(data = factor(nsd_yes$nsd), reference = factor(nsd_yes$actual_nsd))
confusion_matrix_nsd_only_da <- confusionMatrix(data = factor(nsd_yes$da), reference = factor(nsd_yes$actual_da))

    

#20250324 - spot check nsd yes, da no for mra, and spectrum
#
#library statements
library(tidyverse)


# load in dataset of predicted stuff with metadata
metadata <- read_csv("Data/final/predictions_with_metadata.csv.gz")

# #add year published
metadata <- metadata %>% 
    mutate(year.published = dplyr::case_when((is.na(pub_date) & !is.na(issued) & is.na(publishYear)) ~ str_sub(issued, start = 1, end = 4), 
                        (!is.na(pub_date) & is.na(issued) & is.na(publishYear)) ~ as.character(pub_year), 
                        (is.na(pub_date) & is.na(issued) & !is.na(publishYear)) ~ as.character(publishYear), 
                        FALSE ~ NA_character_), 
          issued.date = ymd(issued, truncated = 2) %||% ymd(pub_date, truncated = 2))

# metadata <- metadata %>% 
#   mutate(age.in.months = interval(metadata$issued.date, ymd("2025-01-01")) %/% months(1))

#filter for nsd yes
nsd_yes_metadata <- 
  metadata %>% 
  filter(nsd == "Yes") %>% 
  unique()

count(nsd_yes_metadata, container.title, year.published)

#get mra and spectrum 
nsd_yes_metadata %>% 
    filter(da == "No" & (container.title == "Microbiology Resource Announcements" | container.title == "Microbiology Spectrum")) %>% 
    dplyr::select(., paper, doi_no_underscore, nsd, da, container.title, year.published) %>%
    # count(year.published)
    slice_sample(., by = c(container.title, year.published), n = 5) %>%
    write_csv(., file = "Data/spot_check/20250324_mra_spec_nsd_yes_da_no.csv")


#20250327 - getting all 2024 papers for pat 
# nsd yes, da status in the table

nsd_yes_metadata %>%
    filter(year.published == "2024" ) %>%
    dplyr::select(., paper, doi_no_underscore, nsd, da, container.title, year.published) %>% 
    mutate(actual_nsd = NA, actual_da = NA, notes = NA) %>%
    write_csv(., file = "Data/spot_check/20250327_all_2024_nsd_yes.csv")
    

#20250328 - take nsd yes metadata and grab a few dozen from 2024
metadata %>%
    filter(year.published == "2024" & (container.title != "Microbiology Resource Announcements" | container.title != "Microbiology Spectrum")) %>%
    dplyr::select(., paper, doi_no_underscore, nsd, da, container.title, year.published) %>% 
    mutate(actual_nsd = NA, actual_da = NA, notes = NA) %>%
    slice_sample(., by = container.title, n = 4) %>% 
    write_csv(., file = "Data/spot_check/20250328_2024_no_mra_spec.csv")
