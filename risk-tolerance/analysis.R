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

cpi <- select.returns(pl_cpi_mom, "1991-07-31", "2024-02-29")
real_tbsp <- real.returns(pl_tbsp_extended, cpi)
pl_wig <- select.returns(pl_wig, "1991-07-31", "2024-02-29")
real_wig <- real.returns(pl_wig, cpi)

plot.returns(real_wig)
add.plot.returns(real_tbsp)
add.plot.returns(0.5*real_wig + 0.5*real_tbsp, col="blue")
add.plot.returns(0.3*real_wig + 0.7*real_tbsp, col="green")
