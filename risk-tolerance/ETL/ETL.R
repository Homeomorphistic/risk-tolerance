#' Cotains general functions for ETL.

# Attach library for docstrings.
library(docstring)

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

returns.from.prices <- function(prices) {
  #' Obtain total returns from prices.
  #'
  #' @param prices numeric. A numeric vector of an asset's prices.
  #' @return numeric. A numeric vector of an asset's total returns.

  n <- length(prices)
  dates <- names(prices)
  # Previous price (p_n-1). Exlude last price from whole vector.
  previous <- prices[-n]
  # Present price (p_n). Exlude first price from whole vector.
  present <- prices[-1]
  # Calculate total return as r_n = p_n / p_n-1 - 1 (present over previous price).
  returns <- present/previous - 1
  # Name vector elements as period end dates (return after some period measured at this date).
  names(returns) <- dates[-1]

  return(returns)
}

format.to.percentage <- function(percent, n=length(percent)) {
  #' Formats percents to standard way of X.XX%
  #'
  #' @param numeric. A numeric vector o percents.
  #' @param n numeric. A numeric scalar indicating number of first terms to return.
  #'  If negative, return last n terms.

  # If n is negative, return last n terms.
  if(n < 0){ print(n)
    percent <- tail(percent, -n)}
  else
    percent <- head(percent, n)

  # sprintf will drop vector names, so save them for later.
  dates <- names(percent)
  # Format values, round to 2nd decimal place.
  percent <- sprintf("%1.2f%%", 100*percent)
  names(percent) <- dates

  return(percent)
}

tbsp<-read.stooq.asset.price("./data/input/Poland/tbsp_m.csv")
tbsp_returns <- returns.from.prices(tbsp)
format.to.percentage(tbsp_returns, -2)