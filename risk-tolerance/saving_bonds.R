# saving_bonds.R
#' This script produces returns from polish saving bonds.

edo <- function(from="2012-12-31", to="2023-12-31", margin=.0125, tax=.19, penalty=.02) {
  #' Get EDO saving bonds returns.
  #'
  #' TODO needs details for whole -1 year stuff and other dates.
  #'
  #' @param from character. First year of return of saving bond.
  #' @param to character. Last year of return of saving bond.
  #' @param margin numeric. Margin to add to index.
  #' @param tax numeric Tax taken from profits.
  #' @param penalty numeric. Penalty to pay for buyout before maturity.
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
  print(cpi)
  # Most of the returns are cpi + margin,
  edo_returns <- cpi + margin
  # But every 10th year (and 1st) you restet to interest rate + margin.
  edo_returns[seq(1, length(edo_returns), by=10)] <- int_rates + margin

  names(edo_returns) <- periods
  return(edo_returns)
}
edo(from="2011-12-31", to="2023-12-31", margin = 0)

from=as.Date("1998-02-28")+1
to=as.Date("2024-01-31")+1
s=seq(from, to, by="months")-1
setdiff(as.character(s), names(pl_int_mo))
setdiff(as.character(s), names(pl_cpi_yoy))
setdiff(as.character(s), names(pl_cpi_mom))