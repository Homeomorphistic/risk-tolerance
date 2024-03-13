# saving_bonds.R
#' This script produces returns from polish saving bonds.

edo <- function(from="2014-01-31", to="2024-01-31", margin=.0125, tax=.19, penalty=.02) {
  #' Get EDO saving bonds returns.
  #'
  #' @param from character. Start of saving through bond.
  #' @param to character. End of saving through bond.
  #' @param margin numeric. Margin to add to index.
  #' @param tax numeric Tax taken from profits.
  #' @param penalty numeric. Penalty to pay for buyout before maturity.
  #' @return numeric. A named numeric vector with returns of EDO bond.

  from <- as.Date(from)
  to <- as.Date(to)

  # Get yearly interest rates.
  int_rates <- select.returns(pl_int_mo, from, to, by=120)
  print(int_rates)

  # Add one day, to get 1st of next month, subtract to months,
  # and then subtract 1 day to get back to last date of previous month.
  from <- .add.months(from + 1, -2) -1
  to <- .add.months(to + 1, -2) -1

  # Get yearly CPI from two months prior.
  cpi <- select.returns(pl_cpi_yoy, from, to, by=12)
  print(cpi)

  # Most of the returns are cpi + margin,
  edo_returns <- cpi[-1] + margin
  # But every 10th year (and 1st) you restet to interest rate + margin.
  edo_returns[seq(1, length(edo_returns), by=10)] <- int_rates + margin

  #names(edo_returns) <- names(int_rates)
  return(edo_returns)
}
