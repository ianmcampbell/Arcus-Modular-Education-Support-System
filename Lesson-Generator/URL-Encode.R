# Contains functions for encoding and decoding usernames and lesson lists
library(RCurl)

# Function for converting whole numbers to URL safe Base62
toBase <- function(num, base=62) {
  bv <- c(seq(0,9),letters,LETTERS)
  r <- num %% base
  res <- bv[r+1]
  q <- floor(num/base)
  while (q > 0L) {
    r <- q %% base
    q  <- floor(q/base)
    res <- paste(bv[r+1],res,sep='')
  }
  res
}

# Function for converting Base 62 whole numbers back to base 10
to10 <- function(num, base=62) {
  bv <- c(seq(0,9),letters,LETTERS)
  vb <- list()
  for (i in 1:length(bv)) vb[[bv[i]]] <- i
  num <- strsplit(num,'')[[1]]
  res <- vb[[num[1]]]-1
  if (length(num) > 1)
    for (i in 2:length(num)) res <- base * res + (vb[[num[i]]]-1)
  res
}

#Function to decode URL safe Base64 strings
urlsafebase64decode <- function(x, ...) {
  RCurl::base64(gsub("_","/", gsub("-","+",gsub("~","=",x,fixed=TRUE),fixed=TRUE),fixed=TRUE), encode=FALSE, ...)
}

#Function to encode URL safe Base64 strings
urlsafebase64encode <- function(x, ...) {
  gsub("+","-",gsub("/","_",gsub("=","~",RCurl::base64(x,encode =TRUE), fixed = TRUE), fixed = TRUE), fixed = TRUE)
}

#Function to encode a vector of lesson keys to a URL ready string
encode_lessons <- function(lesson_list){
  lesson_list <- split(as.character(lesson_list), ceiling(seq_along(lesson_list)/5))
  lesson_list_split <- sapply(lesson_list,function(x){as.numeric(paste(x,collapse = ""))})
  encoded_list <- sapply(lesson_list_split,toBase)
  url_ready_list <- paste(encoded_list,collapse="")
  url_ready_list
}

#Decodes a URL string to a vector of lesson keys
decode_lessons <- function(url_string){
  url_split <- strsplit(gsub("([[:alnum:]]{8})", "\\1 ", url_string), " ")[[1]]
  decoded_string <- paste(as.character(sapply(url_split,to10)),collapse = "")
  decoded_lesson_list <- as.numeric(strsplit(gsub("([[:alnum:]]{3})", "\\1 ", decoded_string), " ")[[1]])
  decoded_lesson_list
}
