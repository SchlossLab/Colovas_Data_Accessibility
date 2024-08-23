# DOI gathering with rscopus
# r scopus is a hater 20240823
#
#
#library statements
library(tidyverse)
library(rscopus)

key <- "24a07ed9eea613f729d6469a816966c"

set_api_key(key)
have_api_key(key)
get_api_key(key)

if (have_api_key()) {
auth <- elsevier_authenticate(key, verbose = TRUE)
}

rscopus::is_elsevier_guest()

#example code from rscopus pkg

if (rscopus::is_elsevier_authorized()) {
  res = author_df(last_name = "Muschelli", first_name = "John", verbose = FALSE, general = FALSE)
  names(res)
  head(res[, c("title", "journal", "description")])
  unique(res$au_id)
  unique(as.character(res$affilname_1))
  
  all_dat = author_data(last_name = "Muschelli", 
                        first_name = "John", verbose = FALSE, general = TRUE)
  res2 = all_dat$df
  res2 = res2 %>% 
    rename(journal = `prism:publicationName`,
           title = `dc:title`,
           description = `dc:description`)
  head(res[, c("title", "journal", "description")])
}
