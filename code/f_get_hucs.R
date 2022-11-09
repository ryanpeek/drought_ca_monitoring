# get county data
suppressPackageStartupMessages({
  library(dplyr);
  library(nhdplusTools);
  library(tigris);
  library(sf);
  library(glue);
  library(readr)
})

# function to download and store a list of huc8 and huc12s for CA
f_get_hucs <- function(){
  if(!file.exists("data_raw/ca_hucs_h8.rds")){
    ca <- tigris::states(progress_bar=FALSE) %>%
      filter(STUSPS == "CA")
    write_rds(ca, file = "data_raw/ca_state_boundary.rds")
  } else({
    print("loading ca boundary")
    ca <- read_rds("data_raw/ca_state_boundary.rds")})
  if(!file.exists("data_raw/ca_hucs_h8.rds")){
    h8 <- nhdplusTools::get_huc8(AOI = ca)
    write_rds(h8, file = "data_raw/ca_hucs_h8.rds", compress = "gz")
    print("HUC8 file saved!")
    h12 <- nhdplusTools::get_huc12(AOI = ca)
    write_rds(h12, file = "data_raw/ca_hucs_h12.rds", compress = "gz")
    print("HUC12 file saved!")
    return(list("ca"=ca, "h8"=h8, "h12"=h12))
  } else({
    print("File exists...loading hucs")
    h8 <- read_rds("data_raw/ca_hucs_h8.rds")
    h12 <- read_rds("data_raw/ca_hucs_h12.rds")
    return(list("ca"=ca, "h8"=h8, "h12"=h12))})
}

# dat<- f_get_hucs()
# plot(dat$h12$geometry, border="darkblue", lwd=0.1)
# plot(dat$h8$geometry, border="orange", lwd=1, add=TRUE)
# plot(dat$ca$geometry, border="gray30", lwd=6, add=TRUE)
