save_data <- function(df, name){
  write.csv(df, paste0("data/", name, ".csv"), row.names = F)
  saveRDS(df, paste0("data/", name, ".rda"))
}
