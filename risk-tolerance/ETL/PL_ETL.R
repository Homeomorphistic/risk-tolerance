# PL_ETL.R
#' Extract, transform and load datasets from Poland.
#'
#' Datasets contain CPI of PLN, bond and equity index.

# Source ETL script
source("ETL/ETL.R")

# Before extracting check for at least two errors (look pl_sources.md)
pl_cpi_yoy <- read.stooq.rate("data/input/Poland/cpiypl_m_m.csv")
pl_cpi_mom <- read.stooq.rate("data/input/Poland/cpimpl_m_m.csv")
# Remove dates before GPW and WIG index.
cpi_last_date <- names(pl_cpi_yoy)[length(pl_cpi_yoy)]
pl_cpi_yoy <- select.returns(pl_cpi_yoy, "1991-04-30", cpi_last_date)
pl_cpi_mom <- select.returns(pl_cpi_mom, "1991-04-30", cpi_last_date)

# IMPORTANT NOTES
# Poland 10-Year Government Bond Yield is measured starting 2005-11-30
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



