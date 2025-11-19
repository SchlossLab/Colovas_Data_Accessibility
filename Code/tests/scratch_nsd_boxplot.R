#nsd boxplot

#had to do in Rstudio
#library statements 
library(tidyverse)
library(stats)
library(ggpubr)
# install.packages("ggpubr")

#import files
metadata <- 
read_csv("/Users/jocolova/Documents/Schloss/Colovas_Data_Accessibility/Data/final/predictions_with_metadata.csv.gz")

#filter for data from 2020 
twenty20 <-
metadata %>%
    filter(., year.published == 2020 & nsd != "NA")
    


twenty20 %>% 
    ggplot(., aes(x = factor(nsd), y = is.referenced.by.count)) + 
    geom_boxplot(outliers = FALSE) + 
    facet_wrap(vars(container.title), scale = "free_y", 
    labeller = label_wrap_gen(width = 20)) + 
    labs(x = "Does paper have new sequencing data?", 
    y = "Number of citations", 
    title = "Comparing citations for nsd yes vs nsd no in 2020\nwith Wilcox test of significance") + 
    stat_compare_means(method = "wilcox.test", label = "p.signif", 
                       label.y = -10)

ggsave(filename = "/Users/jocolova/Documents/Schloss/Colovas_Data_Accessibility/Figures/2020_nsd_boxplot_sig.png")


twenty20 %>% 
    ggplot(., aes(x = factor(nsd), y = is.referenced.by.count)) + 
    geom_boxplot() + 
    facet_wrap(vars(container.title), scale = "free_y", 
    labeller = label_wrap_gen(width = 20)) + 
    labs(x = "Does paper have new sequencing data?", 
    y = "Number of citations", 
    title = "Comparing citations for nsd yes vs nsd no in 2020 with outliers") 

ggsave(filename = "/Users/jocolova/Documents/Schloss/Colovas_Data_Accessibility/Figures/2020_nsd_boxplot_outliers.png")


#perform wilcox test using wilcox.test from stats
wilcox.test(formula = is.referenced.by.count ~ factor(nsd), data = twenty20)

twenty20 %>%
    quantile()