#!/usr/bin/env Rscript
# auroc_fig.R
# trying to create panel A of fig 2
# https://journals.asm.org/doi/10.1128/msphere.00336-23
#
# library statements
library(tidyverse)

# get file input from snakemake
input <- commandArgs(trailingOnly = TRUE)
filepath <- input[1]
method <- as.character(input[2])
ml_var <- input[3]

# local data
# filepath <- "Data/ml_results/groundtruth/rf/data_availability"
# ml_var <- "data_availability"


#get list of all files
files_list <- list.files(filepath, 
                        pattern = "hp_performance.csv", 
                        full.names = TRUE)

index <- 
    grep("1234", files_list)

files_list <- files_list[-index]

all_mtry <- read_csv(files_list)

# need to summarize for measures of central tendency
# of each AUC for each mtry value 
summary <-
    all_mtry %>% 
        group_by(mtry) %>% 
        summarise(mean_AUC = format(round(mean(AUC),digits=4), nsmall=4))

# graph mtry on the y axis and auroc on the x axis 
auroc <-
    all_mtry %>% 
        ggplot(aes(x = AUC, y = factor(mtry), color = factor(mtry))) +
        geom_jitter(height=0.2,width=0,alpha = 0.4,size=2) + 
        scale_y_discrete(breaks = c(84, 100, 150, 200, 300)) + 
        stat_summary(fun = mean, geom="pointrange",
                    fun.max = function(x) mean(x) + sd(x),
                    fun.min = function(x) mean(x) - sd(x),
                    color="black",size=1,linewidth=1) +
        geom_text(data=summary,aes(y=factor(mtry),x=as.numeric(mean_AUC),label=mean_AUC),
                vjust=4,size=4.2,color="black") +
        labs(x = "AUROC", 
            y = "MTRY Value", 
            title = str_glue("AUROC of Training Set by MTRY Value for model {ml_var}"), 
            color = "Mtry Value"
            )

ggsave(auroc, filename = str_glue("{filepath}/auroc.{ml_var}.png"))  
