#glmer test lme4
#
#
#library statements 
library(lme4)
library(tidyverse)
library(sjPlot)
library(msm)


#load local metadata
nsd_yes_metadata <- read_csv("~/Documents/Schloss/Colovas_Data_Accessibility/Data/final/nsd_yes_metadata.csv.gz")

#filter out NAs (important later)
nsd_yes_metadata <-
  nsd_yes_metadata %>%
  filter(., age.in.months != "NA" & da_factor != "NA" & container.title != "NA") %>% 
  mutate(da_factor = factor(da_factor), 
         container.title = factor(container.title)) %>% 
  filter(container.title != "Journal of Microbiology &amp; Biology Education")

# total_model <-glm.nb(is.referenced.by.count~ da_factor + log(age.in.months) + container.title + 
#                        + container.title*da_factor + log(age.in.months)*da_factor + container.title*log(age.in.months) + 
#                        log(age.in.months)*da_factor*container.title, data = model_data, link = log)


nsd_yes_10percent <- nsd_yes_metadata %>% 
  slice_sample(., prop = .1, weight_by = container.title)

#start 11:24 = 10% of data 
#relative formula = Y ~ data_avl + age + data_avl*age + (1 +data_avl + age + data_avl*age|journal) 
ten_percent_glmer <- glmer.nb(formula = is.referenced.by.count ~ da_factor + age.in.months + da_factor*age.in.months + 
                                (1+da_factor + age.in.months + da_factor*age.in.months|container.title), 
                              data = nsd_yes_10percent)

#how do we plot the residuals for this??
     
      
plot(ten_percent_glmer)
plot_model(ten_percent_glmer, type = "pred", terms = c("da_factor", "age.in.months[12,60,84]"), 
           bias_correction = FALSE)
ggsave("~/Documents/Schloss/Colovas_Data_Accessibility/Figures/glmer_10_pred.png")
residuals(ten_percent_glmer)

# residuals <-
  residuals(ten_percent_glmer) %>%  tibble(residual = .) %>%  
  ggplot(aes(x = residual)) + 
  geom_histogram(linewidth = 0.2, color = "white", bins = 100) +
  ggtitle("Residuals Plotted for 10% of data glmer.nb") 
  ggsave("~/Documents/Schloss/Colovas_Data_Accessibility/Figures/glmer_10_residuals.png")

  

   
# #let's try the other formula 4:24 -not done at 4:49 done at 4:52
# #y ~ data_avl + age + data_avl*age + (1+data_avl|journal) +
# #(0+age|journal) + (0+data_avl*age|journal)
# 
# ten_percent_glmer_2 <- glmer.nb(formula = is.referenced.by.count ~ da_factor + age.in.months + da_factor*age.in.months + 
#                                 (1 + da_factor|container.title) + (0 +age.in.months|container.title)  +
#                                 (0+ da_factor*age.in.months|container.title), 
#                               data = nsd_yes_10percent)
# 
# plot_model(ten_percent_glmer_2, type = "pred", terms = c("da_factor", "age.in.months[12,60,84]"), 
#            bias_correction = FALSE)


#for the full data - going to take over an hour 
#started around 11:40am
# should i be worried about the maximum umber of function evaluations exceeded?
# can add glmerControl(optCtrl = list(maxfun = 1e6))
#model fails to converge 
# large eigenvalue
full_glmer <- glmer.nb(formula = is.referenced.by.count ~ da_factor + age.in.months + da_factor*age.in.months + 
                                (1+da_factor + age.in.months + da_factor*age.in.months|container.title), 
                              data = nsd_yes_metadata)
saveRDS(full_glmer, file = "~/Documents/Schloss/Colovas_Data_Accessibility/Data/glm/full_glmer.RDS")

plot_model(full_glmer, type = "pred", terms = c("da_factor", "age.in.months[12,60,84]"), 
           bias_correction = FALSE)
ggsave("~/Documents/Schloss/Colovas_Data_Accessibility/Figures/glmer_full_pred.png")

residuals(full_glmer) %>%  tibble(residual = .) %>%  
  ggplot(aes(x = residual)) + 
  geom_histogram(linewidth = 0.2, color = "white", bins = 100) +
  ggtitle("Residuals Plotted for all data using glmer.nb") 
ggsave("~/Documents/Schloss/Colovas_Data_Accessibility/Figures/glmer_all_residuals.png")

