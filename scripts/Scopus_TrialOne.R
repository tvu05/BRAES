#Author: Thien-Nhi Vu 
#Date Created: 7/21/24

# Sample working script that queries Scopus API
# for a list of bird names and associated roost terms
# and returns a count of the number of pieces of literature
# on that species.

library(httr2)
library(jsonlite)
library(readxl)

###
# LOAD THE DATA
###

#fix warning with read_xls argument to have a blank space and NA
xlSpe <- read_xlsx("data/Chapter_2_PhD_data_final.xlsx",
                   sheet= "Core Land birds",
                   na = c("", " ", "NA"))

# let's drop unnecessary data at the outset
speciesList <- xlSpe[,"Species1", drop = TRUE]
rm(xlSpe)
# replace spaces with encoding
speciesList <- gsub(" ", "%20",speciesList)
# subset the data for testing
# DELETE WHEN TESTING WORKS
speciesListTest <- speciesList[1:40]


###
# BUILD THE QUERY PARAMETERS
###

# base elements
url <- "https://api.elsevier.com/content/search/scopus?"
query_TAK <- "query=TITLE-ABS-KEY('"
abstSearch <- "filter=title_and_abstract.search:"
# roost terms
roostTerms <- "'%20AND%20(roost%20OR%20roosting%20OR%20communally%20OR%20communal))&apiKey="
#how do include my API key without writing it in my script
apiKey <- "API"

build_Search <- function(url, query_TAK, birdName, roostTerms, apiKey){
  search <- paste0(url, query_TAK, "Accipiter%20albogularis",roostTerms, apiKey)
  request <- httr2::request(search)
  resp <-req_perform(request)
  body <- fromJSON(rawToChar(resp$body))
  countResults <- body$`search-results`$`opensearch:totalResults`
  return(countResults)
}


birdName <- xlSpe[1:4,1, drop = T]   #drop(boolean) drops table: left w/ only a vector 
birdName <- gsub(" ", "%20",birdName)

for(i in length(birdName)){
  print(birdName)
}

