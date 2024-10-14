# etl.R
#' Cotains general functions for ETL.

library(docstring)
library(readxl)

read.stooq.asset.price <- function(file) {
  #' Read asset closing prices from csv file downloaded from stooq.pl.
  #'
  #' Reads csv file from stooq.pl and returns closing prices of an asset.
  #' Also names vector position as dates.
  #'
  #' @param file character. A string with filepath of the stooq .csv file.
  #' @return numeric. A vector of closing prices of a given asset.

  sq <- read.csv(file)
  closing.price <- sq$Zamkniecie
  # Name vector postions as dates.
  names(closing.price) <- sq$Data

  return(closing.price)
}

read.stooq.rate <- function(file) {
  #' Read closing rates of economic indicators.
  #'
  #' Reads csv file from stooq.pl and returns closing rates of an indicator.
  #' Also names vector position as dates. This function is identical to
  #' read.stooq.asset.price, but has different name, so that we can omit
  #' any missunderstandings.
  #'
  #' @param file character. A string with filepath of the stooq .csv file.
  #' @return numeric. A vector of closing rates of a given indicator.

  # Just do the same as with asset prices.
  return(read.stooq.asset.price(file)/100)
}

.add.date.periods <- function(dates, n, period = "month") {
  #' Add a period to dates.
  #'
  #' @param dates character. A vector of dates.
  #' @param n numeric. A number of periods to add/subtract.
  #' @param period character. A character string, containing
  #'    one of "day", "week", "month", "quarter" or "year".
  #' @return Date. A vector of moved dates.

  dates <- as.Date(dates)
  as.Date(sapply(dates,
                 function(date)
                   seq(date, by = paste (n, period), length = 2)[2]),
          origin = "1970-01-01")
}

.add.months <- function(dates, n) {
  #' Add months to dates.
  #'
  #' @param dates character. A vector of dates.
  #' @param n numeric. A number of months to add/subtract.
  #' @return Date. A vector of moved dates.

  return(.add.date.periods(dates, n, "month"))
}

.add.years <- function(dates, n){
  #' Add years to dates.
  #'
  #' @param dates character. A vector of dates.
  #' @param n numeric. A number of years to add/subtract.
  #' @return Date. A vector of moved dates.

  return(.add.date.periods(dates, n, "year"))
}

.last.day.from.first <- function(dates) {
  #' Find the last day of a given 1st day of month.
  #'
  #' @param dates character. A vector of 1st day dates.
  #' @return dates Date. A vector of last day of the month.

  dates <- as.Date(dates)
  # Add one month, to get 1st day of next.
  dates <- .add.months(dates, 1)
  # Subtract one day, to get last day of original month.
  dates <- dates - 1
  return(dates)
}

.last.day.sequence <- function(from, to, freq=12) {
  #' Get a sequence of last day dates.
  #'
  #' @param from character. A string with date from which to start (last day of month).
  #' @param to character. A string with date at which to stop (last day of month).
  #' @param freq numeric. A frequence of dates, freq/12. Default 1 -> 12/12=1.
  #' @return returns numeric. An extended vector of returns.

  periods <- seq(as.Date(from)+1, as.Date(to)+1, by=paste(freq/12, "month"))-1
  return(periods)
}

read.oecd.yield <- function(file, term="long") {
  #' Read bond yields from .csv file downloaded from data-explorer.oecd.org.
  #'
  #' @param file character. A string with oecd data filename.
  #' @param term character. A string indicating long or short term interest.
  #' @return yields numeric. A named numeric vector with total returns.

  oecd <- read.csv(file)
  measure <- tolower(term)
  # Capitalize first letter to match OECD format.
  substr(measure, 1, 1) <- toupper(substr(measure, 1, 1))

  # Get yields.
  oecd <- oecd[oecd$Measure ==  paste0(measure, "-term interest rates"), ]
  yields <- oecd$OBS_VALUE/100 # to make it a percent

  # Get first and last date + 1 month
  first_date <- as.Date(paste0(oecd$TIME_PERIOD[1], "-01"))
  first_date <- .add.months(first_date, 1)
  last_date <- as.Date(paste0(oecd$TIME_PERIOD[nrow(oecd)], "-01"))
  last_date <- .add.months(last_date, 1)
  # Prepare sequence (shifted by 1 month) from first to last date
  # Subtract 1 day to get last day of previous month (this is why earlier add 1 month)
  periods <- seq(first_date, last_date, by="month") - 1
  names(yields) <- periods

  return(yields)
}

