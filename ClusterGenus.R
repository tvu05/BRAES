library(stringr)
library(dplyr)
library(ggplot2)

data <- read.csv("data/subsetSpecies_200.csv")

data[c('genus', 'epithet')] <- str_split_fixed(data$SpeciesName, " ", 2)

genusData <- data %>% group_by(genus ) %>%
  summarise(count = n(),
            sum = mean(NumWords)) #mean, sum

data %>% group_by(genus ) %>%
  summarise(count = n(),
            sum = mean(NumWords)) %>% 
  ggplot(aes(x = sum)) +
  geom_bar()


summary(genusData$sum)

genusData <- genusData %>% mutate(groupedNumWords =
                                    case_when(sum <= 100 ~ 100,
                                              sum <= 200 ~ 200,
                                              sum <= 300 ~ 300,
                                              sum <= 400 ~ 400,
                                              sum <= 500 ~ 500,
                                              sum <= 600 ~ 600,
                                              sum <= 700 ~ 700,
                                              sum <= 800 ~ 800,
                                              sum <= 900 ~ 900,
                                              sum <= 1000 ~ 1000,
                                              .default = 1100))

ggplot(genusData, aes(x= groupedNumWords)) + 
  geom_bar()
#######

speciesData <- data %>% group_by(SpeciesName ) %>%
  summarise(count = n(),
            sum = mean(NumChar)) #mean, sum

data %>% group_by(SpeciesName ) %>%
  summarise(count = n(),
            sum = mean(NumChar)) %>% 
  ggplot(aes(x = sum)) +
  geom_bar()


summary(speciesData$sum)

speciesData <- speciesData %>% mutate(groupedNumChar =
                                    case_when(sum <= 500 ~ 500,
                                              sum <= 1000 ~ 1000,
                                              sum <= 1500 ~ 1500,
                                              sum <= 2000 ~ 2000,
                                              sum <= 2500 ~ 2500,
                                              sum <= 3000 ~ 3000,
                                              sum <= 3500 ~ 3500,
                                              sum <= 4000 ~ 4000,
                                              sum <= 4500 ~ 4500,
                                              sum <= 5000 ~ 5000,
                                              .default = 5550))

ggplot(speciesData, aes(x= groupedNumChar)) + 
  geom_bar()


########


ggplot(data, aes(x = NumWords)) + 
  geom_bar()

##### 
#this area is for numchar less than 5000 
sub5k <- subset(data, NumChar <= 5000)

ggplot(sub5k, aes(x = NumChar)) + 
  geom_bar()

set.seed(123)

test <- kmeans(sub5k$NumChar, 3)
test$cluster

hist(sub5k$NumChar[which(test$cluster == 1)], main = 
    "Hist of sub5k Cluster 3")
hist(sub5k$NumChar[which(test$cluster == 2)], main = 
       "Hist of sub5k Cluster 2")
hist(sub5k$NumChar[which(test$cluster == 3)], main = 
       "Hist of sub5k Cluster 1")



#Cluster 1 lacks information
#Cluster 2 is a gray area (up to Sandra to decide)
#Cluster 3 is enough information 
#Here are the list of species in cluster 1,2,3
#sub5k$SpeciesName[which(test$cluster == 1)]
#sub5k$SpeciesName[which(test$cluster == 2)]
#sub5k$SpeciesName[which(test$cluster == 3)]
#

#############
#this area is for numRef less than 10
sub10Ref <- subset(data, NumReferences <= 10)

ggplot(sub10Ref, aes(x = NumReferences)) + 
  geom_bar()

set.seed(123)


test <- kmeans(sub10Ref$NumReferences, 3)
test$cluster

hist(sub10Ref$NumReferences[which(test$cluster == 1)], main = 
       "Hist of sub10Ref Cluster 3")
hist(sub10Ref$NumReferences[which(test$cluster == 2)],  main = 
       "Hist of sub10Ref Cluster 2")
hist(sub10Ref$NumReferences[which(test$cluster == 3)], 
     main = "Hist of sub10Ref Cluster 1")

#Cluster 1 lacks information
#Cluster 2 is a gray area (up to Sandra to decide)
#Cluster 3 is enough information 
#Here are the list of species in cluster 1,2,3
#sub10Ref$NumReferences[which(test$cluster == 1)]
#sub10Ref$NumReferences[which(test$cluster == 2)]
#sub10Ref$NumReferencese[which(test$cluster == 3)]
#

##########
#this area is for numWords less than 1000
sub1kWord <- subset(data, NumWords <= 1000)

ggplot(sub1kWord, aes(x = NumWords)) + 
  geom_bar()

set.seed(123)

test <- kmeans(sub1kWord$NumWords, 3)
test$cluster

hist(sub1kWord$NumWords[which(test$cluster == 1)], main = 
       "Hist of sub1kWords Cluster 2")
hist(sub1kWord$NumWords[which(test$cluster == 2)],  main = 
       "Hist of sub1kWords Cluster 1")
hist(sub1kWord$NumWords[which(test$cluster == 3)], 
     main = "Hist of sub1kWords Cluster 3")

#Cluster 1 lacks information
#Cluster 2 is a gray area (up to Sandra to decide)
#Cluster 3 is enough information 
#Here are the list of species in cluster 1,2,3
#sub10Ref$NumReferences[which(test$cluster == 1)]
#sub10Ref$NumReferences[which(test$cluster == 2)]
#sub10Ref$NumReferencese[which(test$cluster == 3)]

#############
#test
#end 

sample <- subset(data, NumWords <= 1000 & NumChar <= 5000 & NumReferences <= 10)


#species & genus level 
# numChar, numRef, numWords
# find wiki articles w/ 1000, 2000 characters