library(sf)
library(banR)
library(sp)
library(tidyverse)
PLU <- read_sf("./Protections commerciales PLU/PLU_PSMV_PROTCOM.shp")

#* @get /protected
protected <- function(adresse) {
  tmp_df <- geocode(paste(adresse, "75019 Paris")) %>% 
    filter(type %in% "housenumber") %>% 
    arrange(desc(importance)) %>% 
    slice(1) %>% 
    select(latitude, longitude)
  coordinates(tmp_df) <- c("longitude", "latitude")
  proj4string(tmp_df) <- st_crs(4326)$proj4string
  tmp_df <- st_as_sf(tmp_df)
  tmp_df <- st_transform(tmp_df, st_crs(PLU))
  
  intersections <- st_intersects(st_buffer(tmp_df, 20), PLU, sparse = TRUE)
  
  if (length(unlist(intersections)) %in% 0) {
    return("Pas de protection commerciale")
  } else if (any((PLU %>% slice(unlist(intersections)) %>% pull(PRCA)) %in% "O")) {
    return("PRCA")
  } else if (any((PLU %>% slice(unlist(intersections)) %>% pull(PCA)) %in% "O")) {
    return("PCA")
  } else if (any((PLU %>% slice(unlist(intersections)) %>% pull(PPA)) %in% "O")) {
    return("PPA")
  } 
}


## BDCOM


library(geojsonio)
BDCOM <- geojson_read("./BDCOM/commercesparis.geojson", method = "local", what = "sp")
BDCOM <- st_as_sf(BDCOM)
BDCOM <- st_transform(BDCOM, st_crs(2154))
BDCOM <- BDCOM %>% 
  mutate_at(vars(libelle_voie, let, type_voie), funs(toupper(as.character(.)))) %>% 
  mutate_at(vars(libact, codact), funs(as.character(.)))

#* @get /bdcom
bdcom <- function(adresse, rayon, commerce) {
  tmp_df <- geocode(paste(adresse, "75019 Paris")) %>% 
    filter(type %in% "housenumber") %>% 
    arrange(desc(importance)) %>% 
    slice(1) %>% 
    select(latitude, longitude)
  coordinates(tmp_df) <- c("longitude", "latitude")
  proj4string(tmp_df) <- st_crs(4326)$proj4string
  tmp_df <- st_as_sf(tmp_df)
  tmp_df <- st_transform(tmp_df, st_crs(2154))
  
  commerce <- jsonlite::fromJSON(commerce)
 
  st_buffer(tmp_df, as.numeric(rayon)) %>% 
    st_intersection(BDCOM) %>% 
    st_set_geometry(NULL) %>% 
    filter(codact %in% commerce) %>% 
    group_by(codact) %>% 
    summarise(n = n())
}
