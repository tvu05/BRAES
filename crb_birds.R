library(httr2)
library(jsonlite)
library(readxl)

url <- "https://api.openalex.org/works?"  #base url

#id, doi, title display
selectedKeys <- "select=id,doi,display_name,type"

#abstractSearch
abstSearch <- "filter=title_and_abstract.search:"

#roostingTerm
#will we add in the word behavio(u)r later on?? (UK and US spelling to remember!!)
roost <- "(roost%20OR%20roosting%20OR%20communally%20OR%20communal)"

speciesList <- "Cathartes%20aura"

#build our search 
search <- paste0(url,selectedKeys,"&", abstSearch,speciesList, "%20AND%20", roost)

#build a request 
#use hhtr2 package -> run the library package 
request <- httr2::request(search)
req_dry_run(request)

resp <-req_perform(request)
#extract body of request obj
#selecting body from resp
body <- fromJSON(rawToChar(resp$body))
#stores meta, results, & group_by
#body$meta
count <- body$meta$count
per_page <- body$meta$per_page
totalNumPages <- ceiling(count/per_page)

result <- body$result
result
colnames(result) #gives column names of objects 
# str(result$open_access) #-> this if we had this key, it would prob say T/F
# result$display_name[1] #retrieves the firs display name 


#loops
#install.packages("readxl")
xlSpe <- read_xlsx("Chapter_2_PhD_data_final.xlsx",
                          sheet= "Core Land birds") 
#returning NA values --> handle them later 

tryCatch({
  # This will cause a warning
  xlSpe <- read_xlsx("Chapter_2_PhD_data_final.xlsx",
                     sheet= "Core Land birds") 
}, 
warning = function(w) {
  message("A warning occurred: ", w$message)
},
finally = {
  message("This will run no matter what.")
})



birdName <- xlSpe[1:5,1, drop = T]   #drop(boolean) drops table: left w/ only a vector 
birdName <- gsub(" ", "%20",birdName)

for (i in birdName){ 
  print(i)
  }

for (i in 1:length(birdName)){
  print(birdName[i])
}

#build three different searches 
#creates empty data frame 
bodyRes<- data.frame(ID= character(),
                  DOI =character(), 
                 Display_Name=character(), 
                 Type = character())

for (i in 1:length(birdName)){
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
  for(i in 1:length(litType)){
    if (litType[i] == "article" | litType[i] == "review"){
      bodyRes<- rbind(bodyRes, literature)
      bodyRes
    }
  }
  
}






#literature or dataset object type?? is it in OA documentation 
#different type 
# - literature, dataset, article 
# how to build empty data frame w/i a data frame (OA parameter, body res is a data frame 
#        w/ its own data frames )
# use unique function to not have repeats of sources 
# review and article is ok type
#dataset is not ok 


