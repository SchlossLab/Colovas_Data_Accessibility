
#negative binomial figures

#library statements
library(tidyverse)


#import data



#do the emmeans contrasts 

# Define the age values you want to examine (in months)
age_values <- seq(5, 120, 5) #c(12, 36, 60, 120)  # Adjust these as needed
# Get emmeans on the link scale for all combinations
emm <- emmeans(model,  ~ da_factor + age.in.months | container.title,
        at = list(age.in.months = age_values), CIs = TRUE,
        type = "response")
# Get pairwise comparisons (differences) between da_factor levels
differences <- contrast(
    emm, by = c("age.in.months", "container.title"),
    method = "revpairwise",
    ratios = TRUE, CIs = TRUE
)
# See the contrasts
# summary(differences)
# Plot the contrasts
# plot(differences, ratios = TRUE)

# Plot the contrasts
ratios_df <- as.data.frame(plot(differences, ratios = TRUE)$data)  %>% 
 filter(container.title != "Journal of Microbiology &amp; Biology Education" &
        container.title != "Genome Announcements" & 
        container.title != "Microbiology Resource Announcements")


ggplot(
    data = ratios_df,
    mapping = aes(x = age.in.months, y = the.emmean)
) +
   geom_hline(yintercept = 1.0, linetype = 2, linewidth = 0.25) + 
    geom_line() +
    geom_ribbon(
        mapping = aes(ymin = lcl, ymax = ucl),
        alpha = 0.3 # transparency of confidence intervals
    ) +
    facet_wrap(~ container.title, nrow = 2, 
               labeller = label_wrap_gen(width = 20)) +
    labs(x = 'Age in months', y = 'Ratio of daYes/daNo') +
    coord_cartesian(ylim = c(0.25, 2.5)) + 
    theme_classic() + 
    scale_x_continuous(breaks = seq(12, 120, 24))  

