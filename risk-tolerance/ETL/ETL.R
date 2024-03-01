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

format.to.percentage <- function(returns, n=length(returns)) {
  #' Formats returns to standard way of X.XX%
  #'
  #' @param numeric. A numeric vector o returns.
  #' @param n numeric. A numeric scalar indicating number of first terms to return.
  #'  If negative, return last n terms.

  # If n is negative, return last n terms.
  if(n < 0){ print(n)
    returns <- tail(returns, -n)}
  else
    returns <- head(returns, n)

  # sprintf will drop vector names, so save them for later.
  dates <- names(returns)
  # Format values, round to 2nd decimal place.
  returns <- sprintf("%1.2f%%", 100*returns)
  names(returns) <- dates

  return(returns)
}

.coumpound.returns <- function(returns, n) {
  #' Compound returns into less but longer periods.
  #'
  #' @param returns numeric. A numeric vector of returns.
  #' @n numeric. A scalar indicating how many periods
  #'    to compound into one.
  #' @return transformed_returns numeric. A numeric vector
  #'    of compounded returns.

  n_periods <- length(returns)
  periods <- names(returns)
  # Prepare target period names.
  progression <- seq(n, n_periods, by=n)
  target_periods <- periods[progression]

  # Find number of periods with target frequency.
  n_target <- n_periods / n
  # Prepare grouping vector. Ex. 1,1,1,2,2,2,...,n_target,n_target,n_target
  groups <- sort(rep(1:n_target, length.out=n_periods))
  # Split returns into groups that will be compounded.
  splitted <- split(1+returns, groups)
  # Compound.
  transformed_returns <- unlist(lapply(splitted, prod)) - 1
  names(transformed_returns) <- target_periods

  return(transformed_returns)
}

.split.returns <- function(returns, n) {
  #' Split returns into more and smaller periods.
  #'
  #' @param returns numeric. A numeric vector of returns.
  #' @n numeric. A scalar indicating how many periods
  #'    to split one into.
  #' @return transformed_returns numeric. A numeric vector
  #'    of splitted returns.

  periods <- names(returns)
  start_date <- as.Date(periods[1])
  # Subtract one year.
  start_date <- seq(start_date, length.out = 2, by="-1 year")[2]
  end_date <- as.Date(periods[length(periods)])
  # For each return, split it into n equal returns.
  transformed_returns <- unlist(lapply(returns,
                                       function(returns) rep((1+returns)^(1/n)-1, n)))
  # Get sequence of dates for target returns.
  periods_target <- seq(start_date+1, end_date+1, by=paste0(12/n, " month"))-1 # TODO explain yourself
  names(transformed_returns) <- periods_target[-1] # TODO explain

  return(transformed_returns)
}

transform.returns <- function(returns, freq=12, target_freq=1) {
  #' Transform returns to match different frequency.
  #'
  #' Transform returns from current frequency to target frequency.
  #' Frequency of 1 is a yearly frequency.
  #'
  #' @param returns numeric. A numeric vector of returns.
  #' @param freq numeric.  Current frequency of returns.
  #' @param target_freq numeric. Target frequency of returns.

  # TODO throw errors if not compatible frequencies.
  # Current number of periods with returns.
  n_periods <- length(returns)
  periods <- names(returns)

  if(freq > target_freq){ # If you want to compound returns,
    # How many periods are in target period?
    # 1/freq is the length of period in terms of year, analogously 1/target,
    # so 1/target / 1/freq = freq/target
    n_prd_in_tgt <- freq / target_freq

    transformed_returns <- .coumpound.returns(returns, n_prd_in_tgt)
  }
  else { # If you want to split returns into smaller chunks.
    n_prd_in_tgt <- target_freq / freq

  }

  return(transformed_returns)
}

tbsp<-read.stooq.asset.price("./data/input/Poland/tbsp_m.csv")
tbsp_returns <- returns.from.prices(tbsp)[c(-205,-206)]
tbsp_returns_yr <- transform.returns(tbsp_returns)
x<-.split.returns(tbsp_returns_yr, 12)

plot(as.Date(names(tbsp_returns)),
     cumprod(tbsp_returns+1),
     type = "l",
     xlim = c(as.Date("2007-01-31"), as.Date("2023-12-31"))
)
lines(as.Date(names(tbsp_returns)), cumprod(x+1), type = "l", col="red")