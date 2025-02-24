#see if they have the same citations or not
#
#
#library
library(tidyverse)

#load files
scopus <-read_csv("Data/scopus/all_scopus_citations.csv.gz")

crossref <-read_csv("Data/crossref/crossref_all_papers.csv.gz")

ncbi <-read_csv("Data/ncbi/ncbi_all_papers.csv.gz")

wos <-read_csv("Data/wos/wos_all_papers.csv.gz")

#send all to lowercase
ncbi$doi <- tolower(ncbi$doi)
scopus$`prism:doi` <-tolower(scopus$`prism:doi`)
crossref$doi<-tolower(crossref$doi)
wos$doi <- tolower(wos$doi)


#fix ncbi
ncbi <-ncbi %>%
filter(!is.na(doi))

dupes<- which(duplicated(ncbi$doi))
dupe_table <- rbind(ncbi[dupes,])
ncbi <-anti_join(ncbi, dupe_table)

#filter nas from scopus
scopus <-
scopus %>%
filter(!is.na(`prism:doi`))

#and remove pre-y2k for scopus 12927
scopus <-
    scopus %>%
    filter(!str_detect(`prism:doi`, "19\\d\\d$")) 

#filter na wos
wos <-
wos %>%
filter(!is.na(doi))

#unique on wos$doi and removing wos dupes

wos_dupes<- which(duplicated(wos$doi))
wos_dupe_table <- rbind(wos[wos_dupes,])
wos <-anti_join(wos, wos_dupe_table)


#final totals
crossref #147325
scopus #97250
ncbi #144333
wos #115167

#let's see if we can just do this as a single list - see line 137


# all_four<- inner_join(scopus, crossref, by = join_by(`prism:doi` == doi)) %>%
#     inner_join(., ncbi, by = join_by(`prism:doi` == doi)) %>%
#     inner_join(., wos, by = join_by(`prism:doi` == doi)) 


# #scopus, crossref, ncbi, subtract dead center
# scn<-inner_join(scopus, crossref, by = join_by(`prism:doi` == doi)) %>%
#     inner_join(., ncbi, by = join_by(`prism:doi` == doi)) %>%
#     anti_join(., all_four)

# #scopus, crossref, wos, subtract dead center
# scw<-inner_join(scopus, crossref, by = join_by(`prism:doi` == doi)) %>%
#     inner_join(., wos, by = join_by(`prism:doi` == doi)) %>%
#     anti_join(., all_four) 

# #wos, crossref, ncbi, subtract dead center
# ncw<-inner_join(ncbi, crossref, by = join_by(doi == doi)) %>%
#     inner_join(., wos, by = join_by(doi == doi)) %>%
#     anti_join(., all_four) 

# #scopus, wos, ncbi, subtract dead center
# snw<-inner_join(scopus, ncbi, by = join_by(`prism:doi` == doi)) %>%
#     inner_join(., wos, by = join_by(`prism:doi` == doi)) %>%
#     anti_join(., all_four) 

# scopus_and_crossref<-inner_join(scopus, crossref, by = join_by(`prism:doi` == doi)) %>%
#     anti_join(., all_three)



# scopus_and_ncbi<-inner_join(scopus, ncbi, by = join_by(`prism:doi` == doi)) %>%
#     anti_join(., all_three)


# crossref_and_ncbi<-inner_join(crossref, ncbi, by = join_by(doi == doi)) %>%
#     anti_join(., all_three, by = join_by(doi == `prism:doi`))

# any(duplicated(crossref_and_ncbi)) 
# which(is.na(crossref_and_ncbi$title)) 

# filter(crossref_and_ncbi, title.x != title.y) %>%
#     select(title.x, title.y) %>% 
#     view()

# ncbi_crossref <-inner_join(crossref, ncbi, by = join_by(doi == doi)) %>%
#     anti_join(., all_three, by = join_by(doi == `prism:doi`))



# scopus_only<-anti_join(scopus, crossref, by = join_by(`prism:doi` == doi)) %>%
#    anti_join(., ncbi, by = join_by(`prism:doi` == doi))

# crossref_only<-anti_join(crossref, scopus, by = join_by(doi == `prism:doi`)) %>%
#    anti_join(., ncbi, by = join_by(doi == doi))

# ncbi_only <- anti_join(ncbi, scopus, by = join_by(doi == `prism:doi`)) %>%
#    anti_join(., crossref, by = join_by(doi == doi))

# ncbi
# crossref
# scopus

# grep("retracted", ncbi$title, value = TRUE, ignore.case = TRUE) #9
# grep("withdrawn", ncbi$title, value = TRUE, ignore.case = TRUE) #7

# grep("retracted", crossref$title, value = TRUE, ignore.case = TRUE) #6
# grep("withdrawn", crossref$title, value = TRUE, ignore.case = TRUE) #0

# filter(crossref_only, is.referenced.by.count ==0)

#-----------using 1 list and filter statements-------------------------

