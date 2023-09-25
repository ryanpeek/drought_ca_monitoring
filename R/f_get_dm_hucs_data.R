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


f_get_dm_hucs_data <- function(area="HUCStatistics",
                          stats_type="GetDroughtSeverityStatisticsByAreaPercent",
                          huc_level="8",
                          aoi="18",
                          #aoi=c("18020111", "18020128", "18020129"),
                          statid=2,
                          end_date=NULL,
                          id_out="h08"){

  # huc_level and it takes 2, 4, 6 or 8,
  # allows downloading all data at a given level for HUCs within the X digit HUC specified in the aoi
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

  # GET Recent data
  dm_curr_file <- glue("data_raw/dm_{area}_{id_out}_current.json.zip")
  if(file.exists(dm_curr_file)){
    dm_curr <- import(dm_curr_file)
    # get latest record date:
    last_record <- max(as_date(dm_curr$MapDate))
  } else({
    last_record <- NULL
  })

  # hucs: HUC ID number (for 2, 4, 6 and 8 digit) (i.e. NFA=18020128)
  aoi_str <- glue_collapse(aoi, ",")

  # START/END Dates: formatted: M/D/YYYY

  # get records from last recorded year to minimize download time
  if(is.null(last_record)){
    start_date <- "10/1/1999"
  } else({
      start_date <- as.character(glue("10/1/{year(last_record)-1}"))
  })

  if(is.null(end_date)){
    end_date <- format(Sys.Date(), format="%m/%d/%Y") # get curr date
    }

  # 1 for traditional or 2 for categorical.
  if(!statid %in% c(1, 2)){
    stop("Not a valid stat. See https://droughtmonitor.unl.edu/DmData/DataDownload/WebServiceInfo.aspx")
  }

  # get data:
  print("Downloading data...")

  # set path
  # but in batches to make download more reasonable (no more than 5 hucs at a time?)
  dm_path <- glue("https://usdmdataservices.unl.edu/api/{area}/{stats_type}?aoi={aoi_str}&hucLevel={huc_level}&startdate={start_date}&enddate={end_date}&statisticsType={statid}")

  # Get info
  dm_get <- GET(url=dm_path)

  # convert to dataframe
  dm_df_tmp <- jsonlite::fromJSON(content(dm_get, "text"))

  print("Data downloaded!")

  # filter to anything newer than last date
  if(!is.null(last_record)){
    dm_df_flt <- dplyr::filter(dm_df_tmp, as_date(dm_df_tmp$MapDate) > last_record)
    dm_df <- bind_rows(dm_curr, dm_df_tmp) %>%
      distinct(.keep_all = TRUE)
    # drop duplicates
  } else ({
    dm_df <- dm_df_tmp
  })
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
