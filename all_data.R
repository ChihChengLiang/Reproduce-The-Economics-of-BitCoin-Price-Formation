library(dplyr)

load("quandl_data.rda")
bitcointalk <- readRDS("bitcointalk.rda")
wiki_views <- readRDS("wiki_views.rda")

all_data <- mkpru %>%
  rename(mkpru = Value) %>%
  inner_join(totbc, by = "Date") %>%
  rename(totbc = Value) %>%
  inner_join(ntran, by = "Date") %>%
  rename(ntran = Value) %>%
  inner_join(naddu, by = "Date") %>%
  rename(naddu = Value) %>%
  inner_join(bcdde, by = "Date") %>%
  rename(bcdde = Value) %>%
  inner_join(exrate, by = "Date") %>%
  rename(exrate = Value) %>%
  inner_join(wiki_views, by = c("Date"="date")) %>%
  rename(wiki_views = view) %>%
  inner_join(
    bitcointalk %>% select(date, new_members, new_posts),
    by=c("Date"="date")
  ) %>%
  inner_join(oil_price, by = "Date") %>%
  rename(oil_price = Value) %>%
  inner_join(
    dj %>% select(Date, dj = `Adjusted Close`),
    by = "Date")

all_data %>% write.csv("all_data.csv", row.names = F)
saveRDS(all_data, "all_data.rda")