simulation_full <- simulateResiduals(fittedModel = full_glmer, plot = F)
residuals(simulation_full) %>%  tibble(residual = .) %>%  
  ggplot(aes(x = residual)) + 
  geom_histogram(linewidth = 0.2, color = "white", bins = 100) +
  ggtitle("Residuals Plotted for all data using glmer.nb and DHARMa") 
ggsave("~/Documents/Schloss/Colovas_Data_Accessibility/Figures/glmer_all_residuals_dharma.png")

plot(simulation_full, sub = "Simulation plotted for all data using glmer.nb") %>% 
  save.image(., file = "~/Documents/Schloss/Colovas_Data_Accessibility/Figures/glmer_all_residuals_dharma_comboplot.png")

#deltamethod 

summary(full_glmer)
#12 months mbio yes/no
yes_12_mbio <- predict(full_glmer, newdata=data.frame(da_factor = "Yes", age.in.months = 12, container.title = "mBio"), type="response")
no_12_mbio <- predict(full_glmer, newdata=data.frame(da_factor = "No", age.in.months = 12, container.title = "mBio"), type="response")

yes_60_mbio <-  predict(full_glmer, newdata=data.frame(da_factor = "Yes", age.in.months = 60, container.title = "mBio"), type="response")
no_60_mbio <- predict(full_glmer, newdata=data.frame(da_factor = "No", age.in.months = 60, container.title = "mBio"), type="response")

yes_12_mbio/no_12_mbio
yes_60_mbio/no_60_mbio

# b0 <- 
  coef(full_glmer)[1]
b1 <- coef(full_glmer)[[2]]

deltamethod( ~ (1 + exp(-x1 - yes_60_mbio*x2))/(1 + exp(-x1 - no_60_mbio*x2)), c(b0, b1), vcov(full_glmer))

# 10 percent glmer with log age.in.months #245
ten_percent_glmer_log <- glmer.nb(formula = is.referenced.by.count ~ da_factor + log(age.in.months) + da_factor*log(age.in.months) + 
                                (1+da_factor + log(age.in.months) + da_factor*log(age.in.months)|container.title), 
                              data = nsd_yes_10percent)

simulation_log <- simulateResiduals(fittedModel = ten_percent_glmer_log, plot = F)
plot_model(ten_percent_glmer_log, type = "pred", terms = c("da_factor", "age.in.months[12,60,84]"), 
           bias_correction = FALSE)



residuals(simulation_log) %>%  tibble(residual = .) %>%  
  ggplot(aes(x = residual)) + 
  geom_histogram(linewidth = 0.2, color = "white", bins = 100) +
  ggtitle("Residuals Plotted for all data using 10% glmer.nb\nand log(age.in.months)") 
ggsave("~/Documents/Schloss/Colovas_Data_Accessibility/Figures/glmer_10_log_residuals.png")

 plot(simulation_log, sub = "10% data, glmer.nb (mixed model) log(age.in.months)") #%>% 
#   save.image(., file = "~/Documents/Schloss/Colovas_Data_Accessibility/Figures/glmer_mixed_10_log_dharma_comboplot.png")

plot_model(ten_percent_glmer_log, type = "pred", terms = c("da_factor", "age.in.months[12,60,84]"), 
           bias_correction = FALSE)

## log all data
full_glmer_log <- glmer.nb(formula = is.referenced.by.count ~ da_factor + log(age.in.months) + da_factor*log(age.in.months) + 
                         (1+da_factor + log(age.in.months) + da_factor*log(age.in.months)|container.title), 
                       data = nsd_yes_metadata)
saveRDS(full_glmer_log, file = "~/Documents/Schloss/Colovas_Data_Accessibility/Data/glm/full_glmer_log.RDS")
simulation_log_full <- simulateResiduals(fittedModel = full_glmer_log, plot = F)
plot(simulation_log_full, sub = "all data, glmer.nb (mixed model) log(age.in.months)") 

residuals(simulation_log_full) %>%  tibble(residual = .) %>%  
  ggplot(aes(x = residual)) + 
  geom_histogram(linewidth = 0.2, color = "white", bins = 100) +
  ggtitle("Residuals Plotted for all data using glmer.nb\nand log(age.in.months)") 
ggsave("~/Documents/Schloss/Colovas_Data_Accessibility/Figures/glmer_full_log_residuals.png")
