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
#i want percentages!
nsd_yes_metadata %>% 
  filter(year.published >= 2020) %>%
  count(year.published, da, container.title) %>% 
  mutate(da_fract = )
  ggplot(aes(y = year.published, x = `n`)) +
  geom_point() +
  facet_wrap(vars(container.title),
             labeller = labeller(container.title = label_wrap_gen(12)))
  
    
#calculate fraction of papers with nsd yes and da yes
post_2020 <- nsd_yes_metadata %>% 
    filter(year.published >= 2020)

post_2020 %>% 
  group_by(year.published, container.title) %>%  
  count(year.published, container.title, da) %>% 
  mutate(da_total = sum(`n`), 
         da_fract = `n`/da_total) %>% 
  filter(da == "Yes") %>% s
  ggplot(aes(x = year.published, y = da_fract)) +
  geom_line() + 
  geom_point() +
  facet_wrap(vars(container.title),
             labeller = labeller(container.title = label_wrap_gen(14))) + 
  labs(x = "Year Published (2020-2024)", 
       y = "Fraction of Papers Containing New\nSequencing Data with Data Available", 
       title = "Fraction of Papers Containing New Sequencing Data\nwith Data Available Over 2020-2024 by ASM Journal") 
  ggsave(filename = "Figures/nsdyes_da_over_time.png")




