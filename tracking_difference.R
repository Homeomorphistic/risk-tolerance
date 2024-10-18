# Source etl script
source("etl/etl.R")
# Paths
common <- "data/input/poland"
common_equities <- file.path(common, "equities")
common_bonds <- file.path(common, "bonds")

# Indices
wig20tr <- read.stooq.asset.price(file.path(common_equities, "wig20tr_w.csv"))
mwig40tr <- read.stooq.asset.price(file.path(common_equities, "mwig40tr_m.csv"))
swig80tr <- read.stooq.asset.price(file.path(common_equities, "swig80tr_m.csv"))
tbsp <- read.stooq.asset.price(file.path(common_bonds, "^tbsp_m.csv"))
gpwbw_bwz <- read.stooq.asset.price(file.path(common_bonds, "^gpwbbwz_m.csv"))

# ETFs
etf_wig20tr <- read.stooq.asset.price(file.path(common_equities, "etfbw20tr_pl_w.csv"))
etf_mwig40tr <- read.stooq.asset.price(file.path(common_equities, "etfbm40tr_pl_m.csv"))
etf_swig80tr <- read.stooq.asset.price(file.path(common_equities, "etfbs80tr_pl_m.csv"))
etf_tbsp <- read.stooq.asset.price(file.path(common_bonds, "etfbtbsp_pl_m.csv"))
etf_cash <- read.stooq.asset.price(file.path(common_bonds, "etfbcash_pl_m.csv"))

rolling.tracking.diff <- function(index, etf, timeframe=12) {
  #' Obtain rolling tracking difference for an etf.
  #'
  #' @param index numeric. A vector of index prices.
  #' @param etf numeric. A vector of etf prices.
  #' @param timeframe numeric. How long is a timeframe to roll?
  #'    Default 12 (annually if prices are given in months).
  #' @return numeric. A vector of rolling tracking differences.

  # Get period over which to measure TD.
  start <- names(etf)[1]
  end <- names(etf)[length(etf)]
  index <- select.returns(index, start, end)
  # Get rolling returns.
  index <- rolling.returns.from.prices(index, timeframe)
  etf <- rolling.returns.from.prices(etf, timeframe)

  return(index - etf)
}

plot.rolling.tracking.diff <- function(index, etf, timeframe = 12, etf.name="") {
  #' Plot rolling tracking difference.
  #'
  #' @param index numeric. A vector of index prices.
  #' @param etf numeric. A vector of etf prices.
  #' @param timeframe numeric. How long is a timeframe to roll?
  #'    Default 12 (annually if prices are given in months).
  #' @param etf.name string. An ETF name to be added in chart title.
  #' @return numeric. A vector of rolling tracking differences.

  td <- rolling.tracking.diff(index, etf, timeframe)
  # Prepare y-axis.
  td.qt<- quantile(td, c(.05, .95))
  y.axis <- seq(round(td.qt[1], 2), round(td.qt[2], 2), by=0.005)
  # Plot
  plot(as.Date(names(td)), td, type="S", yaxt = "n", lwd=0.5, #ylim = td.qt,
       main = paste(etf.name, "rolling tracking difference"),
       xlab = "Date", ylab = "tracking difference")
  axis(2, at=y.axis, labels=paste0(y.axis*100, "%"))
  # Add horizontal lines
  abline(h=td.qt, lty="dotted", lwd=2, col="green")
  abline(h=mean(td), lty="dotted", col="red", lwd=2)
  abline(h=0, col="blue", lwd=2)

  return(td)
}

td <- plot.rolling.tracking.diff(wig20tr, etf_wig20tr, timeframe=51, "Beta WIG20TR")
summary(td)
td.qt <- quantile(td, c(.05, .95))
hist(td[td>=td.qt[1] & td<=td.qt[2]], breaks=20)