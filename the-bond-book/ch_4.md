# Cashflows
There are 3 sources of income from bond: selling (or redeeming) a bond, simple interest derived from coupons and *interest on reinvested coupons*.

For compounding require 2 ingreidients needed: time and reinvestment!

# The many yields

_Coupon yield_ is just rate of coupons.

_Current yield_ = coupon / price. Does not depend on maturity and it fails to measure two cashflows: interest-on-interest and redeeming at par.

_Yield-to-maturity_ takes into account interest-on-interest and selling price (or redeeming). Only numerical solutions to find this interest rate.
It is only an estimate because it takes some conditions:
- holding bond to maturity,
- coupons are reinvested,
- they are reinvested at YTM rate.
Especialy the last two are hard to hold, with longer bonds the interest rate will change and you won't be able to reinvest at the same YTM.

The larger the size of coupon the more likely you are to reinvest them at lower rates, so you will earn less then YTM at buying time.
YTM is increasingly less accurate with longer maturities.
YTM is useful for comparing with other securities, with different coupons and prices.

There is **to much emphasis on YTM**. There are other criteria for selection of bonds, depending on your objective.
When looking for stability you mind look for maturieties (2-7 years) or when you do not plan to reinvest,
you might look at current yield.

_Total return_ is calculated after you have redeemed or sold bond and gives you your earnings.

# Duration
Duration measures sensitivity of a bond to interest rate changes. It also adds timings and size of cashflows. It takes into account size,
because you may have more or less money to reinvest. So two bonds bought at discount (more likely to have small coupons) 
and premium (more likely to have large coupons) with the same YTM will have different durations.

Def: a weighted average term-to-maturity of a security's cash flows

The duration is given in years. It readjust the maturity to account for the size of the coupons and potential interest-on-interest.

*Duration is correlated to maturity length.*

For example, bond at discount with low coupons you have less money to reinvest and the bigger chunk is at maturity.
As a result bonds with lower coupons have longer durations. With the exception of zero coupon bond (for which is equal),
the duration is always shorter than its term-to-maturity.

# Duration and risk
Bond with longer duration is more volatile. For every 1% that interest rates go up or down, the price of a bond will go up or down by the duration number.

Considering buying 3 bonds with the same YTM, one a discount, one a premium, or one a zero, then the premium would be the least volatile,
the discount would be more volatile, and the zero the most volaltile.

Duration is more accurate for small changes in interest rate levels than for larger.
