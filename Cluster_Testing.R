#Generate toy data
A <- rnorm(1000)
B <- rnorm(1000, mean = 10)
C <- c(A,B)

hist(C)

#Cluster
test <- kmeans(C, 2)

test$cluster

#Inspect the results
hist(C[which(test$cluster == 1)])
hist(C[which(test$cluster == 2)])

