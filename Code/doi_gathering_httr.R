# need shebang for this file to be used with snakemake 
#
# query APIs with httr2
#
library(tidyverse)
library(httr2)

# API keys
#   crossref - does not require an API key
#   scopus/elsevier 
scopus_key <- "f24a07ed9eea613f729d6469a816966c"
scopus_institutional_token <- "7c25e0e82b37408e45c8da604e824725"
#   clarivate - 
clarivate_key <- "fba06c10b8832254cfed5f514778b86e9f888e51"

# start with creating a request
req <- request("https://r-project.org") %>%
# add headers to request
    req_headers("Accept" = "application/json") %>%
# add body makes it a POST
    req_body_json(list(x = 1, y = 2)) %>%
# retry if request fails 
    req_retry(max_tries = 5) 

# dry run 

req %>% req_dry_run()
resp <- req_perform(req)
resp

# let's try this for crossref since there's no API keys?


crossref_req <- request("https://api.crossref.org/journals/1098-6596/works?filter=from-pub-date:2000-01-01,until-pub-date:2024-08-31") 
    
  #  req_headers("Accept" = "application/json")

   # req_body_json(list(issn = "1098-6596")) 
crossref_req

response <- req_perform(crossref_req) %>%
    resp_body_json()


# scopus API with 2x keys
#   scopus/elsevier 
scopus_key <- "f24a07ed9eea613f729d6469a816966c"
scopus_institutional_token <- "7c25e0e82b37408e45c8da604e824725"

# 20240912 - this works but i need to figure out what params to add to get what i need
scopus_req <- request("https://api.elsevier.com/content/abstract/citation-count?scopus_id=33646008552") %>%
    req_headers("X-ELS-APIKey" = scopus_key) %>%
    req_headers("X-ELS-Insttoken" = scopus_institutional_token)
    


#playing with the request to try and get an issn to work 
scopus_req <- request("http://api.elsevier.com/content/search/scopus?query=issn(1098-6596)&date(2000-2024)&field=citedby-count,prism:doi,date") %>%
    req_headers("X-ELS-APIKey" = scopus_key) %>%
    req_headers("X-ELS-Insttoken" = scopus_institutional_token)


# #20250113 - this one works i just want to play with it 
# scopus_req <- request("http://api.elsevier.com/content/search/scopus?query=issn(1098-6596)&date(2000-2024)&cursor/@next&start=100&count=200&field=citedby-count,prism:doi,date") %>%
#     req_headers("X-ELS-APIKey" = scopus_key) %>%
#     req_headers("X-ELS-Insttoken" = scopus_institutional_token)

scopus_response <- req_perform(scopus_req) %>%
    resp_body_json(simplifyVector = TRUE) 

as.numeric(scopus_response$`search-results`$`opensearch:totalResults`)



# curl -v -H "X-ELS-APIKey:'f24a07ed9eea613f729d6469a816966c', X-ELS-Insttoken:'7c25e0e82b37408e45c8da604e824725'" 
# "https://api.elsevier.com/content/abstract/citation-count?scopus_id=33646008552"