# look at DA over time 
#
#
#library statements
library(tidyverse)


# load in dataset of predicted stuff with metadata
metadata <- read_csv("Data/final/predictions_with_metadata.csv.gz")

#add year published
metadata <- metadata %>% 
    mutate(year.published = dplyr::case_when((is.na(pub_date) & !is.na(issued) & is.na(publishYear)) ~ str_sub(issued, start = 1, end = 4), 
                        (!is.na(pub_date) & is.na(issued) & is.na(publishYear)) ~ as.character(pub_year), 
                        (is.na(pub_date) & is.na(issued) & !is.na(publishYear)) ~ as.character(publishYear), 
                        FALSE ~ NA_character_), 
          issued.date = ymd(issued, truncated = 2) %||% ymd(pub_date, truncated = 2))

metadata <- metadata %>% 
  mutate(age.in.months = interval(metadata$issued.date, ymd("2025-01-01")) %/% months(1))

#filter for nsd yes
nsd_yes_metadata <- 
  metadata %>% 
  filter(nsd == "Yes")


##this is so ugly but i will work on it more tomorrow
#yes i understand that both yes and no are here
#i want percentages!
nsd_yes_metadata %>% 
  group_by(year.published, container.title) %>% 
  count(year.published, container.title, da) %>% 
  mutate(da_total = sum(`n`), 
         da_fract = `n`/da_total) %>%
 filter(da == "Yes") %>% 
  ggplot(aes(x = year.published, y = da_fract)) +
  geom_col() +
  facet_wrap(vars(container.title),
             labeller = labeller(container.title = label_wrap_gen(14))) + 
  labs(x = "Year Published (2000-2024)", 
       y = "Fraction of Papers Containing New\nSequencing Data with Data Available", 
       title = "Fraction of Papers Containing New Sequencing Data\nwith Data Available Over 2020-2024 by ASM Journal") 
  ggsave(filename = "Figures/nsdyes_da_2000_2024.png")
    
#calculate fraction of papers with nsd yes and da yes
post_2020 <- nsd_yes_metadata %>% 
    filter(year.published >= 2020)

post_2020 %>% 
  group_by(year.published, container.title) %>%  
  count(year.published, container.title, da) %>% 
  mutate(da_total = sum(`n`), 
         da_fract = `n`/da_total) %>% 
  filter(da == "Yes") %>% 
  ggplot(aes(x = year.published, y = da_fract)) +
  # geom_line() + 
  geom_col() +
  facet_wrap(vars(container.title),
             labeller = labeller(container.title = label_wrap_gen(14))) + 
  labs(x = "Year Published (2020-2024)", 
       y = "Fraction of Papers Containing New\nSequencing Data with Data Available", 
       title = "Fraction of Papers Containing New Sequencing Data\nwith Data Available Over 2020-2024 by ASM Journal") 
  ggsave(filename = "Figures/nsdyes_da_2020_2024.png")

  nsd_yes_metadata %>% 
    group_by(year.published, container.title) %>%  
    count(year.published, container.title, da) %>% 
    mutate(da_total = sum(`n`), 
           da_fract = `n`/da_total) %>% 
    filter(da == "Yes") %>% 
    ggplot(aes(x = year.published, y = da_fract)) +
    geom_line() + 
    geom_point() +
    facet_wrap(vars(container.title),
               labeller = labeller(container.title = label_wrap_gen(14))) + 
    labs(x = "Year Published (2020-2024)", 
         y = "Fraction of Papers Containing New\nSequencing Data with Data Available", 
         title = "Fraction of Papers Containing New Sequencing Data\nwith Data Available Over 2020-2024 by ASM Journal") 
  ggsave(filename = "Figures/nsdyes_da_over_time_2000.png")
  



