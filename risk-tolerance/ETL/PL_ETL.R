x <- read.csv("data/input/Poland/OECD.SDD.STES,DSD_STES@DF_FINMARK,4.0+POL.M.IR3TIB+IRLT.PA......csv")
x <- x[x$Measure == "Long-term interest rates", c("TIME_PERIOD", "OBS_VALUE")]
x <- x[72:nrow(x),]
rownames(x) <- 1:nrow(x)

d_t <- function(y_t, m_t = 10) ( 1 - 1/(1+y_t/2)^(2*m_t) ) / y_t
c_t <- function(y_t, m_t=10) 2/y_t^2 * ( 1 - 1/(1+y_t/2)^(2*m_t)) - 2*m_t / (y_t * (1 + y_t/2)^(2*m_t+1))
r_t <- function(y_t_1, y_t, m_t=10) (1+y_t_1)^(1/12)-1 - d_t(y_t)*(y_t - y_t_1) + .5 * c_t(y_t)*(y_t-y_t_1)^2

y <- x$OBS_VALUE/100
n <- length(y)
r <- r_t(y[1:(n-1)], y[-1])

tbsp <- read.csv("data/input/Poland/tbsp_m.csv")
tbsp <- tbsp[-nrow(tbsp), c("Data", "Zamkniecie")]
y <- tbsp$Zamkniecie
tbsp_r <- y[-1] / y[1:(n-1)] - 1
plot(cumprod(1+r), type = "l")
lines(cumprod(1+tbsp_r), col = "red")

# IMPORTANT NOTES
# Poland 10-Year Government Bond Yield is measured starting 2005-11-30
# The same but less accurate data (average for months) in OECD starts 2001-01
# TBSP starts 2006-12-31
# For additional accuracy we can use 2001-01 -> 2005-10 from OECD
# then 2005-11 -> 2006-12 from stooq bond yields
# then TBSP

# Oldest polish bond fund as a proxy
# https://stooq.pl/q/d/?s=2848.n
# https://stooq.pl/q/d/?s=2722.n
# https://stooq.pl/q/d/?s=3960.n
# https://stooq.pl/q/d/?s=1127.n



