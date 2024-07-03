#query OpenAlex API for every species + roosting terms 
#figure out if article/review >> if it is an article, how many count 
#associated w/ that search

#7/2/24 
#Thien-Nhi Vu 

#need to know species ran search for
#filter if an article 
#grab number results associated w/ that search
#create a counter in a for loop each time an article is added to new df
#counter complete, record in dataframe, count & species searched for

#Purpose: create df that recrods species + number of results 

library(httr2)
library(jsonlite)
library(readxl)

url <- "https://api.openalex.org/works?"  #base url

#id, doi, title display
selectedKeys <- "select=type"

#abstractSearch
abstSearch <- "filter=title_and_abstract.search:"

#roostingTerm
#will we add in the word behavio(u)r later on?? (UK and US spelling to remember!!)
roost <- "(roost%20OR%20roosting%20OR%20communally%20OR%20communal)"

speciesList <- "Cathartes%20aura"

#build our search 


#loops
#install.packages("readxl")
xlSpe <- read_xlsx("data/Chapter_2_PhD_data_final.xlsx",
                   sheet= "Core Land birds") 
#returning NA values --> handle them later 


birdName <- xlSpe[1:4,1, drop = T]   #drop(boolean) drops table: left w/ only a vector 
birdName <- gsub(" ", "%20",birdName)


#build three different searches 
#creates empty data frame 
bodyRes<- data.frame(NameSpecies = character(), Count = integer())



for (i in 1:length(birdName)){
  counter <- 0 
  #print(birdName[i])
  search <- paste0(url,selectedKeys,"&", abstSearch,birdName[i], "%20AND%20", roost)
  #print(search)
  request <- httr2::request(search)
  req_dry_run(request)
  Sys.sleep(1) #pasuing in seconds #use to respect OpenAlex request limit 
  resp <-req_perform(request)
  body <- fromJSON(rawToChar(resp$body))
  literature <- body$results
  litType <- literature$type
  
  resultsCount <- body$meta$count
  if(resultsCount == 0){
    species = species #xlSpe$Species1[i]
    articleCount <- 0
  }else if(resultsCount <= 25){
    species = species 
    counter <- 0
    articleCount <- for each resultsCount 
      if litType == article | review 
    counter <- counter + 1
  }else{  #more situations where results is greater than 25 
    species = species 
    counter <- 0 
    pages = pages 
    for each page{ 
      articleCount <- for each resultsCount 
      if litType == article | review 
      counter <- counter + 1  
      }
  }
  per_page <- body$meta$per_page
  totalNumPages <- ceiling(resultsCount/per_page)
  
  for(i in 1:length(litType)){
    if (litType[i] == "article" | litType[i] == "review"){
      bodyRes<- rbind(bodyRes, literature)
      bodyRes <- unique(bodyRes)
      counter <- counter + 1
      #print count into excel sheet column 
    }
  }
  #cleanup function 
  rm(list = c("resp", "body", "literature", "litType", "request", "search"))
}

# 1. for each species in a list
# 2. run a search for that species
# 3. if the result set is 0 >
#   4. record the species name and 0 to a df
# 5. else, create a counter and set it to 0
# 6. if the result set is 25 or less >
#   7. find out how many articles there are and record this to the counter and write this to the df
# 8. if the result is greater than 25 > 
#   9. find out how many pages there and for each page >
#   10. do line 4
# 11. exit the loop


#how to commit & push on gitbash 
# ls -a 
# git add *
#git commit -m "message to push" 

#I am testing on git desktop
