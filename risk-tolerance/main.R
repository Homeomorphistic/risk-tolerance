###################################
######### IMPORT DATA #############
sp500_raw <- read.csv("risk_tolerance_data/sp500_data.csv", header = TRUE,
                      colClasses = c("character", "numeric", "numeric", "numeric", "numeric"))
us_gov_bonds_raw <- read.csv("risk_tolerance_data/Int_mo_gov_bond.csv", header = TRUE)

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
us_monthly_returns <- data.frame(sp500_raw["Date"], us_gov_bonds_raw["Return.M"], sp500_raw["return"],
                                 sp500_raw["inflation"], row.names = NULL)
names(us_monthly_returns) <- c("date", "us_gov_return", "sp500_return", "inflation")
us_monthly_returns <- us_monthly_returns[-1,]

write.csv(us_monthly_returns, file = "us_monthly_returns.csv", row.names = FALSE)

# Histograms.
hist(us_monthly_returns$sp500_return, breaks = seq(-0.25, 0.2, 0.005))
abline(v=0, col="red")

hist(us_monthly_returns$us_gov_return, breaks = seq(-0.1, 0.15, 0.005))
abline(v=0, col="red")

# CAGR
n_years <- nrow(us_monthly_returns)/12
prod(1+us_monthly_returns$sp500_return)^(1/n_years) - 1
prod(1+us_monthly_returns$us_gov_return)^(1/n_years) - 1
prod(1+us_monthly_returns$inflation)^(1/n_years) - 1

#####################################
######### YEARLY RETURNS ############
us_temp <- us_monthly_returns
us_temp["sp500_cum"] <- 1
us_temp["us_gov_cum"] <- 1
us_temp["inflation_cum"] <- 1

for (i in 1:nrow(us_monthly_returns)){
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

us_yearly_returns <- us_temp[seq(12, 900, by=12), c(1,6,5,7)]
us_yearly_returns[, 2:4] <- us_yearly_returns[, 2:4] - 1
names(us_yearly_returns) <- c("date", "us_gov_return", "sp500_return", "inflation")

prod(1+us_yearly_returns$sp500_return)^(1/n_years) - 1
prod(1+us_yearly_returns$us_gov_return)^(1/n_years) - 1
prod(1+us_yearly_returns$inflation)^(1/n_years) - 1

sd(us_yearly_returns$sp500_return)
sd(us_yearly_returns$us_gov_return)

write.csv(us_yearly_returns, file = "us_yearly_returns.csv", row.names = FALSE)