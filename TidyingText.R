# tokenizing and tidying text

#import correct packages
library(tidyverse)
library(tidytext)

#import example text from files test1_textscraping.txt and test2_textscraping.txt 

text1 <- as.tibble(readLines("test1_textscraping.txt"))
text2 <- as.tibble(readLines("test2_textscraping.txt"))

#unnest tokens into new data frame 
text1_tokens <- unnest_tokens(text1, text1_tokens, value) #%>% anti_join(stop_words)
text2_tokens <- unnest_tokens(text2, text2_tokens, value)

text1_tokens <- anti_join(text1_tokens, stop_words, copy = TRUE)
