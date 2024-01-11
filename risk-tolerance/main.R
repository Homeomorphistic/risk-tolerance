# Importing data
sp500_raw <- read.csv("risk_tolerance_data/sp500_data.csv", header = TRUE)
us_gov_bonds_raw <- read.csv("risk_tolerance_data/Int_mo_gov_bond.csv", header = TRUE)

# Set different locale to change months abbreviations.
Sys.setlocale(category = "LC_TIME", locale = "en_US.UTF-8")

# Convert strings to dates in dataframes.
us_gov_bonds_raw["observation_date"] <- as.Date(us_gov_bonds_raw$observation_date,
                                                format = "%d-%b-%Y")

dates <- sapply(sp500_raw["Date"], as.character)
dates <- sapply(dates, function(x) paste0(x, ".01"))
sp500_raw["Date"] <- as.Date(dates, format = "%Y.%m.%d") - 1 # -1 to match with other data

# Removing first rows to match dates between sets.
which(sp500_raw["Date"] == "1946-12-31")