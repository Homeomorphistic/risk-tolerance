portfolio <- function(stocks = .5, bonds = .5) {
  return(stocks * us_yr_returns$sp500_return + bonds * us_yr_returns$us_gov_return)
}

stocks <- seq(0, 1, by=.2)
portfolio_returns <- sapply(stocks, function (p) portfolio(stocks = p, bonds = 1-p))
colnames(portfolio_returns) <- stocks
apply(portfolio_returns, 2, mean)
apply(portfolio_returns, 2, sd)