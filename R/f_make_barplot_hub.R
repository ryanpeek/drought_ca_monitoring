# make plot
# test with tar_load(clean_dat_hub)
# data <- clean_dat_hub

f_make_barplot_hub <- function(data, st_yr){

  ## Color palette hubs
  #greys <- c(0, 60, 40, 60, 0, 40, 60, 0)
  #pal1 <- paste0("grey", greys)
  suppressPackageStartupMessages({
    library(colorspace);
    library(shades);
    library(ggplot2);
    library(dplyr);
    library(ggtext);
    library(systemfonts)
    #library(agg)
  })

  fnt <- "Roboto Slab" # try Barlow or Roboto
  fnt2 <- "Roboto Condensed"

  # filter data
  data <- filter(data, wyear >= st_yr)

  # plot
  bars <-
    ggplot(data, aes(wyweek, percentage)) +
    geom_rect(aes(
      xmin = .5, xmax = max_week + .5,
      ymin = -0.005, ymax = 1),
      fill = "#f4f4f9", color = NA, linewidth = 0.4, show.legend = FALSE  #9d9ca7, 99a4be, 8696bd
    ) +
    geom_col(
      aes(fill = category,
          fill = after_scale(addmix(darken(fill, .05, space = "HLS"), "#d8005a", .15)),
          color = after_scale(darken(fill, .2, space = "HLS"))),
      width = .9, linewidth = 0.12
    ) +
    facet_grid(rows = vars(wyear), cols = vars(hub), switch = "y") +
    coord_cartesian(clip = "off") +
    scale_x_continuous(expand = c(.02, .02), breaks=c(1, 14, 27, 40), labels= c("Oct","Jan","Apr","Jul"), name = NULL) +  #guide = "none")+
    scale_y_continuous(expand = c(0, 0), position = "right", labels = NULL, name = NULL) +
    scale_fill_viridis_d(
      option = "rocket", name = "Category:",
      direction = -1, begin = .17, end = .97,
      labels = c("Abnormally Dry", "Moderate Drought", "Severe Drought",
                 "Extreme Drought", "Exceptional Drought")
    ) +
    guides(fill = guide_legend(override.aes = list(size = 1))) +
    labs(caption = glue("Data from US Drought Monitor, updated {format(Sys.Date(), format='%Y-%m-%d')}")) +
    theme_light(base_size = 18, base_family = fnt) +
    theme(
      plot.caption = element_text(size=10),
      axis.title = element_text(size = 14, color = "black"),
      axis.text = element_text(family = fnt2, size = 11),
      #axis.line.x = element_blank(),
      axis.line.x = element_line(color = "black", linewidth = .1),
      axis.ticks.x = element_line(color = "black", linewidth = .1),
      axis.line.y = element_line(color = "black", linewidth = .2),
      axis.ticks.y = element_line(color = "black", linewidth = .2),
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
      panel.border = element_rect(color = "transparent", linewidth = 0),
      plot.background = element_rect(fill = "transparent", color = "transparent", linewidth = .4),
      plot.margin = margin(rep(18, 4))
    )

  gsub("-","",Sys.Date())
  ggsave(here::here(glue("figs/drought_bars_hub_{gsub('-','',Sys.Date())}.pdf")), width = 14.5, height = 11.8, device = cairo_pdf)

  # current
  ggsave(here::here(glue("figs/drought_bars_hub_current.png")), width = 14.5, height = 11.8, bg="white")

}
