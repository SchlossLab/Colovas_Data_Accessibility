#!/usr/bin/env Rscript
# working on negative binomial regression with dharma
#
#library statements 
library(tidyverse)
library(MASS)
library(jtools)
install.packages("DHARMa")
library(DHARMa)



#load metadata
nsd_yes_metadata <- read_csv("Data/final/nsd_yes_metadata.csv.gz")


total_model <-glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + container.title + 
        + container.title*da_factor + log(age.in.months)*da_factor + container.title*log(age.in.months) + 
        log(age.in.months)*da_factor*container.title, data = nsd_yes_metadata, link = log)

simulationOutput <- simulateResiduals(fittedModel = total_model, plot = F)
#how do i get the plot if the plot popups are blocked by using extra memory? 
str(simulationOutput)

residuals(simulationOutput)

plot <- plot(simulationOutput)

plot(simulationOutput) %>% 
ggsave(., file = "Figures/simulation_residuals.png")
