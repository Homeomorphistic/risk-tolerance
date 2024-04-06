# PL_ETL.R
#' Extract, transform and load datasets from Poland.
#'
#' Datasets contain CPI of PLN, bond and equity index.

# Source ETL script
source("ETL/ETL.R")

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

# BOND MARKET
pl_tbsp <- read.stooq.asset.price(file.path(common_bonds, "tbsp_m.csv"))
pl_tbsp <- returns.from.prices(pl_tbsp)

# TODO compare total returns between OECD, stooq and tbsp
pl_stooq_yield <- read.stooq.rate(file.path(common_bonds, "10yply_b_m.csv"))

# Returns based on average yields.
pl_10y_returns <- read.oecd.yield(file.path(common_bonds, "oecd_yield_poland.csv"))
pl_10y_returns <- returns.from.yield(pl_10y_returns)

pl_3mo_returns <- read.oecd.yield(file.path(common_bonds, "oecd_yield_poland.csv"), term="short")
pl_3mo_returns <- returns.from.yield(pl_3mo_returns, maturity = 0.25)

# Use long and short term yields to obtain estimate of each contribution of TBSP.
# It's done through linear regression and its coefficients.
pl_10y_lm <- select.returns(pl_10y_returns, "2007-01-31", "2023-12-31")
pl_3mo_lm <- select.returns(pl_3mo_returns, "2007-01-31", "2023-12-31")
pl_tbsp_lm <- select.returns(pl_tbsp, "2007-01-31", "2023-12-31")

softmax <- function(x) exp(x) / sum(exp(x))
cf <- lm(pl_tbsp_lm~pl_10y_lm + pl_3mo_lm - 1)$coefficients
cf <- cf/sum(cf)
cf <- softmax(cf)

# Extend TBSP by weighted returns from yields.
pl_10y_mid <- select.returns(pl_10y_returns, "2001-02-28", "2006-12-31")
pl_3mo_mid <- select.returns(pl_3mo_returns, "2001-02-28", "2006-12-31")

pl_tbsp_extended <- cf[1]*pl_10y_mid + cf[2]*pl_3mo_mid
pl_tbsp_extended <- c(pl_tbsp_extended, pl_tbsp)

# Extend begining by short-term yield.
pl_3mo_start <- select.returns(pl_3mo_returns, "1991-07-31", "2001-01-31")
pl_tbsp_extended <- c(pl_3mo_start, pl_tbsp_extended)

# ALTERNATIVES
pl_gold <- read.stooq.asset.price(file.path(common_alt, "xaupln_m.csv"))
pl_gold <- returns.from.prices(pl_gold)
pl_btc <- read.stooq.asset.price(file.path(common_alt, "btcpln_m.csv"))
pl_btc <- returns.from.prices(pl_btc)