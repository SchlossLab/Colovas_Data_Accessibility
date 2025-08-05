#20250522 - statistical meeting with cscar
#library 
library(tidyverse)

#local 
# metadata <- read_csv("~/Documents/Schloss/Colovas_Data_Accessibility/Data/final/cscar_metadata.csv")
#cluster
metadata <- read_csv("Data/final/cscar_metadata.csv")

nsd_yes_metadata <- 
  metadata %>% 
    filter(nsd == "Yes") %>%
    mutate(da_factor = factor(da))

#data avaiability and age in months by themselves, correlational 
summary(lm(is.referenced.by.count~0+da_factor + age.in.months, data = nsd_yes_da_factor))
summary(lm(is.referenced.by.count~0+da_factor + da_factor:age.in.months, data = nsd_yes_da_factor))

#Models for journal and age in months
summary(lm(is.referenced.by.count~ 0 + journal_abrev + age.in.months, data = nsd_yes_metadata))
summary(lm(is.referenced.by.count~0+journal_factor + journal_factor:age.in.months, data = nsd_yes_da_factor))

#Model for interaction terms of journal and Data Availability\nstatus considering the age in months
summary(lm(is.referenced.by.count~0+ da_factor:journal_factor:age.in.months, data = nsd_yes_da_factor))
