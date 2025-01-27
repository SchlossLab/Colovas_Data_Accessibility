# look at DA over time 
#
#
#library statements
library(tidyverse)


# load in dataset of predicted stuff with metadata
metadata <- read_csv("Data/final/predictions_with_metadata.csv.gz")

#add year published
metadata <- metadata %>% 
  mutate(year.published = as.numeric(str_sub(issued, start = 1, end = 4)))

#filter for nsd yes
nsd_yes_metadata <- 
  metadata %>% 
  filter(nsd == "Yes")


##this is so ugly but i will work on it more tomorrow
#yes i understand that both yes and no are here
nsd_yes_metadata %>% 
  filter(year.published >= 2020) %>%
  count(year.published, da, container.title) %>% 
  ggplot(aes(y = year.published, x = `n`, color = container.title)) +
  geom_point() +
  facet_wrap(vars(container.title))
    

