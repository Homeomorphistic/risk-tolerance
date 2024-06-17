# pl_etl.R
#' Extract, transform and load datasets from Poland.
#'
#' Datasets contain CPI of PLN, bond and equity indices,
#' gold and bitcoin indices. Also bond short and long
#' term yields.
#'
#' Main focus of the script is to recreate the bond index
#' throughout 1991-2007. The main bond index TBSP starts
#' in 2006-12-31, but bonds where available since 1991.
#'
#' OECD and other sources (IMF, Eurostat) contain long-term
#' yields in Poland starting in 2001-01 and short-term yields
#' starting in 1991-06.
#'
#' There is a theoretical method for obtaining total returns from
#' yields, which is described in:
#' Swinkels L., "Treasury bond return data starting in 1962"
#'
#' The method is used to obtain total returns from constant 10-year
#' (long-term yields) and 3-month (short-term yields) maturity polish bonds.
#'
#' For period 1991-2001 short-term yields are used as extension of
#' bond index.
#'
#' For period 2001-2007 a mix of short-term and long-term yields
#' are used. The weights are obtained from linear regression based
#' on data from 2007-now:
#'
#' TBSP_i = a*long_term_i + b*short_term_i + eps_i
#'
#' The weights a and b need to satisfy a+b=1, because they are meant
#' to represent proportions of a portfolio containing short-term
#' and long-term bonds. Linear regression coefficients do not satisfy
#' any additional conditions, so later they are transformed using softmax:
#'
#' softmax(x_i) = exp(x_i) / sum^n_i=1 (exp(x_i))

# Source etl script
source("etl/etl.R")

# Paths
common <- "data/input/poland"
common_economy <- file.path(common, "economy")
common_equities <- file.path(common, "equities")
common_bonds <- file.path(common, "bonds")
common_alt <- file.path(common, "alternatives")

# ECONOMIC INDICATORS
# Before extracting check for at least two errors (look pl_sources.md)
pl_cpi_yoy <- read.stooq.rate(file.path(common_economy, "cpiypl_m_m.csv"))
pl_cpi_mom <- read.stooq.rate(file.path(common_economy, "cpimpl_m_m.csv"))
pl_int <- read.imf.rate(file.path(common_economy, "imf_Interest_Rates.xlsx"))

# EQUITY MARKET
pl_wig <- read.stooq.asset.price(file.path(common_equities, "wig_m.csv"))
pl_wig <- returns.from.prices(pl_wig)

# ALTERNATIVES
pl_gold <- read.stooq.asset.price(file.path(common_alt, "xaupln_m.csv"))
pl_gold <- returns.from.prices(pl_gold)
pl_btc <- read.stooq.asset.price(file.path(common_alt, "btcpln_m.csv"))
pl_btc <- returns.from.prices(pl_btc)

# BOND MARKET
pl_tbsp <- read.stooq.asset.price(file.path(common_bonds, "tbsp_m.csv"))
pl_tbsp <- returns.from.prices(pl_tbsp)

# Returns based on average yields.
pl_10y_returns <- read.oecd.yield(file.path(common_bonds, "oecd_yield_poland.csv"), term="long")
pl_10y_returns <- returns.from.yield(pl_10y_returns, maturity = 10)

pl_3mo_returns <- read.oecd.yield(file.path(common_bonds, "oecd_yield_poland.csv"), term="short")
pl_3mo_returns <- returns.from.yield(pl_3mo_returns, maturity = 0.25)

# Use long and short term yields to obtain estimate of each contribution of TBSP.
# It's done through linear regression and its coefficients.
pl_10y_lm <- select.returns(pl_10y_returns, "2007-01-31", "2023-12-31")
pl_3mo_lm <- select.returns(pl_3mo_returns, "2007-01-31", "2023-12-31")
pl_tbsp_lm <- select.returns(pl_tbsp, "2007-01-31", "2023-12-31")

softmax <- function(x) exp(x) / sum(exp(x))
cf <- lm(pl_tbsp_lm~pl_10y_lm + pl_3mo_lm - 1)$coefficients
cf <- softmax(cf)

# Extend TBSP by weighted returns from yields.
pl_10y_mid <- select.returns(pl_10y_returns, "2001-02-28", "2006-12-31")
pl_3mo_mid <- select.returns(pl_3mo_returns, "2001-02-28", "2006-12-31")

pl_tbsp_extended <- cf[1]*pl_10y_mid + cf[2]*pl_3mo_mid
pl_tbsp_extended <- c(pl_tbsp_extended, pl_tbsp)

# Extend begining by short-term yield.
pl_3mo_start <- select.returns(pl_3mo_returns, "1991-07-31", "2001-01-31")
pl_tbsp_extended <- c(pl_3mo_start, pl_tbsp_extended)

######################################################
######################################################
# Earliest date is 1991-06-30 and latest
first <- names(pl_3mo_returns)[1]
last <- names(pl_wig)[length(pl_wig)]
# Extend returns to this date and fill with NAs.
# Put everything into one dataframe.
pl_mo_returns <- data.frame(money_market=extend.with.na(pl_3mo_returns, first, last),
                            bond=extend.with.na(pl_tbsp_extended, first, last),
                            equity=extend.with.na(pl_wig, first, last),
                            gold=extend.with.na(pl_gold, first, last),
                            btc=extend.with.na(pl_btc, first, last),
                            cpi=extend.with.na(pl_cpi_mom, first, last))

