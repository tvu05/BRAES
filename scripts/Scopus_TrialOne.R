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
apiKey <- "api key" #my secret API Key ...shhhhh

build_Search <- function(url, query_TAK, birdName, roostTerms, apiKey){
  search <- paste0(url, query_TAK, birdName,roostTerms, apiKey)
  request <- httr2::request(search)
  resp <-req_perform(request)
  body <- fromJSON(rawToChar(resp$body))
  return(body)
}

execute_search <- function(data, delay){
  #creating a counter to see if it exceeds the rate limit. 
  # Initialize counter and timestamp
  # Define the start of the counter
  requestCounter <- 0
  # Define the limit of the counter
  search_limit <- 20000
  # Define the start time
  startTime <- Sys.time()
  daysRun <- 0 # set day counter
  waitTime <- 86400
  
  # prepare a vector to hold the count data
  count_of_articles <- vector(mode = "numeric", length = length(data))
  
  # starting the loop...
  for(i in 1:length(data)){
    requestCounter <- requestCounter + 1
    cat(paste("performing request number", requestCounter, "\n"))
    now <- Sys.time()
    elapsedTime <- now - startTime # total elapsed time
    twentyFourHourLimitCheck <- elapsedTime - daysRun * 86400  # resetable time
    cat(paste("I've been running for", round(elapsedTime), "seconds.\n"))
    # if we've hit our search limit in less than 24 hours
    # reset the counter and pause for the remainder of the
    # 24 hour period. Otherwise carry on...
    if(requestCounter == search_limit & twentyFourHourLimitCheck < 86400){
      requestCounter <- 0
      daysRun = daysRun + 1
      cat(paste("Rate limit hit. Pausing for 24 hours.\n"))
      cat(paste("I have been running for", daysRun, ".\n"))
      Sys.sleep(waitTime)
    } else {
      birdName <- data[i] # species to search for
      cat(paste("Looking up", gsub("%20", " ", birdName), "\n"))
      pageNumber <- 1 # starting page number
      results_per_page <- 25 # default results per page
      articleType <- "article|review|book-chapter" # what we're looking for
      # i don't think article type is an issue for scopus 
      #perform_search() # function counting the number of requests
      
      body <- build_Search(url, query_TAK, birdName, roostTerms, apiKey)
      
      # parse the results
      meta_count <- body$search-results$opensearch:totalResults # first count the number of results
      # then deal with tallying the count
      if(meta_count == 0){ # nothing is found
        returned_results <- 0
        cat("No results found.\n")
      } else if (meta_count <= results_per_page) { # something is found, but only one page of results is returned
        returned_results <- length(grep(articleType, x = body$results$type)) # look in the type vector for values that match the article types of interest
        cat(paste("1 page with", returned_results, "reulst(s) found.\n"))
      } else { # something is found, and more than one page of results is returned
        returned_results <- length(grep(articleType, x = body$results$type)) # number of results on page 1
        returned_pages <- ceiling(body$meta$count/results_per_page) # number of pages to cycle through
        for(j in 2:(returned_pages)){
          pageNumber <- j
          body <- build_Search(url, selectedKeys, abstSearch, birdName, roostTerms, pageNumber)
          results_on_page <- length(grep(articleType, x = body$results$type))
          returned_results <- returned_results + results_on_page # add each page of returned results together
          # hang tight
          Sys.sleep(delay)
        }
        cat(paste(returned_pages, "pages returned, with a total of", returned_results, "results found.\n"))
      }
      # update the count
      count_of_articles[i] <- returned_results
      # hang tight
      Sys.sleep(delay)
    }
  }
  return(count_of_articles)
}

