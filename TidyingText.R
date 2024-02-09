# tokenizing and tidying text

#import correct packages
library(tidyverse)
library(tidytext)

#import example text from files test1_textscraping.txt and test2_textscraping.txt 
text1 <- as.tibble(readLines("test1_textscraping.txt"))
text2 <- as.tibble(readLines("test2_textscraping.txt"))

#unnest tokens into new data frame 
text1_tokens <- unnest_tokens(text1, text1_tokens, value)
text2_tokens <- unnest_tokens(text2, text2_tokens, value)

#alphabetize tokens in dataframes
text1_tokens_sorted <- arrange(text1_tokens, text1_tokens)
text2_tokens_sorted <- arrange(text2_tokens, text2_tokens)

#remove tokens with three or fewer characters
text1_tokens_sorted_filtered <- filter(text1_tokens_sorted, nchar(text1_tokens_sorted[[1]]) > 3)
text2_tokens_sorted_filtered <- filter(text2_tokens_sorted, nchar(text2_tokens_sorted[[1]]) > 3)

#antijoin with stop_words dataset from package tidytext
text1_stop <- anti_join(text1_tokens_sorted_filtered, stop_words, by = join_by(text1_tokens == word))
text2_stop <- anti_join(text2_tokens_sorted_filtered, stop_words, by = join_by(text2_tokens == word))

#count tokens
text1_counted <- text1_stop %>% unique() %>% mutate(frequency = table(text1_stop))
text2_counted <- text2_stop %>% unique() %>% mutate(frequency = table(text2_stop))



