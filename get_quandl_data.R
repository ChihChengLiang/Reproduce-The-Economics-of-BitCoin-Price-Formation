# If you want to reproduce this step, 
# please register at https://www.quandl.com .
# Then, get your api key at 
# https://www.quandl.com/account/api 
# and save it to `api_key`.

library(Quandl)
api_key <- readLines("api_key", warn = F)
Quandl.api_key(api_key)

mkpru <- Quandl("BCHAIN/NADDU")
totbc <- Quandl("BCHAIN/TOTBC")
ntran <- Quandl("BCHAIN/NTRAN")
naddu <- Quandl("BCHAIN/NADDU")
bcdde <- Quandl("BCHAIN/BCDDE")
exrate <- Quandl("ECB/EURUSD")
oil_price <- Quandl("EIA/PET_RBRTE_D")
dj <- Quandl("YAHOO/INDEX_DJI")

save(
  list = c("bcdde", "mkpru", "naddu", "ntran", "totbc",
           "exrate", "oil_price", "dj"),
  file = "data/quandl_data.rda")