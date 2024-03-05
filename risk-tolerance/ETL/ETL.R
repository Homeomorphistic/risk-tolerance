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

.compound.returns <- function(returns, n) {
  #' Compound returns into less periods but longer ones.
  #'
  #' @param returns numeric. A numeric named vector of returns.
  #' @n numeric. A scalar indicating how many periods
  #'    to compound into one.
  #' @return transformed_returns numeric. A numeric vector
  #'    of compounded returns.

  # How many periods there are? What are those periods?
  n_periods <- length(returns)
  periods <- names(returns)
  # New longer periods are the subsequence of periods with start n and step of n.
  progression <- seq(n, n_periods, by=n)
  longer_periods <- periods[progression]

  # How many new longer periods are in old ones?
  n_longer <- n_periods / n
  # Prepare grouping vector. It will group smaller periods into groups,
  # which will be compounded. Ex. 1,1,1,2,2,2,...,n_longer,n_longer,n_longer
  groups <- sort(rep(1:n_longer, length.out=n_periods))
  # Split returns into groups that will be compounded.
  splitted <- split(1+returns, groups) # add 1 for later multiplication.
  # Compound. For every group in list, take product of grouped returns.
  transformed_returns <- unlist(lapply(splitted, prod)) - 1 # subtract 1 to get retuns.
  names(transformed_returns) <- longer_periods

  return(transformed_returns)
}

.split.returns <- function(returns, n, freq) {
  #' Split returns into more but smaller periods.
  #'
  #' @param returns numeric. A numeric named vector of returns.
  #' @param n numeric. A scalar indicating how many periods
  #'    to split one into.
  #' @param freq numeric. A scalar indicating present frequency of returns.
  #' @return transformed_returns numeric. A numeric vector
  #'    of splitted returns.

  # What are the periods? What is the starting date?
  periods <- names(returns)
  start_date <- as.Date(periods[1])
  # Subtract one period. To do that, create sequence of dates, from starting_date to a period ago.
  start_date <- seq(start_date, length.out = 2, by=paste(-12/freq, "months"))[2]
  # We need it, because dates represent returns after a period (for example a year) and
  # if we want to split a year into smaller periods, we will need months (or anything else)
  # before that date.

  end_date <- as.Date(periods[length(periods)])

  # For each return, split it into n equal returns.
  transformed_returns <- unlist(lapply(returns,
                                       function(returns) rep((1+returns)^(1/n)-1, n)))
  # Get sequence of dates for new smaller periods.
  smaller_periods <- seq(start_date+1, end_date+1, by=paste0(12/n, " month"))-1
  # We are adding one to date, to make it 1st of the next month. It's gives
  # accurate sequence of dates (always first), while it has problems with last dates
  # (for example sometimes skips 28th Feb to 2nd March)
  # Then subtract one, to get back to last day of previous month.

  names(transformed_returns) <- smaller_periods[-1] # First period is before the original period.

  return(transformed_returns)
}

transform.returns <- function(returns, freq=12, target_freq=1) {
  #' Transform returns to match different frequency.
  #'
  #' Transform returns from current frequency to target frequency.
  #' Frequency of 1 is a yearly frequency.
  #'
  #' @param returns numeric. A numeric named vector of returns.
  #' @param freq numeric. A scalar indicating current frequency of returns.
  #' @param target_freq numeric. A scalar indicating target frequency of returns.

  # How many periods? What are they?
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
    transformed_returns <- .split.returns(returns, n_prd_in_tgt, freq)
  }

  return(transformed_returns)
}

plot.returns <- function(returns, title="Returns") {
  #' Plot cumulative returns.
  #'
  #' @param returns numeric. A numeric named vector of returns.
  #' @param title character. A string with plot title.

  plot(as.Date(names(returns)), cumprod(1+returns),
       type = "l", ylab = "Returns", xlab = "time", main = title)
}

add.plot.returns <- function(returns, colour="red") {
  #' ADd cumulative returns to another plot.
  #'
  #' @param returns numeric. A numeric named vector of returns.

  lines(as.Date(names(returns)), cumprod(1+returns), col = colour)
}

tbsp<-read.stooq.asset.price("./data/input/Poland/tbsp_m.csv")
tbsp_returns <- returns.from.prices(tbsp)[c(-205,-206)]
tbsp_returns_qr <- transform.returns(tbsp_returns, 12, 4)
tbsp_returns_hf <- transform.returns(tbsp_returns, 12, 2)
tbsp_returns_yr <- transform.returns(tbsp_returns, 12, 1)

plot.returns(tbsp_returns, "tbsp monthly")
add.plot.returns(transform.returns(tbsp_returns, 12, 1), "red")
add.plot.returns(transform.returns(tbsp_returns, 12, 4), "blue")