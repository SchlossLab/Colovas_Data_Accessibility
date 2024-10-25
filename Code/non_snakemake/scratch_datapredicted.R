# library statements
library(tidyverse)

#read csv of the predictions... 
#ok these aren't quite right, 
# maybe they need to be saved as .RDS files
jmbe_predictions  <- readRDS("Data/predicted/1935-7885.data_predicted.csv")
mra_predictions <- readRDS("Data/predicted/2576-098X.data_predicted.csv")

#okay let's see if the step before that made normal data
jmbe_da_prep <- readRDS("Data/preprocessed/1935-7885.data_availability.preprocessed_predict.RDS")
head(jmbe_da_prep)
head(jmbe_da_prep$paper_doi)

mra_da_prep <- readRDS("Data/preprocessed/2576-098X.data_availability.preprocessed_predict.RDS")
head(mra_da_prep)
head(mra_da_prep$paper_doi)
