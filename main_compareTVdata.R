

rm(list = ls())
options(scipen = 999)


# Point to the local R-Portable library
.libPaths()


# # install packages
# install.packages("shinydashboard")
# install.packages("shinyDirButton")
# install.packages("naniar")
# install.packages("data.table")
# install.packages("ggplot2")
# install.packages("shiny")
# install.packages("shinyBS")
# install.packages("plotly")
# install.packages("tidyverse")
# install.packages("devtools")
#install.packages("formattable")
# 
# install.packages("RColorBrewer")
# install.packages("mltools")
# 
# install.packages("ggcorrplot")
# install.packages("compareDF")
# install.packages("htmlTable")
# install.packages("htmltools")
# install.packages("arsenal")
# install.packages("dplyr")
# install.packages("knitr")
# install.packages("shinyFiles")
# 
# install.packages("doParallel")
# install.packages("foreach")
# 
# detach("package:rmarkdown", unload = TRUE)
# install.packages("htmltools", dependencies=TRUE)
# 
# # Load shiny libraries
# library(shinydashboard)
# library(shinyDirButton)
# library(naniar)
# library(data.table)
# library(ggplot2)
# library(shiny)
# library(shinyBS)
# library(plotly)
# library(tidyverse)
# library(devtools)
# library(RColorBrewer)
# library(mltools)
#library(formattable)
# 
# library(ggcorrplot)
# library(compareDF)
# library(htmlTable)
# library(arsenal)
# library(dplyr)
# library(knitr)
# library(shinyFiles)
# 
# library(doParallel)
# library(foreach)


#############################################
##  STEP 1: Data cleansing                 ##
#############################################


## Get data ---------------------------------
path = "C:/Users/Laura/OneDrive/Documentos/LAURA/KNOWLEDGE/MASTER/UOC/13 - Visualització de dades/Practica2/1 - Enunciat/Final_dataset_used"
setwd(path)


amazon.rawdata <- data.table::fread(paste0(path, "/amazon_prime_titles.csv"))
netflix.rawdata <- data.table::fread(paste0(path, "/netflix_titles.csv"))
disney.rawdata <- data.table::fread(paste0(path, "/disney_plus_titles.csv"))
rotten.tomatoes.rawdata <- data.table::fread(paste0(path, "/MoviesOnStreamingPlatforms.csv"))

## Add streaming platforms --------------------
amazon.rawdata[,streaming_platform := "Amazon Prime"]
netflix.rawdata[,streaming_platform := "Netflix"]
disney.rawdata[,streaming_platform := "Disney Plus"]


# Combine all platforms data in one 
data <- rbind(amazon.rawdata, netflix.rawdata)

data <- data.table::copy(rbind(data, disney.rawdata)) 

data[, show_id:= NULL]


## Clean platforms data -----------------------
date_cols <- "date_added"
data.table::setDT(data)[, (date_cols) := lapply(.SD, anytime::anydate), .SDcols = date_cols]

data[, year_added := lubridate::year(date_added)]
data[(is.na(year_added) & release_year == 2021), year_added := 2021]
data[, speed_introduction := year_added - release_year]



# Adhoc mistakes
data[title == "Louis C.K. 2017", `:=`(rating = NA, duration = "74 min")]
data[title == "Louis C.K.: Hilarious", `:=`(rating = NA, duration = "84 min")]
data[title == "Louis C.K.: Live at the Comedy Store", `:=`(rating = NA, duration = "66 min")]


# Self production
data[, is_self_production := ifelse(lubridate::year(date_added) == release_year, 1, 0)]

# Duration
data[, c("duration", "duration_unit") := data.table::tstrsplit(duration, " ", fixed=TRUE)]
data[,duration := as.numeric(duration)]

# Rating
data[rating %in% c("", "UNRATED", "NOT_RATE", "NR", "UR", "TV-NR"), rating := NA]
data[rating %in% c("ALL", "ALL_AGES", "TV-Y", "TV-G", "G"), rating := "All ages"]
data[rating %in% c("TV-Y7", "TV-Y7-FV"), rating := "7+"]
data[rating %in% c("TV-PG", "PG-13", "PG"), rating := "13+"]
data[rating %in% c("TV-14"), rating := "14+"]
data[rating %in% c("16", "AGES_16_"), rating := "16+"]
data[rating %in% c("NC-17", "TV-MA"), rating := "17+"]
data[rating %in% c("AGES_18_", "R" ), rating := "18+"]


# Change names
data.table::setnames(data, "country", "production_country")

# Add country where these movies/shows are available for those platforms
data[1:10000, country := "Spain, Italy"]
data[10001:19925, country := "Spain, United States"]


# Create monthly price column
data[streaming_platform == "Amazon Prime", price := 4.99]
data[streaming_platform == "Disney Plus", price := 8.99]
data[streaming_platform == "Netflix", price := 7.99]

## Clean rotten tomatoes data -----------------
rotten.tomatoes.rawdata[, c("rotten1", "rotten2") := data.table::tstrsplit(`Rotten Tomatoes`, "/", fixed=TRUE)]
rotten.tomatoes <- data.table::copy(rotten.tomatoes.rawdata[, rotten1 := as.numeric(rotten1)])
rotten.tomatoes <- data.table::copy(rotten.tomatoes[, rotten2 := as.numeric(rotten2)])
rotten.tomatoes <- data.table::copy(rotten.tomatoes[, rotten_tomatoes := (rotten1/rotten2)*100])
rotten.tomatoes <- data.table::copy(rotten.tomatoes[,.(Title, rotten_tomatoes)])
data.table::setnames(rotten.tomatoes, "Title", "title")


## Add rotten tomatoes data -------------------
final.data <- merge(data, rotten.tomatoes, all.x = TRUE)


## Exemple sexe
final.data[title == "Christiane Amanpour: Sex & Love Around the World", listed_in := "Sex"]
final.data[title == "All About Sex", listed_in := "Sex"]



## Save data
saveRDS(final.data, file = paste("final_data.rds"))


##############################################
##        STEP 2. RUN SHINY APPLICATION     ##
##############################################

# Check the report in the below visualization tool
RunTVComparisonShinyApp()

