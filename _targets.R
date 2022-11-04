## TARGETS --------


## Mapping Drought Over Time -----



# Libraries & Setup -------------------------------------------------------

library(targets)
library(tarchetypes)
tar_option_set(packages = "tidyverse") #, debug = "analysis_data"
options(tidyverse.quiet=TRUE)
#suppressPackageStartupMessages(library(tidyverse, quietly = TRUE))

tar_source("code/")


# End this file with a list of target objects.
list(

  tar_target(download_dat, command = f_get_dm_data()),
  tar_target(read_local, f_load_local(download_dat)),
  tar_target(clean_dat, f_clean_data(read_local))

  #tar_target(make_figs, f_make_figs(data)),
  #tar_render(name = report, path = "docs/dtsm_weekly_update.Rmd")
)

