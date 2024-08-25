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


#species & genus level 
# numChar, numRef, numWords
# find wiki articles w/ 1000, 2000 characters