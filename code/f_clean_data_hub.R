# clean data

f_clean_data_hub <- function(data){

  require(lubridate)
  library(stringr)
  library(tidyr)
  require(dplyr)
  library(glue)

  # setup params:
  hub_northwest <- c("AK", "OR", "ID", "WA")
  hub_california <- "CA"
  hub_southwest <- c("AZ", "HI", "NM", "NV", "UT")
  hubs_order <- c("Northwest", "California", "Southwest")

  # percent cat data: -------------
  dm_perc_cat_hub <-
    data %>%
    # filter to just Northwest, CA and Southwest
    filter(Name %in% c("California", "Northwest", "Southwest")) %>%
    mutate(
      across(c(MapDate, ValidStart, ValidEnd), as_date),
      across(None:D4, ~as.numeric(.x) / 100),
      Name = stringr::str_remove(Name, "\\\\n"),
      Name = str_replace(Name, "Nothern", "Northern")
    ) %>%
    rename("date" = "MapDate", "hub" = "Name") %>%
    pivot_longer(
      cols = c(None:D4),
      names_to = "category",
      values_to = "percentage"
    ) %>%
    filter(category != "None") %>%
    mutate(category = factor(category)) %>%
    dplyr::select(-ValidStart, -ValidEnd, -StatisticFormatID) %>%
    mutate(
      year = year(date),
      week = week(date),
      hub = factor(hub, levels = hubs_order, labels = hubs_order)
    ) %>%
    group_by(year) %>%
    mutate(max_week = max(week)) %>% ## for var
    ungroup() %>%
    filter(percentage > 0)
  return(dm_perc_cat_hub)
}
