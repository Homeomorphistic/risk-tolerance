#' analysis.R
#' Functions for analysis.

real.returns <- function(returns, cpi) {
  #' Get real returns of an asset.
  #'
  #' @param returns numeric. A vector of an asset returns.
  #' @param cpi numeric. A vector of CPI.
  #' @return numeric. A vector of real asset returns.

  return( (1+returns) / (1+cpi) - 1)
}
