#20250113 - doi gathering with scopus using httr2
#need to paginate through the response pages after figuring out how many results we will have for each thing 
#how to concatenate them all i have no idea
#
#
#library statements 
library(tidyverse)
library(httr2)


#make tibble of ISSNs and journal names for 12 ASM journals 
issn <-  c("1098-6596", "1098-5336", "1098-5522", "1098-5530", "0095-1137", "1935-7885", 
           "1098-5514", "2150-7511", "2576-098X", "2165-0497", "2379-5042", "2379-5077") 

journal_name <- c("Antimicrobial Agents and Chemotherapy", "Applied and Envrionmental Microbiology",
                  "Infection and Immunity", "Journal of Bacteriology", "Journal of Clinical Microbiology", 
                  "Journal of Microbiology & Biology Education", "Journal of Virology", "mBio",
                  "Microbiology Resource Announcements", "Microbiology Spectrum", "mSphere", "mSystems" )
journal_acronym <- c("AAC", "AEM", "I&I", "JB", "JCB", "JMBE", "JV", "mBio", "MRA", "MS", "mSph", "mSys")

asm_journals <- tibble(journal_name, journal_acronym, issn)


# scopus API with 2x keys
#   scopus/elsevier 
scopus_key <- "f24a07ed9eea613f729d6469a816966c"
scopus_institutional_token <- "7c25e0e82b37408e45c8da604e824725"

# 20240912 - this works but i need to figure out what params to add to get what i need
#this one is generic 
scopus_req <- request("https://api.elsevier.com/content/abstract/citation-count?scopus_id=33646008552") %>%
    req_headers("X-ELS-APIKey" = scopus_key) %>%
    req_headers("X-ELS-Insttoken" = scopus_institutional_token)
    


#playing with the request to try and get an issn to work 
scopus_req <- request("http://api.elsevier.com/content/search/scopus?query=issn(1098-6596)&date(2000-2024)&cursor/@next&start=0&count=200&field=citedby-count,prism:doi,date") %>%
    req_headers("X-ELS-APIKey" = scopus_key) %>%
    req_headers("X-ELS-Insttoken" = scopus_institutional_token)


# #20250113 - this one works i just want to play with it 
# scopus_req <- request("http://api.elsevier.com/content/search/scopus?query=issn(1098-6596)&date(2000-2024)&cursor/@next&start=100&count=500&field=citedby-count,prism:doi,date") %>%
#     req_headers("X-ELS-APIKey" = scopus_key) %>%
#     req_headers("X-ELS-Insttoken" = scopus_institutional_token)


#this gives you the number of expected responses from the scopus response,
#even if you only get 25 at first
# i want to get the number of responses so that we can divide by 
# 200 and get the expected number of pages per journal
scopus_response <- req_perform(scopus_req) %>%
    resp_body_json(simplifyVector = TRUE) 

num_responses<- as.numeric(scopus_response$`search-results`$`opensearch:totalResults`)
num_pages <- (num_responses%/%200)+1

#can we create just a list of lists and 
# then unlist them? like page[n] and unlist page? 

as_tibble(scopus_response$`search-results`$entry)




#20250113 - things i still do not know 
# how to save and unserialize the json file in a way that gives me a table of values 
#this gives you a tibble of values 
as.tibble(scopus_response$`search-results`$entry) 

#okay gonna try and loop this 
#add number of responses and pages to the df

#20250113 - after talking to greg
# this approach will work 
# the journal issn is in the snakefile 
#need it to work for each journal independently 

#request for the journal to find out how many records and pages it is 
scopus_req <- request("http://api.elsevier.com/content/search/scopus?query=issn(1098-6596)&date(2000-2024)&field=citedby-count,prism:doi,date") %>%
    req_headers("X-ELS-APIKey" = scopus_key) %>%
    req_headers("X-ELS-Insttoken" = scopus_institutional_token)

scopus_response <- req_perform(scopus_req) %>%
    resp_body_json(simplifyVector = TRUE) 

num_responses<- as.numeric(scopus_response$`search-results`$`opensearch:totalResults`)
num_pages <- (num_responses%/%200)

#construcuor for the list
page_results <- vector(mode = "list", length = num_pages+1)
length(page_results)


for(i in 0:num_pages){

cursor<-i*200
request_url<-paste0("http://api.elsevier.com/content/search/scopus?query=issn(1098-6596)&date(2000-2024)&cursor/@next&start=", 
                cursor, "&count=200&field=citedby-count,prism:doi,date&mailto=jocolova@med.umich.edu")

scopus_req <- request(request_url) %>%
    req_headers("X-ELS-APIKey" = scopus_key) %>%
    req_headers("X-ELS-Insttoken" = scopus_institutional_token) %>%
    req_user_agent("jocolova@med.umich.edu") %>%
    req_throttle(rate = 50/60)

scopus_response <- req_perform(scopus_req) %>%
    resp_body_json(simplifyVector = TRUE) 

page_results[[i+1]]<-as_tibble(scopus_response$`search-results`$entry)

}
#20250115 - this does the right thing but 
#will only do up to 25 at a time and 
#i have no idea how/why so maybe i just need to chunk them diff

#20250113 - 
#this makes the right list 
#need them all as tibbles so that they don't unlist funny?
# would rather unnest than unlist
# i think i have initialized wrong?
#why do they give me an error if i try and do all the pages at once? 
