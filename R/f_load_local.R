# load data using a contentID check

library(dplyr)
#library(contentid)
library(rio)
library(glue)

f_load_local <- function(dm_file) {
  # get raw data ID:
  #dat_id <- contentid::store(glue("{dm_file}"))
  #dat_check <- contentid::resolve(dat_id)

  # read in data
  dat <- import(glue("{dm_file}"))

  print("Data loading complete.")

  return(dat)

}
