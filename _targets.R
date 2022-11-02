library(targets)
library(tarchetypes)
suppressPackageStartupMessages(library(tidyverse, quietly = TRUE))
tar_source("R/")
options(tidyverse.quiet=TRUE)
# Set target-specific options such as packages.
tar_option_set(packages = "tidyverse") #, debug = "analysis_data"

# End this file with a list of target objects.
list(

  tar_target(name = data, command = f_get_tasks("data/dtsm_weekly_tasks.xlsx")),
  tar_render(name = report, path = "docs/dtsm_weekly_update.Rmd")
)

