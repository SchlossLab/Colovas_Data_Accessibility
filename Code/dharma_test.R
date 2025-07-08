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
# nsd_yes_metadata <- read_csv("Data/final/nsd_yes_metadata.csv.gz")
#load local metadata

nsd_yes_metadata <- read_csv("~/Documents/Schloss/Colovas_Data_Accessibility/Data/final/nsd_yes_metadata.csv.gz")

nsd_yes_metadata <- nsd_yes_metadata %>%  
  filter(., age.in.months != "NA") 

#430 start- 430 finish damn 
total_model <-glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + container.title + 
        + container.title*da_factor + log(age.in.months)*da_factor + container.title*log(age.in.months) + 
        log(age.in.months)*da_factor*container.title, data = nsd_yes_metadata, link = log)

simulationOutput <- simulateResiduals(fittedModel = total_model, plot = T)
#how do i get the plot if the plot popups are blocked by using extra memory? 
str(simulationOutput)

residuals(simulationOutput)

plot <- plot(simulationOutput)

plotQQunif(simulationOutput)
plotResiduals(simulationOutput)

plotResiduals(simulationOutput, form = nsd_yes_metadata$age.in.months)
plotResiduals(simulationOutput, form = nsd_yes_metadata$da_factor)
plotResiduals(simulationOutput, form = nsd_yes_metadata$container.title) 
