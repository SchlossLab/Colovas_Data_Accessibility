# DOI gathering with rscopus
# r scopus is a hater 20240823
#
#
#library statements
library(tidyverse)
library(rscopus)

personal_key <- "f24a07ed9eea613f729d6469a816966c"
institutional_token <- "7c25e0e82b37408e45c8da604e824725"

set_api_key(personal_key)
have_api_key()

hdr <- inst_token_header(institutional_token)

get_api_key()
elsevier_authenticate(headers = hdr)

# token is from Scopus dev

res <- author_df(last_name = "Muschelli", first_name = "John", verbose = FALSE, general = FALSE, headers = hdr)

if (have_api_key()) {
auth <- elsevier_authenticate(personal_key, verbose = TRUE, headers = hdr)
}

rscopus::is_elsevier_guest()

#example code from rscopus 

# 20240905
# with error message stored in result 
#  "Requestor configuration settings insufficient for access to this resource."
# bruh
 if (!is.null(personal_key) & nchar(personal_key) > 0){
       result <- citation_retrieval(pii = c("S0140673616324102",
       "S0014579301033130"),
       verbose = FALSE)
       if (httr::status_code(result$get_statement) < 400) {
          res <- parse_citation_retrieval(result)
       }
    }

    
    set_api_key(NULL)

