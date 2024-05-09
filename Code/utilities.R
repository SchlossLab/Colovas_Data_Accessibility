# utilities.R
# script with commonly used functions across multiple R script files
#
#
# function to read and unserialize jsonfiles 
use_json <- function(jsonfile){
  json_data <- read_json(jsonfile)
  json_data <- unserializeJSON(json_data[[1]])
}

