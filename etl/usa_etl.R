# usa_etl.R extracts, transforms and loads USA market data.

# USA market data consists of many sources: NYU Stern (A. Damodaran),
# Yale (R. Shiller) and stooq site. First two are in xls files, which require
# more work, but contain many years of historical data. Stooq datasets are used
# only for US CPI (both monthly and yearly frequency).

# NYU Stern (A. Damodaran) dataset contains returns of almost any type of US asset:
# stocks, t-bills, bonds, corp bonds, real estate, gold and inflation. This is at
# the cost of frequency -- yearly returns.

# Yale (R. Shiller) dataset contains returns of stocks and home prices at monthly
# frequency. It also contains inflation.

# These datasets contain overlaping data, which can be used for testing data and methods.

# Library for reading Excel files.
library(readxl)

# Read NYU Stern (A. Damodaran) excel file.
damodaran_excel <- read_excel("data/input/USA/nyu_stern_damodaran.xls", sheet = "Returns by year")
# Read Yale (R. Shiller) excel files.
shiller_stock_excel <- read_excel("data/input/USA/shiller/yale_shiller_stocks.xls", sheet = "Data")
shiller_home_excel <- read_excel("data/input/USA/shiller/yale_shiller_home.xls", sheet = "Data")

###################################
######### IMPORT DATA #############
sp500_raw <- read.csv("data/input/usd/sp500_data.csv", header = TRUE,
                      colClasses = c("character", "numeric", "numeric", "numeric", "numeric"))
us_gov_bonds_raw <- read.csv("data/input/usd/Int_mo_gov_bond.csv", header = TRUE)

#####################################
#########  CLEAN DATA ###############

# Set different locale to change months abbreviations.
Sys.setlocale(category = "LC_TIME", locale = "en_US.UTF-8")

# Convert strings to dates in dataframes.
us_gov_bonds_raw["observation_date"] <- as.Date(us_gov_bonds_raw$observation_date,
                                                format = "%d-%b-%Y")

dates <- sapply(sp500_raw["Date"], as.character)
# add missing 0 to october
dates <- sub(pattern = "\\.1$", replacement = ".10", dates)
# add day date, without it formats don't work.
dates <- sapply(dates, function(x) paste0(x, ".01"))

sp500_raw["Date"] <- as.Date(dates, format = "%Y.%m.%d") - 1 # -1 to match with other data

# Remove first rows to match dates between sets.
start_date_ind <- which(sp500_raw["Date"] == "1947-12-31")
sp500_raw <- sp500_raw[start_date_ind:nrow(sp500_raw),]
us_gov_bonds_raw <- us_gov_bonds_raw[13:nrow(us_gov_bonds_raw),]

#####################################
######### CALCULATE RETURNS #########
sp500_raw["return"] <- 0
sp500_raw["inflation"] <- sp500_raw["CPI"]
n <- nrow(sp500_raw)

sp500_shift_1 <- sp500_raw[2:n,]
sp500_raw[2:n, "return"] <- (sp500_shift_1[, "Price"] + sp500_shift_1["Dividend"]/12 ) / sp500_raw[1:(n-1), "Price"] - 1
sp500_raw[2:n, "inflation"] <- sp500_shift_1[, "inflation"] / sp500_raw[1:(n-1), "inflation"] - 1

#####################################
######### JOIN DATAFRAMES ###########
us_mo_returns <- data.frame(sp500_raw["Date"], us_gov_bonds_raw["Return.M"], sp500_raw["return"],
                            sp500_raw["inflation"], row.names = NULL)
names(us_mo_returns) <- c("date", "us_gov_return", "sp500_return", "inflation")
us_mo_returns <- us_mo_returns[-1,]

rownames(us_mo_returns) <- us_mo_returns$date
#write.csv(us_mo_returns, file = "data/output/us_monthly_returns.csv", row.names = FALSE)

# Histograms.
hist(us_mo_returns$sp500_return, breaks = seq(-0.25, 0.2, 0.005))
abline(v=0, col="red")

hist(us_mo_returns$us_gov_return, breaks = seq(-0.1, 0.15, 0.005))
abline(v=0, col="red")

# CAGR
n_years <- nrow(us_mo_returns)/12
prod(1+us_mo_returns$sp500_return)^(1/n_years) - 1
prod(1+us_mo_returns$us_gov_return)^(1/n_years) - 1
prod(1+us_mo_returns$inflation)^(1/n_years) - 1

#####################################
######### YEARLY RETURNS ############
us_temp <- us_mo_returns
us_temp["sp500_cum"] <- 1
us_temp["us_gov_cum"] <- 1
us_temp["inflation_cum"] <- 1

for (i in 1:nrow(us_mo_returns)){
  if (i %% 12 != 1){ # for any month besides January, cumulate montly returns.
    us_temp[i, "sp500_cum"] <- us_temp[i-1, "sp500_cum"] * (1+us_temp[i, "sp500_return"])
    us_temp[i, "us_gov_cum"] <- us_temp[i-1, "us_gov_cum"] * (1+us_temp[i, "us_gov_return"])
    us_temp[i, "inflation_cum"] <- us_temp[i-1, "inflation_cum"] * (1+us_temp[i, "inflation"])
  }
  else{ # for January reset cumulation and start over.
    us_temp[i, "sp500_cum"] <- 1+us_temp[i, "sp500_return"]
    us_temp[i, "us_gov_cum"] <- 1+us_temp[i, "us_gov_return"]
    us_temp[i, "inflation_cum"] <- 1+us_temp[i, "inflation"]
  }
}

us_yr_returns <- us_temp[seq(12, 900, by=12), c(1, 6, 5, 7)]
us_yr_returns[, 2:4] <- us_yr_returns[, 2:4] - 1
names(us_yr_returns) <- c("date", "us_gov_return", "sp500_return", "inflation")
rownames(us_yr_returns) <- 1:nrow(us_yr_returns)

prod(1+us_yr_returns$sp500_return)^(1/n_years) - 1
prod(1+us_yr_returns$us_gov_return)^(1/n_years) - 1
prod(1+us_yr_returns$inflation)^(1/n_years) - 1

sd(us_yr_returns$sp500_return)
sd(us_yr_returns$us_gov_return)

rownames(us_yr_returns) <- us_yr_returns$date
#write.csv(us_yr_returns, file = "data/output/us_yearly_returns.csv", row.names = FALSE)





