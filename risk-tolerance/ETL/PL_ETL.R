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

pl_long_int <- read.oecd.yield(file.path(common_bonds, "oecd_yield_poland.csv"), term="long")
pl_short_int <- read.oecd.yield(file.path(common_bonds, "oecd_yield_poland.csv"), term="short")

# TODO compare total returns between OECD, stooq and tbsp
pl_stooq_long <- read.stooq.rate(file.path(common_bonds, "10yply_b_m.csv"))

# Bond funds.
investor <- read.stooq.asset.price(file.path(common_bonds, "2848_n_m.csv"))
nn <- read.stooq.asset.price(file.path(common_bonds, "2722_n_m.csv"))
generali <- read.stooq.asset.price(file.path(common_bonds, "3960_n_m.csv"))
pzu <- read.stooq.asset.price(file.path(common_bonds, "1127_n_m.csv"))

investor <- returns.from.prices(investor)
nn <- returns.from.prices(nn)
generali <- returns.from.prices(generali)
pzu <- returns.from.prices(pzu)

# investor <- select.returns(investor, "1999-10-31", "2024-02-29")
# nn <- select.returns(nn, "1999-10-31", "2024-02-29")
# generali <- select.returns(generali, "1999-10-31", "2024-02-29")
# pzu <- select.returns(pzu, "1999-10-31", "2024-02-29")

investor <- select.returns(investor, "2007-01-31", "2024-02-29")
nn <- select.returns(nn, "2007-01-31", "2024-02-29")
generali <- select.returns(generali, "2007-01-31", "2024-02-29")
pzu <- select.returns(pzu, "2007-01-31", "2024-02-29")

plot.returns(pl_tbsp)
add.plot.returns(nn)
add.plot.returns(investor, col="blue")
add.plot.returns(pzu, col="green")
add.plot.returns(generali, col="violet")


# ALTERNATIVES
pl_gold <- read.stooq.asset.price(file.path(common_alt, "xaupln_m.csv"))
pl_gold <- returns.from.prices(pl_gold)
pl_btc <- read.stooq.asset.price(file.path(common_alt, "btcpln_m.csv"))
pl_btc <- returns.from.prices(pl_btc)

# IMPORTANT NOTES
# poland 10-Year Government Bond Yield is measured starting 2005-11-30
# The same but less accurate data (average for months) in OECD starts 2001-01
# TBSP starts 2006-12-31
# For additional accuracy we can use 2001-01 -> 2005-10 from OECD
# then 2005-11 -> 2006-12 from stooq bond yields
# then TBSP

# You can add short term interest to mix and obtain results closer to TBSP!

# Oldest polish bond fund as a proxy
# https://stooq.pl/q/d/?s=2848.n
# https://stooq.pl/q/d/?s=2722.n
# https://stooq.pl/q/d/?s=3960.n
# https://stooq.pl/q/d/?s=1127.n



