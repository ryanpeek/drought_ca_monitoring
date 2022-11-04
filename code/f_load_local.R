# load data using a contentID check

library(dplyr)
#library(contentid)
library(rio)
library(glue)

# example: dm_ClimateHubStatistics_20221104.json
#dm_file <- "dm_ClimateHubStatistics_current.json"

f_load_local <- function(dm_file) {
  # get raw data ID:
  #dat_id <- contentid::store(glue("data_raw/{dm_file}"))
  #dat_check <- contentid::resolve(dat_id)

  # read in data
  dat <- import(glue("data_raw/{dm_file}"))

  print("Data loading complete.")

  return(dat)

}
