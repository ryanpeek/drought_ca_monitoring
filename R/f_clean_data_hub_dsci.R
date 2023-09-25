# clean data by hub
# tar_load(read_hub_dsci)

f_clean_data_hub_dsci <- function(data){

  suppressPackageStartupMessages({
    library(lubridate);
    library(stringr);
    library(tidyr);
    library(dplyr);
    library(glue);
    library(dataRetrieval)
  })

  # setup params:
  hub_northwest <- c("AK", "OR", "ID", "WA")
  hub_california <- "CA"
  hub_southwest <- c("AZ", "HI", "NM", "NV", "UT")
  hubs_order <- c("Northwest", "California", "Southwest")


  # percent cat data -----------------------------------------

  dm_hub_dsci <-
    data %>%
    # filter to just Northwest, CA and Southwest
    filter(Name %in% c("California", "Northwest", "Southwest")) %>%
    mutate(
      across(c(MapDate), as_date)) %>%
    rename("date" = "MapDate", "hub" = "Name", "dsci"="DSCI") %>%
    mutate(
      year = year(date),
      wyear = dataRetrieval::calcWaterYear(date),
      wyday = add_wyd(date),
      week = week(date),
      wyweek = add_wyweek(wyday),
      hub = factor(hub, levels = hubs_order, labels = hubs_order)
    ) %>%
    group_by(wyear) %>%
    mutate(max_week = max(wyweek)) %>% ## for var
    ungroup()

  return(dm_hub_dsci)
}
