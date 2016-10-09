library(lubridate)
library(httr)
library(rvest)
library(dplyr)
library(pbapply)
source("utils.R")

extract_data <- function(yyyymm){
  url <- paste0(
    "https://bitcointalk.org/index.php?action=stats;expand=",
    yyyymm, ";xml")
  
  doc <- GET(
    url,
    config = list(
      "Referer"="https://bitcointalk.org/index.php?action=stats"
      )
    )
  df <- doc %>%
    content() %>%
    xml_nodes("day") %>%
    xml_attrs() %>%
    lapply(as.list) %>%
    bind_rows()
  return(df)
}
# extract_data("200912")

dates <- seq(
  ymd("2009-12-01"),
  ymd("2016-09-01"),
  by = "1 month") %>%
  format("%Y%m")

df_list <- dates %>% pblapply(extract_data)
bitcointalk <- df_list %>% bind_rows() %>%
  mutate_each(funs(as.numeric), 2:6) %>%
  mutate(date = as.Date(date))

bitcointalk %>% save_data("bitcointalk")
