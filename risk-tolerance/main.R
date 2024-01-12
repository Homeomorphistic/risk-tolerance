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
start_date_ind <- which(sp500_raw["Date"] == "1946-12-31")
sp500_raw <- sp500_raw[start_date_ind:nrow(sp500_raw),]

#####################################
######### CALCULATE RETURNS #########
sp500_raw["return"] <- 0
n <- nrow(sp500_raw)
sp500_shift_1 <- sp500_raw[2:n,]
sp500_raw[2:n, "return"] <- (sp500_shift_1[, "Price"] + sp500_shift_1["Dividend"]/12 ) / sp500_raw[1:(n-1), "Price"] - 1

#####################################
######### JOIN DATAFRAMES ###########
us_returns <- data.frame(sp500_raw["Date"], us_gov_bonds_raw["Return.M"], sp500_raw["return"],
                         sp500_raw["CPI"])
names(us_returns) <- c("date", "us_gov_return", "sp500_return", "cpi")
us_returns[1, "us_gov_return"] <- 0

summary(us_returns["sp500_return"])
hist(unlist(us_returns["sp500_return"]), breaks = seq(-0.25, 0.2,0.01))

summary(us_returns["us_gov_return"])
hist(unlist(us_returns["us_gov_return"]), breaks = seq(-0.1, 0.15,0.01))
