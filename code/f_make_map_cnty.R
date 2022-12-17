# make plot

f_make_map_cnty <- function(data){

  ## Color palette hubs
  #greys <- c(0, 60, 40, 60, 0, 40, 60, 0)
  #pal1 <- paste0("grey", greys)
  suppressPackageStartupMessages({
    library(colorspace);
    library(shades);
    library(ggplot2);
    library(ggtext);
    library(systemfonts)
  })
  fnt <- "Roboto Slab" # try Barlow or Roboto
  fnt2 <- "Roboto Condensed"

  # plot
  bars <-
    ggplot(data, aes(week, percentage)) +
    geom_rect(aes(
      xmin = .5, xmax = max_week + .5,
      ymin = -0.005, ymax = 1),
      fill = "#f4f4f9", color = NA, size = 0.4, show.legend = FALSE  #9d9ca7, 99a4be, 8696bd
    ) +
    geom_col(
      aes(fill = category,
          fill = after_scale(addmix(darken(fill, .05, space = "HLS"), "#d8005a", .15)),
          color = after_scale(darken(fill, .2, space = "HLS"))),
      width = .9, size = 0.12
    ) +
    facet_grid(rows = vars(year), cols = vars(cnty), switch = "y") +
    coord_cartesian(clip = "off") +
    scale_x_continuous(expand = c(.02, .02), guide = "none", name = NULL) +
    scale_y_continuous(expand = c(0, 0), position = "right", labels = NULL, name = NULL) +
    scale_fill_viridis_d(
      option = "rocket", name = "Category:",
      direction = -1, begin = .17, end = .97,
      labels = c("Abnormally Dry", "Moderate Drought", "Severe Drought",
                 "Extreme Drought", "Exceptional Drought")
    ) +
    guides(fill = guide_legend(override.aes = list(size = 1))) +
    theme_light(base_size = 18, base_family = fnt) +
    theme(
      axis.title = element_text(size = 14, color = "black"),
      axis.text = element_text(family = fnt2, size = 11),
      axis.line.x = element_blank(),
      axis.line.y = element_line(color = "black", size = .2),
      axis.ticks.y = element_line(color = "black", size = .2),
      axis.ticks.length.y = unit(2, "mm"),
      legend.position = "top",
      legend.title = element_text(color = "#2DAADA", size = 18, face = "bold"),
      legend.text = element_text(color = "#2DAADA", size = 16),
      strip.text.x = element_text(size = 16, hjust = .5, face = "plain", color = "black", margin = margin(t = 20, b = 5)),
      strip.text.y.left = element_text(size = 18, angle = 0, vjust = .5, face = "plain", color = "black"),
      strip.background = element_rect(fill = "transparent", color = "transparent"),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_blank(),
      panel.spacing.x = unit(0.3, "lines"),
      panel.spacing.y = unit(0.25, "lines"),
      panel.background = element_rect(fill = "transparent", color = "transparent"),
      panel.border = element_rect(color = "transparent", size = 0),
      plot.background = element_rect(fill = "transparent", color = "transparent", size = .4),
      plot.margin = margin(rep(18, 4))
    )

  gsub("-","",Sys.Date())
  ggsave(here::here(glue("figs/drought_bars_cnty_{gsub('-','',Sys.Date())}.pdf")), width = 14.5, height = 11.8, device = cairo_pdf)
  #ggsave(here::here(glue("figs/drought_bars_cnty_{gsub('-','',Sys.Date())}.png")), width = 14.5, height = 11.8)

}
