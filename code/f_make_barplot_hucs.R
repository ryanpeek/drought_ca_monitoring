# make plot

f_make_barplot_hucs <- function(data, ca_hucs, huc_level="huc8",huc_id=NULL,
                                huc_name=NULL){

  ## Color palette hubs
  #greys <- c(0, 60, 40, 60, 0, 40, 60, 0)
  #pal1 <- paste0("grey", greys)
  suppressPackageStartupMessages({
    library(colorspace);
    library(shades);
    library(ggplot2);
    library(glue);
    library(cowplot);
    library(sf);
    library(dplyr);
    library(ggtext);
    library(patchwork);
    library(systemfonts)
  })
  fnt <- "Roboto Slab" # try Barlow or Roboto
  fnt2 <- "Roboto Condensed"

  # get HUC layer
  # 18040013, Upper Cosumnes
  # American c("18020111", "18020128", "18020129")
  huc_dat <- ca_hucs[[huc_level]]

  # now filter by huc_id
  if(!is.null(huc_id)){
    if(all(huc_id %in% huc_dat$huc)){
      huc_filt <- dplyr::filter(huc_dat, huc %in% huc_id)
      print("huc_id found...filtering!")
    } else({
      stop("Not a valid huc_id...check again")
    })
  } else(
    print("huc_id is NULL.")
  )

  # filter by huc_name
  if(!is.null(huc_name)){
    if(all(huc_name %in% huc_dat$name)){
      huc_filt <- dplyr::filter(huc_dat, name %in% huc_name)
      print("huc_name found...filtering!")
    } else({
      stop("Not a valid huc_name...check again")
    })
  } else(
    print("huc_name is NULL.")
  )

  if(length(huc_filt)>0) {
    huc_out <- huc_filt
  } else({
    stop("No data selected.")
  })

  # join data
  dat_sf <- huc_out %>%
    select(huc, name, geometry) %>%
    left_join(data, multiple="all")

  # trim data
  dat_filt <- data %>% filter(huc %in% huc_id)
  dat_filt %>% distinct(.keep_all = TRUE) -> dat_filt

  # get plot of huc shapes
  gg_huc <- ggplot() +
    geom_sf(data=ca_hucs$ca, col="gray30", fill=NA, linewidth=1.2) +
    geom_sf(data=huc_out, col="orange4", fill="gray60", lwd=0.2, alpha=0.7) +
    labs(caption = glue("NHD: {huc_level}"))+
    ggrepel::geom_text_repel(data=huc_out, family = fnt,
                             aes(label = huc,
                                 geometry = geometry),
                             stat = "sf_coordinates",
                             force = 10,box.padding = 1,
                             min.segment.length = 0.2) +
    #geom_sf_text(data=huc_out, aes(label=huc), family="Roboto Slab")+
    cowplot::theme_map(font_family = fnt)
    #cowplot::theme_minimal_grid()

  # get plot of condition
  bars <-
    ggplot(dat_filt, aes(wyweek, percentage)) +
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
    facet_grid(rows = vars(wyear), cols = vars(huc), switch = "y") +
    coord_cartesian(clip = "off") +
    #scale_x_continuous(expand = c(.02, .02), guide = "none", name = NULL) +
    scale_x_continuous(expand = c(.02, .02), breaks=c(1, 14, 27, 40), labels= c("Oct","Jan","Apr","Jul"), name = NULL) +  #guide = "none")+
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
      #axis.line.x = element_blank(),
      axis.line.x = element_line(color = "black", linewidth = .1),
      axis.ticks.x = element_line(color = "black", linewidth = .1),
      axis.line.y = element_line(color = "black", linewidth = .2),
      axis.ticks.y = element_line(color = "black", linewidth = .2),
      axis.ticks.length.y = unit(2, "mm"),
      legend.position = "top",
      legend.justification = c(0.15, 1),
      legend.title = element_text(color = "#2DAADA", size = 16, face = "bold"),
      legend.text = element_text(color = "#2DAADA", size = 15),
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
  ggsave(here::here(glue("figs/drought_bars_{huc_level}_{gsub('-','',Sys.Date())}.pdf")), width = 14.5, height = 11.8, device = cairo_pdf)

  # use patchwork to plot
  gg_final <- bars + gg_huc + plot_layout(guides = 'auto')

  ggsave(plot = gg_final, filename = here::here(glue("figs/drought_bars_{huc_level}_w_map_{gsub('-','',Sys.Date())}.pdf")), width = 14.5, height = 11.8, device = cairo_pdf)
  #ggsave(plot = gg_final, filename = here::here(glue("figs/drought_bars_{huc_level}_w_map_{gsub('-','',Sys.Date())}.png")), width = 14.5, height = 11.8, bg="white")


}
