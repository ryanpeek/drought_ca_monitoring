
## Mapping Drought Over Time -----



# Libraries & Setup -------------------------------------------------------

library(targets)
#library(tarchetypes)

tar_option_set(packages = "tidyverse")
suppressPackageStartupMessages(library(tidyverse, quietly = TRUE))
options(tidyverse.quiet=TRUE)

# source code
tar_source("code/")

# list the steps
list(
  # rule to download USDA Climate Hubs:
  ## California = 1, Caribbean = 2, Midwest = 3, Northeast = 4, Northern Forests = 5, Northern Plains = 6, Northwest = 7, Southeast  = 8, Southern Plains = 9, Southwest = 10
  tar_target(download_hub,
             command = f_get_dm_data(aoi = c(1,7,10))),
  tar_target(download_hub_dsci,
             command = f_get_dm_data(
               aoi = c(1,7,10),
               stats_type="GetDSCI",
               id_out = "dsci_west")),

  # rule to download counties
  tar_target(cnty_fips, f_get_counties() %>%
               filter(county %in%
                        c("Yolo", "Stanislaus", "Tulare", "Kern"))),
  # download county data
  tar_target(download_cnty,
             command = f_get_dm_data(
               area = "CountyStatistics",
               aoi = c(cnty_fips$ca_cnty_fips),
               id_out = "cnty")),

  # get hucs and ca boundary
  tar_target(ca_hucs,
             f_get_hucs()),
  # download by hucs of CA
  tar_target(download_hucs,
             command = f_get_dm_data(
               area = "HUCStatistics",
               aoi = c(ca_hucs$huc8$huc),
               id_out = "h08")),

  # load the local data
  tar_target(read_hub, f_load_local(download_hub)),
  tar_target(read_hub_dsci, f_load_local(download_hub_dsci)),
  tar_target(read_cnty, f_load_local(download_cnty)),
  tar_target(read_hucs, f_load_local(download_hucs)),

  # clean data
  tar_target(clean_dat_hub, f_clean_data_hub(read_hub)),
  tar_target(clean_dat_cnty, f_clean_data_cnty(read_cnty)),
  tar_target(clean_dat_hucs, f_clean_data_hucs(read_hucs)),
  tar_target(clean_dat_hub_dsci, f_clean_data_hub_dsci(read_hub_dsci)),

  # make plot
  tar_target(make_plot_hub, f_make_barplot_hub(clean_dat_hub, 2010)),
  tar_target(make_plot_cnty, f_make_barplot_cnty(clean_dat_cnty)),
  # pull info for American
  tar_target(make_plot_hucs, f_make_barplot_cnty(clean_dat_huc, huc_level="huc8",huc_id=c("18020111", "18020128", "18020129")))
)

