#' Cotains general functions for ETL.

# Attach library for docstrings
library(docstring)

# Extract from stooq.pl file.
read.stooq.asset.price <- function(file) {
  #' Reads asset closing prices from csv file downloaded from stooq.pl.
  #'
  #' Reads csv file from stooq.pl and returns closing prices of an asset.
  #' Also names vector position as dates.
  #'
  #' @param file character. The name of the stooq.pl file which the data are to be read from.
  #' @return numeric. A vector of closing prices of a given asset.
  # Read file and get closing prices.
  sq <- read.csv(file)
  closing.price <- sq$Zamkniecie
  # Name vector postions as dates.
  names(closing.price) <- sq$Data

  return(closing.price)
}
??read.stooq.asset.price
x<-read.stooq.asset.price("./data/input/Poland/tbsp_m.csv")
