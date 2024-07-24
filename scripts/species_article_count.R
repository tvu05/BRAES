####
# Created: 2024-07-09
# Updated: NA
# 
# Author: Mathew Vis-Dunbar
# 
# Description:
#   
# Sample working script that queries OpenAlex API
# for a list of bird names and associated roost terms
# and returns a count of the number of pieces of literature
# on that species.
####

# load libraries
library(httr2)
library(jsonlite)
library(readxl)

# base elements
url <- "https://api.openalex.org/works?"
selectedKeys <- "select=type"
abstSearch <- "filter=title_and_abstract.search:"

# roost terms
roostTerms <- "(roost%20OR%20roosting%20OR%20communally%20OR%20communal)"

# read in the data
xlSpe <- read_xlsx("data/Chapter_2_PhD_data_final.xlsx",
                           sheet= "Core Land birds")
# subset the data
speciesList <- xlSpe[1:4,1, drop = T] # testing with the first 40 birds
# replace spaces with encoding
speciesList <- gsub(" ", "%20",speciesList)

# prepare a vector to hold the count data
count_of_articles <- vector(mode = "numeric", length = length(speciesList))

# starting the loop...
for(i in 1:length(speciesList)){
  birdName <- speciesList[i] # species to search for
  print(birdName)
  pageNumber <- 1 # starting page number
  results_per_page <- 25 # default results per page
  articleType <- "article|review|book-chapter" # what we're looking for
  
  # build and run the search
  search <- paste0(url,selectedKeys,"&", abstSearch, birdName, "%20AND%20", roostTerms, "&", "page=", pageNumber)
  request <- httr2::request(search)
  resp <-req_perform(request)
  body <- fromJSON(rawToChar(resp$body))
  
  # parse the results
  meta_count <- body$meta$count # first count the number of results
  # then deal with tallying the count
  if(meta_count == 0){ # nothing is found
    returned_results <- 0
  } else if (meta_count <= results_per_page) { # something is found, but only one page of results is returned
    returned_results <- length(grep(articleType, x = body$results$type)) # look in the type vector for values that match the article types of interest
  } else { # something is found, and more than one page of results is returned
    returned_results <- length(grep(articleType, x = body$results$type)) # number of results on page 1
    print(returned_results)
    returned_pages <- ceiling(body$meta$count/results_per_page) # number of pages to cycle through
    for(i in 2:(returned_pages)){
      print("doing a loop")
      pageNumber <- i
      search <- search <- paste0(url,selectedKeys,"&", abstSearch, birdName, "%20AND%20", roostTerms, "&", "page=", pageNumber)
      request <- httr2::request(search)
      resp <-req_perform(request)
      body <- fromJSON(rawToChar(resp$body))
      results_on_page <- length(grep(articleType, x = body$results$type))
      print(results_on_page)
      returned_results <- returned_results + results_on_page # add each page of returned results together
      print(returned_results)
      # hang tight
      Sys.sleep(1)
    }
  }
  # update the count
  count_of_articles[i] <- returned_results
  # hang tight
  Sys.sleep(1)
}

wrap_up <- data.frame(Species = gsub("%20", " ", speciesList),
                      Results = count_of_articles)
