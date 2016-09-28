# According to Kristoufek 2013 the data comes from
# http://stats.grok.se . However, the data ends at
# Jan 2016.
# So the rest of the data are extracted from:
# https://tools.wmflabs.org/pageviews/?project=en.wikipedia.org&platform=all-access&agent=user&start=2015-07-01&end=2016-09-27&pages=Bitcoin


library(jsonlite)
library(dplyr)
library(pbapply)
library(lubridate)

extract_data <- function(yyyymm){
  url <- paste0("http://stats.grok.se/json/en/",
                yyyymm, "/Bitcoin")
  json_list <- fromJSON(url)
  df <- json_list$daily_views %>%
    unlist %>%
    data.frame(
      date = names(.),
      view = .,
      row.names = NULL,
      stringsAsFactors = F)
  return(df)
}
# extract_data("201212")

dates <- seq(
  ymd("2009-11-01"),
  ymd("2015-12-01"),
  by = "1 month") %>%
  format("%Y%m")

df_list <- pblapply(dates, extract_data)

wiki_views <- df_list %>%
  bind_rows() %>%
  mutate(date = ymd(date)) %>%
  filter(!is.na(date)) %>%
  arrange(date)

wiki_views_latest <- read.csv(
  "pageviews-20150701-20160927.csv", stringsAsFactors = F) %>%
  select(date=Date, view=Bitcoin) %>%
  mutate(date = ymd(date))

wiki_views_combined <- wiki_views_latest %>%
  filter(date> "2015-12-31") %>%
  bind_rows(wiki_views) %>%
  arrange(date)

wiki_views_combined %>%
  write.csv("wiki_views.csv", row.names = F)

saveRDS(wiki_views_combined, file="wiki_views.rda")
