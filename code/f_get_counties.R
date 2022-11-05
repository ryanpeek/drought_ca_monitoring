# get county data

library(dplyr)
library(tigris)
library(glue)
library(readr)

# function
f_get_counties <- function(){
  if(!file.exists("data_raw/ca_cnty_fips.rds")){
    fips <- tigris::list_counties(state = "CA") %>%
      mutate(ca_cnty_fips = glue("06{county_code}"))
    write_rds(fips, file = "data_raw/ca_cnty_fips.rds")
    print("File saved")
    return(fips)
  } else({
    print("File exists...loading fips")
    fips <- read_rds("data_raw/ca_cnty_fips.rds")
    return(fips)})
}

