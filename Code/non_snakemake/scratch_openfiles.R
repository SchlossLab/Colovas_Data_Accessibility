#scratch_openfiles.R
#
#opening files
#library
library(tidyverse)

import_pre<-read_csv("Data/final/predicted_results.csv.gz")
view(import_pre)

import_pre %>% count(da, nsd)
