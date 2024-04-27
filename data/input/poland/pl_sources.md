# Datasets for Poland

## Economic indicators
Those indicators are needed for securities linked to inflation
or interest rate. In polish case these are EDO saving bonds.

CPI is used for obtaining real rate of returns from any securities
denominated in PLN.

- CPI year-over-year: 
[cpiypl_m_m.csv (year-over-year)](https://stooq.pl/q/d/?s=cpiypl.m&i=m)
(1982-present)

    error with signs:
    - 2020-04-30,-3.4,-3.4,-3.4,-3.4

- CPI month-over-month:
[cpimpl_m_m.csv (month-over-month)](https://stooq.pl/q/d/?s=cpimpl.m)
(1982-present)

  missing record:
  - 2023-05-31,0,0,0,0

- Central bank policy rate: 
  - International money fund:
  [imf_Interest_Rates.xlsx](https://data.imf.org/regular.aspx?key=61545855)
  (1998-present)
  
    To download the data, select country "Poland" and then
    all Dates by expanding list, then right-clicking and
    Advanced selection -> Select level -> Monthly.

  - stooq.pl (with around 100 missing values): 
  [inrtpl_m_m.csv](https://stooq.pl/q/d/?s=inrtpl.m)
  (1998-present)
  
    missing records: (only first few)
    - 2010-07-30,3.5,3.5,3.5,3.5
    - 2011-02-31,3.75,3.75,3.75,3.75
    - 2011-08-30,4.5,4.5,4.5,4.5
    - 2012-08-31,4.75,4.75,4.75,4.75
    - 2024-01-31,5.75,5.75,5.75,5.75

## Equity market

- WIG [wig_m.csv](https://stooq.pl/q/d/?s=wig) (1991-present)

## Bond market

- TBSP [tbsp_m.csv](https://stooq.pl/q/d/?s=^tbsp) (2007-present)

- short and long-term yields:
[oecd_yield_poland.csv](https://data-explorer.oecd.org/vis?lc=en&pg=0&fs[0]=Topic%2C1%7CEconomy%23ECO%23%7CShort-term%20economic%20statistics%23ECO_STS%23&fc=Topic&bp=true&snb=21&vw=tb&df[ds]=dsDisseminateFinalDMZ&df[id]=DSD_STES%40DF_FINMARK&df[ag]=OECD.SDD.STES&df[vs]=4.0&pd=1991-01%2C2024-02&dq=POL.M..PA.....&ly[rw]=MEASURE&ly[cl]=TIME_PERIOD&to[TIME_PERIOD]=false)
(short-term 1991-present, long-term 2001-present)

  Organisation for Economic Co-operation:
  it contains both long-term (10-year) and short-term (3-months) yield monthly averages.

  alternatively:

  - [Eurostat](https://ec.europa.eu/eurostat/databrowser/view/irt_lt_mcby_m__custom_10602653/default/table?lang=en)
  - [OECD](https://data.ecb.europa.eu/data/datasets/IRS/IRS.M.PL.L.L40.CI.0000.PLN.N.Z?chart_props=W3sibm9kZUlkIjoiNTE3NTkwIiwicHJvcGVydGllcyI6W3siY29sb3JIZXgiOiIiLCJjb2xvclR5cGUiOiIiLCJjaGFydFR5cGUiOiJsaW5lY2hhcnQiLCJsaW5lU3R5bGUiOiJTb2xpZCIsImxpbmVXaWR0aCI6IjEuNSIsImF4aXNQb3NpdGlvbiI6ImxlZnQiLCJvYnNlcnZhdGlvblZhbHVlIjpmYWxzZSwiZGF0ZXMiOltdLCJpc1RkYXRhIjpmYWxzZSwibW9kaWZpZWRVbml0VHlwZSI6IiIsInllYXIiOiJmdWxsUmFuZ2UiLCJzdGFydERhdGUiOiIyMDAxLTAxLTMxIiwiZW5kRGF0ZSI6IjIwMjQtMDItMjkiLCJzZXREYXRlIjpmYWxzZSwic2hvd1RhYmxlRGF0YSI6dHJ1ZSwiY2hhbmdlTW9kZSI6ZmFsc2UsInNob3dNZW51U3R5bGVDaGFydCI6ZmFsc2UsImRpc3BsYXlNb2JpbGVDaGFydCI6dHJ1ZSwic2NyZWVuU2l6ZSI6Im1heCIsInNjcmVlbldpZHRoIjoxOTIwLCJzaG93VGRhdGEiOmZhbHNlLCJ0cmFuc2Zvcm1lZEZyZXF1ZW5jeSI6Im5vbmUiLCJ0cmFuc2Zvcm1lZFVuaXQiOiJub25lIiwiZnJlcXVlbmN5Ijoibm9uZSIsInVuaXQiOiJub25lIiwibW9kaWZpZWQiOiJmYWxzZSIsInNlcmllc0tleSI6Im1vbnRobHkiLCJzaG93dGFibGVTdGF0ZUJlZm9yZU1heFNjcmVlbiI6ZmFsc2UsImlzZGF0YWNvbXBhcmlzb24iOmZhbHNlLCJzZXJpZXNGcmVxdWVuY3kiOiJtb250aGx5IiwiaW50aWFsU2VyaWVzRnJlcXVlbmN5IjoibW9udGhseSIsIm1ldGFkYXRhRGVjaW1hbCI6IjIiLCJpc1RhYmxlU29ydGVkIjpmYWxzZSwiaXNZZWFybHlUZGF0YSI6ZmFsc2UsInJlc3BvbnNlRGF0YUVuZERhdGUiOiIyMDI0LTAyLTI5IiwiaXNpbml0aWFsQ2hhcnREYXRhIjp0cnVlLCJpc0RhdGVzRnJvbURhdGVQaWNrZXIiOmZhbHNlLCJkYXRlUGlja2VyRW5kRGF0ZSI6IiIsImlzRGF0ZVBpY2tlckVuZERhdGUiOmZhbHNlLCJzZXJpZXNrZXlTZXQiOiIiLCJkYXRhc2V0SWQiOiIyMSIsImlzQ2FsbGJhY2siOmZhbHNlLCJpc1NsaWRlclRkYXRhIjpmYWxzZSwiaXNTbGlkZXJEYXRhIjpmYWxzZSwiaXNJbml0aWFsQ2hhcnREYXRhRnJvbUdyYXBoIjpmYWxzZSwiY2hhcnRTZXJpZXNLZXkiOiJJUlMuTS5QTC5MLkw0MC5DSS4wMDAwLlBMTi5OLloiLCJ0eXBlT2YiOiIifV19XQ%3D%3D)
  - [stooq](https://stooq.pl/q/d/?s=10yply.b) (not averages, so more accurate, but only since 2005-10)

## Alternatives
- Gold: [xaupln_m.csv](https://stooq.pl/q/d/?s=xaupln) (1984-present)
- Bitcoin: [btcpln_m.csv](https://stooq.pl/q/d/?s=btcpln) (2010-present)