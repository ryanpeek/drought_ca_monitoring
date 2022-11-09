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
    huc8 <- nhdplusTools::get_huc8(AOI = ca)
    huc8 <- huc8 %>% rename(huc=huc8)
    write_rds(huc8, file = "data_raw/ca_hucs_h8.rds", compress = "gz")
    print("HUC8 file saved!")
    huc12 <- nhdplusTools::get_huc12(AOI = ca)
    huc12 <- huc12 %>% rename(huc=huc12)
    write_rds(huc12, file = "data_raw/ca_hucs_h12.rds", compress = "gz")
    print("HUC12 file saved!")
    return(list("ca"=ca, "huc8"=huc8, "huc12"=huc12))
  } else({
    print("File exists...loading hucs")
    huc8 <- read_rds("data_raw/ca_hucs_h8.rds")
    huc12 <- read_rds("data_raw/ca_hucs_h12.rds")
    return(list("ca"=ca, "huc8"=huc8, "huc12"=huc12))})
}

# dat<- f_get_hucs()
# plot(dat$h12$geometry, border="darkblue", lwd=0.1)
# plot(dat$h8$geometry, border="orange", lwd=1, add=TRUE)
# plot(dat$ca$geometry, border="gray30", lwd=6, add=TRUE)
