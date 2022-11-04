## TARGETS --------


## Mapping Drought Over Time -----



# Libraries & Setup -------------------------------------------------------

library(targets)
library(tarchetypes)
suppressPackageStartupMessages(library(tidyverse, quietly = TRUE))
library(fs)
library(glue)
library(sf)
tar_source("code/")
options(tidyverse.quiet=TRUE)
# Set target-specific options such as packages.
tar_option_set(packages = "tidyverse") #, debug = "analysis_data"

# End this file with a list of target objects.
list(

  tar_target(name = get_data, command = f_get_dm_data())
  #tar_target(make_figs, f_make_figs(data)),
  #tar_render(name = report, path = "docs/dtsm_weekly_update.Rmd")
)