scopus<-mutate(scopus, scopus_doi = `prism:doi`)
ncbi<-mutate(ncbi, ncbi_doi = doi)
crossref<-mutate(crossref, crossref_doi = doi)
wos<-mutate(wos, wos_doi = doi)


full_joined<- full_join(scopus, crossref, by = join_by(`prism:doi` == doi)) %>%
    full_join(., ncbi, by = join_by(`prism:doi` == doi)) %>%
    full_join(., wos, by = join_by(`prism:doi` == doi)) %>%
    select(ends_with("_doi"))

# full_joined <-full_join(scopus, crossref, by = join_by(`prism:doi` == doi)) %>%
#     full_join(., ncbi, by = join_by(`prism:doi` == doi)) %>% 
#     select(ends_with("_doi"))
   

#for venn diagram 
# A - crossref
# B - scopus 
# C - NCBI
# D - WOS

#crossref only - A
 A <- full_joined %>% 
    filter(!is.na(crossref_doi) & is.na(scopus_doi) & is.na(ncbi_doi) & is.na(wos_doi)) %>%
    nrow()

#scopus only - B
B<- full_joined %>% 
    filter(is.na(crossref_doi) & !is.na(scopus_doi) & is.na(ncbi_doi) & is.na(wos_doi)) %>% 
    nrow()

#ncbi only - C
C<-full_joined %>% 
    filter((is.na(crossref_doi) & is.na(scopus_doi) & !is.na(ncbi_doi) & is.na(wos_doi))) %>% 
    nrow()

#wos only - D
D <- full_joined %>% 
    filter((is.na(crossref_doi) & is.na(scopus_doi) & is.na(ncbi_doi) & !is.na(wos_doi))) %>% 
    nrow()

#crossref and scopus - AB
AB <-full_joined %>% 
    filter((!is.na(crossref_doi) & !is.na(scopus_doi) & is.na(ncbi_doi) & is.na(wos_doi))) %>% 
    nrow()

#crossref and ncbi - AC
AC<-full_joined %>% 
    filter((!is.na(crossref_doi) & is.na(scopus_doi) & !is.na(ncbi_doi) & is.na(wos_doi))) %>% 
    nrow()

#crossref and wos - AD
AD<-full_joined %>% 
    filter((!is.na(crossref_doi) & is.na(scopus_doi) & is.na(ncbi_doi) & !is.na(wos_doi))) %>% 
    nrow()

# scopus and ncbi - BC
BC<-full_joined %>% 
    filter((is.na(crossref_doi) & !is.na(scopus_doi) & !is.na(ncbi_doi) & is.na(wos_doi))) %>% 
    nrow()

# scopus and wos - BD
BD<- full_joined %>% 
    filter((is.na(crossref_doi) & !is.na(scopus_doi) & is.na(ncbi_doi) & !is.na(wos_doi))) %>% 
    nrow()

# ncbi and wos - CD
CD<-full_joined %>% 
    filter((is.na(crossref_doi) & is.na(scopus_doi) & !is.na(ncbi_doi) & !is.na(wos_doi))) %>% 
    nrow()


# crossref and scopus and ncbi - ABC
ABC<-full_joined %>% 
    filter((!is.na(crossref_doi) & !is.na(scopus_doi) & !is.na(ncbi_doi) & is.na(wos_doi))) %>% 
    nrow()

# crossref and scopus and wos - ABD
ABD<-full_joined %>% 
    filter((!is.na(crossref_doi) & !is.na(scopus_doi) & is.na(ncbi_doi) & !is.na(wos_doi))) %>% 
    nrow()

# scopus and ncbi and wos - BCD
BCD<-full_joined %>% 
    filter((is.na(crossref_doi) & !is.na(scopus_doi) & !is.na(ncbi_doi) & !is.na(wos_doi))) %>% 
    nrow()

# crossref and ncbi and wos - ACD
ACD<-full_joined %>% 
    filter((!is.na(crossref_doi) & is.na(scopus_doi) & !is.na(ncbi_doi) & !is.na(wos_doi))) %>% 
    nrow()


# All 4 - ABCD
ABCD<-full_joined %>% 
    filter(!is.na(ncbi_doi) & !is.na(scopus_doi) &  !is.na(wos_doi) & !is.na(crossref_doi)) %>% 
    nrow()

not_ABCD<-full_joined %>% 
    filter(is.na(ncbi_doi) & is.na(scopus_doi) &  is.na(wos_doi) & is.na(crossref_doi)) %>% 
    nrow()



#summing all parts
sumA<-sum(A, AB, AC, AD, ABC, ABD, ACD, ABCD)
sumB<-sum(B, AB, BC, BD, ABC, ABD, BCD, ABCD) #correct
sumC<-sum(C, AC, BC, CD, ABC, ACD, BCD, ABCD)
sumD<-sum(A, AD, BD, CD, ABD, BCD, ACD, ABCD)

sumA -nrow(crossref)


unique(crossref)

nrow(full_joined)

is.na(full_joined$scopus_doi) %>%
    count()
