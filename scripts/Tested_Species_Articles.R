####
# Created: 2024-07-09
# Updated: 2024-07-11
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
# install.packages("lubridate")
library(httr2)
library(jsonlite)
library(readxl)
# install.packages("knitr") 
# library(knitr)
# library(lubridate)  #use for date & time

# search_counter <- 0
# start_time <- Sys.time()

###
# LOAD THE DATA
###

# better to fix the warningings if possible
# if you pull up the documentation on read_xls, you'll
# see there's an argument to define missing values,
# the default is a blank cell, I've updated it to include
# cells with a space and the string NA
# suppressWarnings({
#   # read in the data
#   xlSpe <- read_xlsx("data/Chapter_2_PhD_data_final.xlsx",
#                      sheet= "Core Land birds")
# })

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
speciesListTest <- speciesList[1:20] # testing with the first 40 birds

###
# BUILD THE QUERY PARAMETERS
###

# base elements
url <- "https://api.openalex.org/works?"
selectedKeys <- "select=type"
abstSearch <- "filter=title_and_abstract.search:"
# roost terms
roostTerms <- "(roost%20OR%20roosting%20OR%20communally%20OR%20communal)"

###
# BUILD THE SEARCH FUNCTION
###
build_Search <- function(url, selectedKeys, abstSearch, birdName, roostTerms, pageNumber){
  search <- paste0(url,selectedKeys,"&", abstSearch, birdName, "%20AND%20", roostTerms, "&", "page=", pageNumber)
  request <- httr2::request(search)
  resp <-req_perform(request)
  body <- fromJSON(rawToChar(resp$body))
  return(body)
}

###
# BUILD THE EXECUTION FUNCTION
###
# data is a vector of species names
# delay is the throttle in seconds between queries
execute_search <- function(data, delay){
  #creating a counter to see if it exceeds the rate limit. 
  # Initialize counter and timestamp
  # Define the start of the counter
  requestCounter <- 0
  # Define the limit of the counter
  search_limit <- 100000
  # Define the start time
  startTime <- Sys.time()
  daysRun <- 0 # set day counter
  
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
      waitTime <- 86400 - elapsedTime
      cat(paste("Rate limit hit. Pausing for", waitTime, "seconds.\n"))
      cat(paste("I have been running for", daysRun, ".\n"))
      Sys.sleep(waitTime)
    } else {
      birdName <- data[i] # species to search for
      cat(paste("Looking up", gsub("%20", " ", birdName), "\n"))
      pageNumber <- 1 # starting page number
      results_per_page <- 25 # default results per page
      articleType <- "article|review|book-chapter" # what we're looking for
      #perform_search() # function counting the number of requests
      
      body <- build_Search(url, selectedKeys, abstSearch, birdName, roostTerms, pageNumber)
      
      # parse the results
      meta_count <- body$meta$count # first count the number of results
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
        for(i in 2:(returned_pages)){
          pageNumber <- i
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

###
# RUN THE EXECUTION FUNCTION
###

results <- execute_search(speciesListTest, 1)

df <- data.frame(Species = gsub("%20", " ", speciesListTest),
                      Results = results)

write.csv(df, "outputs/output.csv", row.names = FALSE)


# Function to simulate a search
# perform_search <- function() {
#   # Increment the counter
#   search_counter <- search_counter + 1
#   
#   if (search_counter > search_limit) {
#     elapsed_time <- Sys.time() - start_time
#     if (elapsed_time < 24 * 60 * 60) {
#       Sys.sleep(24 * 60 * 60 - as.numeric(elapsed_time))
#       search_counter <<- 1
#       start_time <<- Sys.time()
#     } else {
#       search_counter <<- 1
#       start_time <<- Sys.time()
#     }
#   }
# }







# NA warning fixed 
# 1 function implemented 
# Species testsed 
# attempted to make a counter to record number of runs & requests 
