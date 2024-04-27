#' saving_bonds.R
#' This script produces returns from polish saving bonds.

source("analysis.R")

edo.returns <- function(from, to, margin=.0125) {
  #' Get EDO saving bonds returns.
  #'
  #' TODO needs details for whole -1 year stuff and other dates.
  #' TODO add deflation.
  #'
  #' @param from character. First year of return of saving bond.
  #' @param to character. Last year of return of saving bond.
  #' @param margin numeric. Margin to add to index.
  #' @return numeric. A named numeric vector with returns of EDO bond.

  from <- as.Date(from)
  to <- as.Date(to)
  periods <- seq(from, to, by="years")

  # We need interest rate from year ago, to know present return.
  from <- .add.years(from, -1)
  to <- .add.years(to, -1)
  int_rates <- select.returns(pl_int_mo, from, to, by=120)

  # We need CPI from year and two months ago, to know present return.
  # Add one day, to get 1st of next month, subtract to months,
  # and then subtract 1 day to get back to last date of previous month.
  from <- .add.months(from + 1, -2) -1
  to <- .add.months(to + 1, -2) -1

  # Get year-over-year CPI from two months prior.
  cpi <- select.returns(pl_cpi_yoy, from, to, by=12)

  # Most of the returns are cpi + margin,
  edo_returns <- cpi + margin
  # But every 10th year (and 1st) you restet to interest rate + margin.
  edo_returns[seq(1, length(edo_returns), by=10)] <- int_rates + margin

  names(edo_returns) <- periods
  return(edo_returns)
}

edo.real.returns <- function(from, to, cpi, margin=.0125) {
  #' Get EDO saving bonds real returns.
  #'
  #' @param from character. First year of return of saving bond.
  #' @param to character. Last year of return of saving bond.
  #' @param margin numeric. Margin to add to index.
  #' @param cpi numeric. A vector of CPI.
  #' @return numeric. A named numeric vector with real returns of EDO bond.

  edo <- edo.returns(from, to, margin)
  print(edo)
  cpi <- select.returns(cpi, from, to, 12)
  print(cpi)
  return(real.returns(edo, cpi))
}

edo.total.return <- function(from, to, margin = .0125, tax=.19, penalty=.02) {
  #' Get total return from some period of EDO saving bond.
  #'
  #' TODO works only for 10-year periods
  #'
  #' @param from character. First year of return of saving bond.
  #' @param to character. Last year of return of saving bond.
  #' @param margin numeric. Margin to add to index.
  #' @param tax numeric Tax taken from profits.
  #' @param penalty numeric. Penalty to pay for buyout before maturity.
  #' @return numeric. Total return of a given EDO bond.

  edo <- edo.returns(from, to, margin)
  gross_return <- prod(1 + edo) - 1
  return(gross_return * (1-tax))
}

edo.total.real.return <- function(from, to, cpi, margin = .0125,
                                  tax=.19, penalty=.02) {
  #' Get total real return from some period of EDO saving bond.
  #'
  #' TODO works only for 10-year periods
  #'
  #' @param from character. First year of return of saving bond.
  #' @param to character. Last year of return of saving bond.
  #' @param cpi numeric. A vector of CPI.
  #' @param margin numeric. Margin to add to index.
  #' @param tax numeric Tax taken from profits.
  #' @param penalty numeric. Penalty to pay for buyout before maturity.
  #' @return numeric. Total real return of a given EDO bond.

  total_return <- edo.total.return(from, to, margin, tax, penalty)
  cpi <- select.returns(cpi, from, to, 12)
  return( (1 + total_return) / prod(1+cpi) - 1)
}

get.all.edo.returns <- function(from, to, margin = .0125,
                                tax = .19, penalty = .02) {

}
