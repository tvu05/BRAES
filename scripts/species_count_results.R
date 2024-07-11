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
# bodyRes<- data.frame(NameSpecies = character(), Count = integer())
# bodyRes <- rbind(bodyRes, NameSpecies = xlSpe$Species1[1], Count = 1)
# bodyRes <- rbind(bodyRes, NameSpecies = "hello", Count = 43)



bodyRes <- data.frame(NameSpecies = character(), Count = integer(), stringsAsFactors = FALSE)
# bodyRes <- rbind(bodyRes, data.frame(NameSpecies = xlSpe$Species1[1], Count = 1, stringsAsFactors = FALSE))
# bodyRes <- rbind(bodyRes, data.frame(NameSpecies = "hello", Count = 43, stringsAsFactors = FALSE))
# print(bodyRes)



test <- xlSpe$Species1[1:5]
test

for (i in 1:length(birdName)){
  articleCount <- 0 
  #print(birdName[i])
  search <- paste0(url,selectedKeys,"&", abstSearch,birdName[i], "%20AND%20", roost)
  #print(search)
  request <- httr2::request(search)
  req_dry_run(request)
  Sys.sleep(0.15) #pasuing in seconds #use to respect OpenAlex request limit 
  resp <-req_perform(request)
  body <- fromJSON(rawToChar(resp$body))
  literature <- body$results
  litType <- literature$type
  
  resultsCount <- body$meta$count
  species <- xlSpe$Species1[i]
  print(species)


  if(resultsCount == 0){
    #species <- species
    articleCount <- 0
    bodyRes <- rbind(bodyRes, data.frame(NameSpecies = species, Count = articleCount, stringsAsFactors = FALSE))

  }else if(resultsCount <= 25){
    #species <- species
    
    for(j in 1:length(litType)){
      if (litType[j] == "article" | litType[j] == "review"){
        bodyRes <- unique(bodyRes)
        articleCount <- articleCount + 1
        bodyRes <- rbind(bodyRes, data.frame(NameSpecies = species, Count = articleCount, stringsAsFactors = FALSE))
        #print count into excel sheet column 
      }
    }
    
  }else{  #more situations where results is greater than 25 
    #species <- species
    per_page <- body$meta$per_page
    totalNumPages <- ceiling(restultsCount/per_page)
    
    for (j in totalNumPages){ 
      for(k in 1:length(litType)){
        if (litType[k] == "article" | litType[k] == "review"){
          #bodyRes<- rbind(bodyRes, literature)
          bodyRes <- unique(bodyRes)
          articleCount <- articleCount + 1
          bodyRes <- rbind(bodyRes, data.frame(NameSpecies = species, Count = articleCount, stringsAsFactors = FALSE))
          #print count into excel sheet column 
        }
      } 
    }
  }
  
  #cleanup function 
  rm(list = c("resp", "body", "literature", "litType", "request", "search"))
}

#problem: bodyRes dataframe is not recording all the species name. only seems to be recording one species and they have 
#different count...? I need to record firs five species and the count of relevant articles. 

#update
