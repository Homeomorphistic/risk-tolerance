# Source etl script
source("etl/etl.R")

# Paths
common <- "data/input/poland"
common_bonds <- file.path(common, "bonds")
common_equities <- file.path(common, "equities")

# Rolling returns of indices.
pl_wig20tr <- read.stooq.asset.price(file.path(common_equities, "wig20tr_m.csv"))
pl_wig20tr <- select.returns(pl_wig20tr,"2019-12-31", "2024-09-30")
pl_roll_wig20tr <- rolling.returns.from.prices(pl_wig20tr)
pl_mwig40tr <- read.stooq.asset.price(file.path(common_equities, "mwig40tr_m.csv"))
pl_roll_mwig40tr <- rolling.returns.from.prices(pl_mwig40tr)
pl_swig80tr <- read.stooq.asset.price(file.path(common_equities, "swig80tr_m.csv"))
pl_roll_swig80tr <- rolling.returns.from.prices(pl_swig80tr)
pl_tbsp <- read.stooq.asset.price(file.path(common_bonds, "tbsp_m.csv"))
pl_roll_tbsp <- rolling.returns.from.prices(pl_tbsp)

# Rolling returns of ETFs
etf_wig20tr <- read.stooq.asset.price(file.path(common_equities, "etfbw20tr_pl_m.csv"))
etf_wig20tr <- select.returns(etf_wig20tr,"2019-12-31", "2024-09-30")
roll_etf_wig20tr <- rolling.returns.from.prices(etf_wig20tr)
# TODO prepare proper dates.
etf_mwig40tr <- read.stooq.asset.price(file.path(common_equities, "etfbm40tr_pl_m.csv"))
roll_etf_mwig40tr <- rolling.returns.from.prices(etf_wig20tr)
etf_swig80tr <- read.stooq.asset.price(file.path(common_equities, "etfbs80tr_pl_m.csv"))
roll_etf_swig80tr <- rolling.returns.from.prices(etf_wig20tr)
etf_tbsp <- read.stooq.asset.price(file.path(common_bonds, "etfbtbsp_pl_m.csv"))
roll_etf_tbsp <- rolling.returns.from.prices(etf_tbsp)

# Tracking differences.
tracking_diff_wig20tr <- pl_roll_wig20tr - roll_etf_wig20tr
summary(tracking_diff_wig20tr)
plot(as.Date(names(tracking_diff_wig20tr)), tracking_diff_wig20tr, type="l", ylim = c(0, 0.02))
