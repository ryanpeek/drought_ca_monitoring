
## Mapping Drought Over Time -----



# Libraries & Setup -------------------------------------------------------

library(targets)
library(tarchetypes)
library(glue)
tar_option_set(packages = "tidyverse")
suppressPackageStartupMessages(library(tidyverse, quietly = TRUE))
options(tidyverse.quiet=TRUE)

# source code
tar_source("code/")

# list the steps
list(
  # rule to download hubs
  tar_target(download_hub,
             command = f_get_dm_data(aoi = c(1,7,10))),

  # rule to download counties
  tar_target(cnty_fips, f_get_counties() %>%
               filter(county %in%
                        c("Yolo", "Butte", "Sutter", "Colusa"))),
  tar_target(download_cnty,
             command = f_get_dm_data(
               area = "CountyStatistics",
               aoi = c(cnty_fips$ca_cnty_fips))),

  # load the local data
  tar_target(read_hub, f_load_local(download_hub)),
  tar_target(read_cnty, f_load_local(download_cnty)),

  # clean data
  tar_target(clean_dat_hub, f_clean_data_hub(read_hub)),
  tar_target(clean_dat_cnty, f_clean_data_cnty(read_cnty)),

  # make plot
  tar_target(make_plot_hub, f_make_barplot_hub(clean_dat_hub)),
  tar_target(make_plot_cnty, f_make_barplot_cnty(clean_dat_cnty))
)

