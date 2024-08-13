
#REALISTIC 3D ELEVATION MAPS TUTORIAL
#------------------------------------

install.packages("devtools")
install.packages("remotes")

# Install rayvista
devtools::install_github("h-a-graham/rayvista", dependencies = TRUE)

# Install elevatr
devtools::install_github("jhollist/elevatr")

# Install rayrender
remotes::install_github("tylermorganwall/rayrender")

# Install rgl
remotes::install_github("dmurdoch/rgl")

# Install rayshader
remotes::install_github("tylermorganwall/rayshader")

# Load libraries
library(rayvista)
library(elevatr)
library(rayshader)
library(sf)


# 1. RAYVISTA - PLACE
#--------------------

durmitor_lat <- 43.100
durmitor_long <- 19.0167

durmitor <- rayvista::plot_3d_vista(
  lat = durmitor_lat,
  long = durmitor_long,
  radius = 3500,
  zscale = 5,
  zoom = .8,
  solid = F,
  elevation_detail = 13,
  overlay_detail = 15,
  theta = 0,
  windowsize = 800
)

# render camera to adjust the scene view

rayshader::render_camera(
  zoom = .7, theta = 0, phi = 30
)

#rayshader::render_highquality(
#  filename = "durmitor_highqual.png",
#  preview = T,
#  light = T,
#  lightdirection = 225,
#  lightintensity = 1200,
#  lightaltitude = 60,
#  interactive = F,
#  width = 4000,
#  height = 4000
#)

getwd()
setwd("C:\\Users\\Admin\\Desktop\\github\\maps\\r\\3d_elevation_tutorial\\maps")

rayshader::render_highquality(
  filename = "durmitor_highqual.png",
  preview = TRUE,
  light = TRUE,
  lightdirection = 225,
  lightintensity = 1200,
  lightaltitude = 60,
  interactive = FALSE,
  width = 500,
  height = 500
)

# 2. RAYVISTA - AREA
#--------------------
# 120.965824,13.977382,121.023159,14.048333

crsLONGLAT <- "+proj=longlat +datum=WGS84 +no_defs"

get_area_bbox <- function(){
  xmin <- 120.965824
  ymin <- 13.977382
  xmax <- 121.023159
  ymax <- 14.048333
  
  bbox <- sf::st_sfc(
    sf::st_polygon(
      list(
        cbind(
          c(xmin, xmax, xmax, xmin, xmin),
          c(ymin, ymin, ymax, ymax, ymin)
        )
      )
    ), crs = crsLONGLAT
  ) |> sf::st_as_sf()
  
  return(bbox)
}

taal_bbox <- get_area_bbox()

rgl::close3d()

taal_dem <- rayvista::plot_3d_vista(
  req_area = taal_bbox,
  phi = 80,
  theta = 0,
  elevation_detail = 13,
  overlay_detail = 16,
  zscale = 1,
  solid = F,
  outlier_filter = .001,
  zoom = .65,
  windowsize = c(500, 500)
)

rayshader::render_snapshot(
  filename = "taal.png",
  clear = T
)


# 3. RAYVISTA - COUNTRY
#--------------------

install.packages("giscoR")

get_ireland_sf <- function(){
  
  ireland_sf <- giscoR::gisco_get_countries(
    country = "IE",
    resolution = "1"
  ) |>
    sf::st_transform(crs = crsLONGLAT)
  
  return(ireland_sf)
}

ireland_sf <- get_ireland_sf()

get_elevation_data <- function(){
  country_elevation <- elevatr::get_elev_raster(
    locations = ireland_sf,
    z = 7,
    clip = "locations"
  )
  
  return(country_elevation)
}

country_elevation <- get_elevation_data()
names(country_elevation) <- "elevation"

rgl::close3d()

ireland_dem <- rayvista::plot_3d_vista(
  dem = country_elevation$elevation,
  overlay_detail = 11,
  zscale = 10,
  zoom = .8,
  phi = 85,
  theta = 0,
  solid = F,
  windowsize = c(300, 300)
)

rayshader::render_highquality(
  filename = "ireland-dem.png",
  preview = T,
  light = T,
  lightdirection = 225,
  lightintensity = 1200,
  lightaltitude = 60,
  parallel = T,
  interactive = F,
  width = 500,
  height = 500
)

rgl::close3d()