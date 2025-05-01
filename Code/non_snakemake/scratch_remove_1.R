#library 
library(tidyverse)

da<-readRDS("Data/preprocessed/groundtruth.data_availability.preprocessed.RDS")

grep("_1", da$grp_feats, value = TRUE)
str(da)

grp_feats <- da$grp_feats %>%
    unlist() %>%
    tibble(tokens = .)

filter(grp_feats, str_detect(tokens, "_1", negate = TRUE))
!grp_feats$tokens %in% "_1"

which(str_detect(grp_feats$tokens, "_1")) %>%
length()