read.imf.rate <- function(file, indicator="Central Bank Policy Rate") {
  #' Read closing rates of economic indicators.
  #'
  #' Reads xlsx file from data.imf.org and returns closing rates of an indicator.
  #' Also names vector position as dates.
  #'
  #' @param file character. A string with filepath of the imf .xlsx file.
  #' @return numeric. A vector of closing rates of a given indicator.

  imf <- as.data.frame(read_xlsx(file, sheet="Monthly", skip=7))
  # Remove 3 unused columns
  imf <- imf[, -c(2,3,4)]
  n_col <- ncol(imf) - 1 # do not count first column with name.
  # Replace "..." to NAs.
  imf[imf=="..."] <- NA
  # Find which row corresponds to indicator.
  ind <- which(imf$Indicator == indicator)

  rates <- as.numeric(imf[ind, 2:n_col])
  names(rates) <- colnames(imf)[2:n_col]
  # Convert names to proper dates. Present format is YYYYMmm.
  names(rates) <- as.Date(paste0(names(rates), "01"), format = "%YM%m%d")

  # Remove NAs.
  rates <- rates[!is.na(rates)]
  # Get last day dates.
  names(rates) <- .last.day.from.first(names(rates))

  return(rates/100) # to get percent.
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

rolling.returns.from.prices <- function(prices, time_frame=12) {
  #' Obtain rolling returns from prices.
  #'
  #' @param prices numeric. A numeric vector of an asset's prices.
  #' @param time_frame numeric. How long is a timeframe?
  #'    Default 12 (annually if prices are given in months).
  #' @return numeric. A numeric vector of an asset's total returns.

  n <- length(prices)
  # Get starting price of each time frame.
  # The last frame starts at n-time_frame+1. Since we don't want to exclude it +1 => +2
  start <- prices[-((n-time_frame+2):n)]
  # Get ending price of each time frame. The first frame ends after a full period.
  # Since we don't want to exlude it, we stop at the previous => -1
  end <- prices[-(1:(time_frame-1))]
  # TODO there is some date missmatch, needs probably +1 or something.
  returns <- end/start - 1
  names(returns) <- names(end)

  return(returns)
}

returns.from.yield <- function(yield, maturity=10) {
  #' Obtain total returns from bond yields.
  #'
  #' Details of this method can be found in
  #' Swinkels L., "Treasury bond return data starting in 1962"
  #'
  #' @param yield numeric. A named numeric vector with bond yields.
  #' @param maturity numeric. A scalar indicating maturity of those bonds.
  #' @return numeric. A named vector of total returns.
  #' 
  n <- length(yield)
  y_t_1 <- yield[1:(n-1)]
  y_t <- yield[-1]
  m_t <- maturity

  # Interest rate sensitivity or
  # Modified duration of risk-free bond at par value.
  d_t <- ( 1 - 1/(1+y_t/2)^(2*m_t) ) / y_t
  # Convexity of par bond.
  c_t <- ( 2/y_t^2
      * ( 1 - 1/(1+y_t/2)^(2*m_t))
    - 2*m_t / (y_t * (1 + y_t/2)^(2*m_t+1)) )
  # Returns.
  r_t <- (1+y_t_1)^(1/12)-1 - d_t*(y_t - y_t_1) + .5 * c_t*(y_t-y_t_1)^2

  return(r_t)
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

  if(freq > target_freq){ # If you want to compound returns,
    # How many periods are in target period?
    # 1/freq is the length of period in terms of year, analogously 1/target,
    # so 1/target / 1/freq = freq/target
    n_prd_in_tgt <- freq / target_freq

    transformed_returns <- .compound.returns(returns, n_prd_in_tgt)
  }
  else { # If you want to split returns into smaller chunks.
    n_prd_in_tgt <- target_freq / freq
    transformed_returns <- .split.returns(returns, n_prd_in_tgt, freq)
  }

  return(transformed_returns)
}

plot.returns <- function(returns, title="Returns", log=FALSE) {
  #' Plot cumulative returns.
  #'
  #' @param returns numeric. A numeric named vector of returns.
  #' @param title character. A string with plot title.

  log <- if(log) "y" else ""
  plot(as.Date(names(returns)), cumprod(1+returns),
       type = "l", ylab = "Returns", xlab = "time", main = title, log = log)
}

add.plot.returns <- function(returns, colour="red") {
  #' ADd cumulative returns to another plot.
  #'
  #' @param returns numeric. A numeric named vector of returns.

  lines(as.Date(names(returns)), cumprod(1+returns), col = colour)
}

select.returns <- function(returns, from, to, by=1) {
  #' Select a returns from some date to some other date.
  #'
  #' @param returns numeric. A named numeric vector of returns.
  #' @param from character. A string with date from which to start.
  #' @param to character. A string with date at which to stop.
  #' @retun numeric. A named numeric vector with returns from given date
  #'    to given date.

  periods <- names(returns)
  start <- which(periods == from)
  end <- which(periods == to)

  return(returns[seq(start, end, by=by)])
}

contains.all.dates <- function(returns, from, to) {
  #' Check if returns contain range of dates.
  #'
  #' @param returns numeric. A named vector of returns.
  #' @param from character. A string with date from which to start.
  #' @param to character. A string with date at which to stop.
  #' @return Date. A vector of missing dates.

  # Add one day, to get 1st day of next.
  from <- as.Date(from) + 1
  to <- as.Date(to) + 1
  # Subtract one day, to get last day of original month.
  range <- seq(from, to, by="month") - 1
  range <- as.character(range)

  return(setdiff(range, names(returns)))
}

extend.with.na <- function(returns, from, to, freq=12) {
  #' Extend returns with NA's.
  #'
  #' @param returns numeric. A named vector of returns.
  #' @param from character. A string with date from which to start.
  #' @param to character. A string with date at which to stop.
  #' @param freq numeric. A frequence of dates, freq/12. Default 1 -> 12/12=1.
  #' @return returns numeric. An extended vector of returns.

  # Get returns dates.
  start_date <- names(returns)[1]
  end_date <- names(returns)[length(returns)]
  ret_periods <- .last.day.sequence(start_date, end_date, freq)

  # Get periods to cover and fill them with NAs.
  periods <- .last.day.sequence(from, to, freq)
  na_filled <- rep(NA, length(periods))
  names(na_filled) <- periods

  # Find common dates and use them to fill returns where it's proper.
  common_dates <- intersect(as.character(ret_periods), as.character(periods))
  na_filled[common_dates] <- returns[common_dates]

  return(na_filled)
}