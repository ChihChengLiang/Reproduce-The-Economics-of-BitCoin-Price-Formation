# According to Kristoufek 2013 the data comes from
# http://stats.grok.se . However, the data ends at
# Jan 2016.
# So the rest of the data are extracted from:
# https://tools.wmflabs.org/pageviews/?project=en.wikipedia.org&platform=all-access&agent=user&start=2015-07-01&end=2016-09-27&pages=Bitcoin


library(jsonlite)
library(dplyr)
library(pbapply)
library(lubridate)
library(ggplot2)
library(tidyr)
source("utils.R")

extract_data <- function(yyyymm){
  url <- paste0("http://stats.grok.se/json/en/",
                yyyymm, "/Bitcoin")
  json_list <- fromJSON(url)
  df <- json_list$daily_views %>%
    unlist %>%
    data.frame(
      date = names(.),
      views = .,
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

wiki_views %>% save_data("wiki_views_stats.grok.se")

# I use the api to extract content in
# https://tools.wmflabs.org/pageviews/?project=en.wikipedia.org&platform=all-access&agent=user&start=2015-07-01&end=2016-09-27&pages=Bitcoin

url <- "https://wikimedia.org/api/rest_v1/metrics/pageviews/per-article/en.wikipedia/all-access/user/Bitcoin/daily/2015070100/2016092700"
wmflabs_json <- url %>% fromJSON()

wiki_views_wmflabs <- wmflabs_json$items %>%
  mutate(date = as.Date(timestamp, format = "%Y%m%d00")) %>%
  select(date, views)

wiki_views_wmflabs %>% save_data("wiki_views_wmflabs")


# Now we need a resonable way to combine wiki view data
# from stats.grok.se and from tools.wmflabs.org

intersection_df <- wiki_views %>%
  inner_join(wiki_views_wmflabs, by="date", suffix = c(".grok.se", ".wmflabs"))

cor(intersection_df$views.grok.se, intersection_df$views.wmflabs)

model <- lm(data = intersection_df, formula = views.grok.se ~ views.wmflabs + 0)

scale <- model$coefficients[[1]]

# Visualization shows the scaled views fit good and look satisfying :)
intersection_df %>%
  mutate(scaled_views.wmflabs = views.wmflabs* scale) %>%
  gather(key = "source", value = "views", -date) %>%
  ggplot(aes(x= date, y = views, color = source)) +
  geom_line()

wiki_views_combined <- wiki_views_wmflabs %>%
  filter(date > "2015-12-31") %>%
  mutate(views = views * scale) %>%
  bind_rows(wiki_views) %>%
  arrange(date)

wiki_views_combined %>% save_data("wiki_views_combined")
