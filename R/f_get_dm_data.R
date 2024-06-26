# get drought monitor data

# drought monitor data here for direct click option:

# and here for API download: # https://droughtmonitor.unl.edu/DmData/DataDownload/WebServiceInfo.aspx#comp

## USING AOI for HUBS:
# aoi=c(1,7,10) (CA, Northwest, Southwest)
# aoi

library(glue)
library(dplyr)
library(rio)
library(httr)
library(xml2)
library(lubridate)
#library(purrr)
#library(tigris)


f_get_dm_data <- function(area="ClimateHubStatistics",
                          stats_type="GetDroughtSeverityStatisticsByAreaPercent",
                          aoi=c(1,7,10), statid=2, end_date=NULL, id_out="west"){

  # check parameters
  if(!area %in% c("StateStatistics", "CountyStatistics",
                  "HUCStatistics", "ClimateHubStatistics")){
    stop("Not a valid area. See https://droughtmonitor.unl.edu/DmData/DataDownload/WebServiceInfo.aspx")
  }

  if(!stats_type %in% c("GetDroughtSeverityStatisticsByArea",
                        "GetDroughtSeverityStatisticsByAreaPercent",
                        "GetDSCI")){
    stop("Not a valid stat. See https://droughtmonitor.unl.edu/DmData/DataDownload/WebServiceInfo.aspx")
  }

  # AOIs:
  # CA FIPS: 06, County FIPS (06 + XXX)
  # fips <- tigris::list_counties(state = "CA")

  # hubs <- list("California" = 1, "Caribbean" = 2, "Midwest" = 3,"Northeast" = 4,"Northern Forests" = 5,"Northern Plains" = 6,"Northwest" = 7,"Southeast"  = 8,"Southern Plains" = 9,"Southwest" = 10)
  # hubs <- purrr::map_df(hubs, unlist) %>% t() %>% as.data.frame() %>% rownames_to_column("state") %>% rename(fips=2)

  # national: "us", "conus"

  # hucs: HUC ID number (for 2, 4, 6 and 8 digit) (i.e. NFA=18020128)
  aoi_str <- glue_collapse(aoi, ",")

  # GET Recent data
  dm_curr_file <- glue("data_raw/dm_{area}_{id_out}_current.json.zip")
  if(file.exists(dm_curr_file)){
    dm_curr <- import(dm_curr_file)
    # get latest record date:
    last_record <- max(as_date(dm_curr$MapDate))
  } else({
    last_record <- NULL
  })

  # START/END Dates: formatted: M/D/YYYY
  if(is.null(end_date)){
    end_date <- format(Sys.Date(), format="%m/%d/%Y") # get curr date
  }

  # start_date <- "10/1/1999" # same time frame for all
  # get records from last recorded year to minimize download time
  if(is.null(last_record)){
    start_date <- "10/1/1999"
  } else({
    start_date <- as.character(glue("10/1/{year(last_record)-1}"))
  })

  # 1 for traditional or 2 for categorical.
  if(!statid %in% c(1, 2)){
    stop("Not a valid stat. See https://droughtmonitor.unl.edu/DmData/DataDownload/WebServiceInfo.aspx")
  }
  # id_out
  # a label for saving the file (i.e., west, ca, huc8, huc12, etc)

  # get data:
  print("Downloading data...")

  # set path
  dm_path <- glue("https://usdmdataservices.unl.edu/api/{area}/{stats_type}?aoi={aoi_str}&startdate={start_date}&enddate={end_date}&statisticsType={statid}")

  # Get info
  dm_get <- GET(url=dm_path)

  # convert to dataframe
  dm_df <- jsonlite::fromJSON(content(dm_get, "text"))

  print("Data downloaded!")

  # join data
  if(!is.null(last_record)){
    dm_df <- full_join(dm_df, dm_curr)
  }

  # write out general to json
  rio::export(dm_df, file=glue("data_raw/dm_{area}_{id_out}_current.json.zip"))

  # now zip
  #zip(zipfile = glue("data_raw/dm_{area}_{id_out}_{gsub('-','', Sys.Date())}.json.zip"), files = glue("data_raw/dm_{area}_{id_out}_current.json"))

  # print message!
  print(glue("Data saved and zipped here: data_raw/dm_{area}_{id_out}_{gsub('-','', Sys.Date())}"))

  # make path to updated data:
  df_path <- glue("data_raw/dm_{area}_{id_out}_current.json.zip")

  return(df_path)
}
