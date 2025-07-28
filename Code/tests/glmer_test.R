#glmer test lme4
#
#
#library statements 
library(lme4)
library(tidyverse)
library(sjPlot)


#load local metadata
nsd_yes_metadata <- read_csv("~/Documents/Schloss/Colovas_Data_Accessibility/Data/final/nsd_yes_metadata.csv.gz")

#filter out NAs (important later)
nsd_yes_metadata <- nsd_yes_metadata %>%
  filter(., age.in.months != "NA" & da_factor != "NA" & container.title != "NA") %>% 
  mutate(da_factor = factor(da_factor), 
         container.title = factor(container.title))

# total_model <-glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + container.title + 
#                        + container.title*da_factor + log(age.in.months)*da_factor + container.title*log(age.in.months) + 
#                        log(age.in.months)*da_factor*container.title, data = model_data, link = log)


nsd_yes_10percent <- nsd_yes_metadata %>% 
  slice_sample(., prop = .1, weight_by = container.title)

#start 3:12-325 = 10% of data 
#relative formula = Y ~ data_avl + age + data_avl*age + (1 +data_avl + age + data_avl*age|journal) 
ten_percent_glmer <- glmer.nb(formula = is.referenced.by.count ~ da_factor + age.in.months + da_factor*age.in.months + 
                                (1+da_factor + age.in.months + da_factor*age.in.months|container.title), 
                              data = nsd_yes_10percent)


  # plot_model <- plot_model(model, type = "pred", 
      # terms = c("da_factor", "age.in.months[12,60,84,120,180]"))     
      
plot(ten_percent_glmer)
plot_model(ten_percent_glmer, type = "pred", terms = c("da_factor", "age.in.months[12,60,84]"), 
           bias_correction = FALSE)

   
#let's try the other formula 4:24 -not done at 4:49 done at 4:52
#y ~ data_avl + age + data_avl*age + (1+data_avl|journal) +
#(0+age|journal) + (0+data_avl*age|journal)

ten_percent_glmer_2 <- glmer.nb(formula = is.referenced.by.count ~ da_factor + age.in.months + da_factor*age.in.months + 
                                (1 + da_factor|container.title) + (0 +age.in.months|container.title)  +
                                (0+ da_factor*age.in.months|container.title), 
                              data = nsd_yes_10percent)

plot_model(ten_percent_glmer_2, type = "pred", terms = c("da_factor", "age.in.months[12,60,84]"), 
           bias_correction = FALSE)
