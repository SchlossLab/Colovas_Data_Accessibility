# utilities.R
# script with commonly used functions across multiple R script files
#
#
# function to read and unserialize jsonfiles 
use_json <- function(jsonfile){
  json_data <- read_json(jsonfile)
  json_data <- unserializeJSON(json_data[[1]])
}


# 20240823 will need to load this into the other files that need it 
journals <- c("Antimicrobial Agents and Chemotherapy",
              "Applied and Environmental Microbiology",
              "Infection and Immunity",
              "Journal of Bacteriology",
              "Journal of Clinical Microbiology", 
              "Journal of Microbiology &amp; Biology Education",
              "Journal of Virology",
              "mBio",
              "Microbiology Resource Announcements", 
              "Microbiology Spectrum",
              "mSphere",
              "mSystems")
