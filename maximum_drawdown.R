#####################################
######### MAXIMUM DRAWDOWN ##########
drawdown <- function(returns, start=1, end=length(returns)) {
  # Compute drawdown of given asset returns and period.
  # Args:
  #   returns (double[]): asset returns vector.
  #   start (int): start index.
  #   end (int): end index.
  # Returns:
  #   (double): drawdown of given asset, throught given period.

  # Get cumulative returns of an asset, throught given period.
  cum_ret <- cumprod(1+returns[start:end])
  n <- end - start + 1
  # Find maximum for this period.
  mx <- max(cum_ret)
  # Calculate drawdown.
  dd <- mx - cum_ret[n]
  return(if(dd >= 0) dd/mx else 0)
}
drawdown(us_yr_returns$sp500_return, 55, 61)

maxiumum_drawdown <- function(returns, start=1, end=length(returns)) {
  # Compute maxiumum drawdown of given asset returns and period.
  # Args:
  #   returns (double[]): asset returns vector.
  #   start (int): start index.
  #   end (int): end index.
  # Returns:
  #   (double): maximum drawdown of given asset, throught given period.

  dds <- start:end
  # Find drowdown for shorter periods, shifting starting point.
  dds <- sapply(dds, function (i) drawdown(returns, start=start, end=i))
  # Find maximum drowdown.
  return(max(dds))
}
maxiumum_drawdown(us_yr_returns$sp500_return)

maxiumum_drawdown(us_mo_returns$sp500_return)
maxiumum_drawdown(us_mo_returns$us_gov_return)

investment_horizon <- 1
n <- nrow(us_mo_returns) - investment_horizon*12
plot(1:n,
     1-sapply(1:n, function (month)
       maxiumum_drawdown(us_mo_returns$sp500_return, start = month, end = month + investment_horizon*12)),
     type = "l",
    col = "blue")
lines(1:n,
     1-sapply(1:n, function (month)
       maxiumum_drawdown(us_mo_returns$us_gov_return, start = month, end = month + investment_horizon*12)),
     type = "l",
    col = "red")
abline(h=seq(.6, .9, by=.1))