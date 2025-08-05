#20250312 - 
#checking feature importance of variables that 
#i want to remove from my training set

#here's my list of missing vars
#interest importance 
#material method bacterial 
#grp1-4

#library
library(tidyverse)

da5<-readRDS("Data/ml_results/groundtruth/rf/data_availability/rf.data_availability.5.model.RDS")
rf9<-readRDS("Data/ml_results/groundtruth/rf/new_seq_data/rf.new_seq_data.9.model.RDS")

str(da5)

da5$finalModel$importance[c("`interest importance`_1", "`interest importance`_0") ,]

da5$finalModel$importance[c("`interest importance`_1", "`interest importance`_0", 
                        "`material method bacterial`_1", "`material method bacterial`_0", 
                        "grp1","grp2","grp3","grp4"), ]



rf9$finalModel$importance[c("`interest importance`_1", "`interest importance`_0", 
                        "`material method bacterial`_1", "`material method bacterial`_0", 
                        "grp1","grp2","grp3","grp4"), ]

str(da5$finalModel$importance) 
colnames(da5$finalModel$importance)
