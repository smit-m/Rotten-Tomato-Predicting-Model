#####################################################

# Get the lookup tables for popularity 

#install.packages("stringr")
#install.packages("splitstackshape")
#install.packages("reshape2")
#install.packages("dplyr")
library(splitstackshape)
library(reshape2)
library(stringr)
library(dplyr)

# Importing
rottom <- read.csv("test_2018-04-22_02-55-10.txt", sep = "\t", stringsAsFactors = FALSE) 

# Extracting year
rottom$Yr <- str_sub(rottom$In_Theaters_date, -2, -1)
rt <- rottom[rottom$Yr != "ne", ]
rt$Year <- ifelse(as.integer(rt$Yr) <= 18, paste0("20",rt$Yr), paste0("19", rt$Yr))
rt$ReleaseDate <- paste(str_sub(rt$In_Theaters_date, 1, -4), rt$Year, sep = "-")


#Creating copies of the main dataset
I0_cast_pop <- rt[, c(1, 15, 2, 3, 21, 22)] # FIRST CHANGE HERE: 15 to Directers, Writters
I0_direct_pop <- rt[, c(1, 7, 2, 3, 21, 22)]
I0_write_pop <- rt[, c(1, 8, 2, 3, 21, 22)]

#Reshape the dataframe
I1_temp11 <- cSplit(I0_cast_pop, 'Cast', sep=",", type.convert=FALSE)
I1_temp12 <- melt(I1_temp11, variable.name = "Cast", id.vars = c("Movie_name", "Critics_Score", "Audience_Score", "Year", "ReleaseDate")) # CHANGE Cast to D, W, add BO
I1_temp13 <- I1_temp12[!is.na(I1_temp12$value), ]

I1_temp21 <- cSplit(I0_direct_pop, 'Directed_By', sep=",", type.convert=FALSE)
I1_temp22 <- melt(I1_temp21, variable.name = "Directed_By", id.vars = c("Movie_name", "Critics_Score", "Audience_Score", "Year", "ReleaseDate"))
I1_temp23 <- I1_temp22[!is.na(I1_temp22$value), ]

I1_temp31 <- cSplit(I0_write_pop, 'Written_By', sep=",", type.convert=FALSE)
I1_temp32 <- melt(I1_temp31, variable.name = "Written_By", id.vars = c("Movie_name", "Critics_Score", "Audience_Score", "Year", "ReleaseDate"))
I1_temp33 <- I1_temp32[!is.na(I1_temp32$value), ]

I2_castmem <- I1_temp13[, -6]
I2_directmem <- I1_temp23[, -6]
I2_writemem <- I1_temp33[, -6]

I2_castmem$Year <- as.integer(I2_castmem$Year)
I2_castmem$Audience_Score <- as.integer(I2_castmem$Audience_Score)
I2_castmem$Critics_Score <- as.integer(I2_castmem$Critics_Score)

I2_directmem$Year <- as.integer(I2_directmem$Year)
I2_directmem$Audience_Score <- as.integer(I2_directmem$Audience_Score)
I2_directmem$Critics_Score <- as.integer(I2_directmem$Critics_Score)

I2_writemem$Year <- as.integer(I2_writemem$Year)
I2_writemem$Audience_Score <- as.integer(I2_writemem$Audience_Score)
I2_writemem$Critics_Score <- as.integer(I2_writemem$Critics_Score)

names(I2_castmem) <- c("Movie", "Critics_Score", "Audience_Score", "Year", "ReleaseDate", "Actor")
names(I2_directmem) <- c("Movie", "Critics_Score", "Audience_Score", "Year", "ReleaseDate", "Director")
names(I2_writemem) <- c("Movie", "Critics_Score", "Audience_Score", "Year", "ReleaseDate", "Writter")

I2_castmem <- I2_castmem[complete.cases(I2_castmem), ]
I2_directmem <- I2_directmem[complete.cases(I2_directmem), ]
I2_writemem <- I2_writemem[complete.cases(I2_writemem), ]

#Calculations
d1 <- I2_castmem %>% arrange(Actor, Year) %>% mutate(Avg1 = cummean(Audience_Score)) %>% mutate(Avg2 = cummean(Critics_Score)) %>% select(Actor, Year, Avg1, Avg2) %>% group_by(Actor, Year) %>% summarise(AvgAS = last(Avg1), AvgCS = last(Avg2))
d2 <- I2_directmem %>% arrange(Director, Year) %>% mutate(Avg1 = cummean(Audience_Score)) %>% mutate(Avg2 = cummean(Critics_Score)) %>% select(Director, Year, Avg1, Avg2) %>% group_by(Director, Year) %>% summarise(AvgAS = last(Avg1), AvgCS = last(Avg2))
d3 <- I2_writemem %>% arrange(Writter, Year) %>% mutate(Avg1 = cummean(Audience_Score)) %>% mutate(Avg2 = cummean(Critics_Score)) %>% select(Writter, Year, Avg1, Avg2) %>% group_by(Writter, Year) %>% summarise(AvgAS = last(Avg1), AvgCS = last(Avg2))

write.table(d1, "Cast.txt", sep="\t", row.names = FALSE)
write.table(d2, "Directors.txt", sep="\t", row.names = FALSE)
write.table(d3, "Writers.txt", sep="\t", row.names = FALSE)

rm(list=ls())
