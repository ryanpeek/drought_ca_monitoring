# CA Drought Monitoring and Visualization

(**_This is all still a work in progress..._**)

A `{targets}` based project to pull data from the [US Drought Monitor](https://droughtmonitor.unl.edu/CurrentMap/StateDroughtMonitor.aspx?West), clean and tidy, then visualize using code adapted from Cédric Scherer and Georgios Karamanis ([code](https://github.com/gkaramanis/drought_viz_sciam-shared)). In particular, additional code has been written to convert the data to a water year calendar (Oct 1 - Sep 30), and additional faceting and datasets can be integrated more easily. 

These data can be visualized by CA county, HUC8, and Climate Hub, with additional adaptions planned focusing on using the [Drought Severity & Coverage Index](https://droughtmonitor.unl.edu/DmData/DataDownload/DSCI.aspx) (DSCI) metric in conjunction with a metric of evaporative demand.

![](figs/drought_bars_huc8_w_map_20230228.pdf)

![](figs/drought_bars_hub_20230228.pdf)

## To Run

Open the project and load the library:

```
library(targets)
```

To visualize a pipeline dependency showing the status of the various functions and steps, use:

```
tar_visnetwork()
```

Finally, to run the entire project from start to finish:

```
tar_make()
```
Re-run the `tar_visnetwork()` often to check the status and change of different rules.

## Troubleshooting and Other Things

There may be some version warnings and messages associated with changes to `ggplot2` (i.e., linewidth vs. size), these can be ignored for now.

In some cases if a rule needs to be re-run, we can invalidate the rule specifically, i.e., `tar_invalidate(download_hucs)`, and then re-run: `tar_make(download_hucs)`. We can also load specific datasets with `tar_load(<insert_target_here>)`.
