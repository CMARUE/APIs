library(sf)
library(banR)
library(sp)
library(memoise)
library(tidyverse)
PLU <- read_sf("./PLU/PLU_PSMV_PROTCOM.shp", stringsAsFactors = FALSE)

fc <- cache_filesystem("~/.Rcache")
m_geocode <- memoise(geocode, cache = fc)


#* @filter cors
cors <- function(res) {
  res$setHeader("Access-Control-Allow-Origin", "*") # Or whatever
  plumber::forward()
}



protected_internal <- function(adresse) {
  tmp_df <- geocode(adresse) %>% 
    filter(type %in% "housenumber") %>% 
    arrange(desc(importance)) %>% 
    slice(1) %>% 
    select(latitude, longitude)
  if (nrow(tmp_df) %in% 0) {
    return("Cette adresse ne figure pas dans le PLU")
  }
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

m_protected_internal <- memoise(protected_internal, cache = fc)

#* @get /protected
protected <- function(adresse) {
  m_protected_internal(adresse)
}


## BDCOM


library(geojsonio)
BDCOM <- geojson_read("./BDCOM/commercesparis.geojson", method = "local", what = "sp", stringsAsFactors = FALSE)
BDCOM <- st_as_sf(BDCOM)
BDCOM <- st_transform(BDCOM, st_crs(2154))
BDCOM <- BDCOM %>% 
  mutate_at(vars(libelle_voie, let, type_voie), funs(toupper(.)))


bdcom_internal <- function(adresse, rayon, commerce) {
  
  adresse_std <- adresse %>% 
    toupper() %>% 
    stringr::str_replace_all(", ", "") %>% 
    stringr::str_replace_all("[ÉÈ]", "E") %>%
    stringr::str_replace_all("À", "A") %>%
    stringr::str_replace_all("Ç", "C") %>%
    stringr::str_replace_all("Ù", "U") %>%
    stringr::str_replace_all(" BOULEVARD", " BD") %>% 
    stringr::str_replace_all(" PLACE", " PL") %>%
    stringr::str_replace_all(" AVENUE", " AV") %>%
    stringr::str_replace_all(" IMPASSE", " IMP") %>%
    stringr::str_replace_all(" CARREFOUR", " CAR") %>%
    stringr::str_replace_all(" PASSAGE", " PAS") %>%
    stringr::str_replace_all(" VILLA", " VLA") %>%
    stringr::str_replace_all(" QUAI", " QU") %>%
    stringr::str_replace_all(" ALLEE", " ALL") %>%
    stringr::str_replace_all(" R[ON] *D[- ]POINT", "RPT") %>%
    stringr::str_replace_all(" SQUARE", " SQ") %>%
    stringr::str_replace_all(" CHAUSSEE", " CHAU") %>%
    stringr::str_replace_all(" COURS", " CRS") %>%
    stringr::str_replace_all(" SENTE", " SENT") %>%
    stringr::str_replace_all(" GALERIE", " GAL") %>%
    stringr::str_replace_all(" ROUTE", " RTE") %>%
    stringr::str_replace_all(" CHEMIN", " CHEM") %>%
    stringr::str_replace_all(" DE [LA ]*", " ") %>%
    stringr::str_replace_all(" DU ", " ") %>%
    stringr::str_replace_all(" DES ", " ") %>%
    stringr::str_replace_all(" L'", " ")
    
    
tmp_df <- BDCOM %>% 
  filter(adresse_complete %in% adresse_std)
    
if (nrow(tmp_df) > 0) {
  tmp_df <- tmp_df %>% 
    slice(1)
} else {
  tmp_df <- geocode(adresse) %>% 
    filter(type %in% "housenumber") %>% 
    arrange(desc(importance)) %>% 
    slice(1) %>% 
    select(latitude, longitude)
  coordinates(tmp_df) <- c("longitude", "latitude")
  proj4string(tmp_df) <- st_crs(4326)$proj4string
  tmp_df <- st_as_sf(tmp_df)
  tmp_df <- st_transform(tmp_df, st_crs(2154))
}


  
  commerce <- jsonlite::fromJSON(commerce)
  
  res <- st_buffer(tmp_df, as.numeric(rayon)) %>%
    select(geometry) %>% 
    st_intersection(BDCOM) %>% 
    st_set_geometry(NULL) %>% 
    filter(codact %in% commerce) %>% 
    group_by(codact) %>% 
    summarise(n = n())
  if (nrow(res) %in% 0) {
    res <- data_frame(codact = commerce, n = 0)
  }
  return(res)
}

m_bdcom_internal <- memoise(bdcom_internal)

#* @get /bdcom
bdcom <- function(adresse, rayon = 200, commerce) {
  m_bdcom_internal(adresse, rayon, commerce)
}
