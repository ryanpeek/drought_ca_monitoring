# clean data by county

f_clean_data_cnty <- function(data){

  suppressPackageStartupMessages({
    library(lubridate);
    library(stringr);
    library(tidyr);
    library(dplyr);
    library(glue);
    library(dataRetrieval)
  })

  # percent cat data: -------------
  dm_perc_cat_cnty <-
    data %>%
    mutate(
      # convert to percents across
      across(c(MapDate, ValidStart, ValidEnd), as_date),
      across(None:D4, ~as.numeric(.x) / 100)) %>%
    rename("date" = "MapDate", "cnty" = "County", "state"="State") %>%
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
      wyear = dataRetrieval::calcWaterYear(date),
      wyday = add_wyd(date),
      week = week(date),
      wyweek = add_wyweek(wyday),
      cnty = as.factor(cnty)
    ) %>%
    group_by(year) %>%
    mutate(max_week = max(wyweek)) %>% ## for var
    ungroup() %>%
    filter(percentage > 0)
  return(dm_perc_cat_cnty)
}
