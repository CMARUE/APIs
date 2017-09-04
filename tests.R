# tests

# library(plumber)
# api <- plumb("plumber.R")
# api$run(port = 8000)

library(httr)
test <- GET("http://localhost:8000/protected", query = list(adresse = "148 rue de Crimée"))
test %>% status_code
test %>% content

test2 <- GET("http://localhost:8000/protected", query = list(adresse = "78 rue d'Hautpoul"))
test2 %>% status_code
test2 %>% content

test3 <- GET("http://localhost:8000/protected", query = list(adresse = "78 rue d'Hautpoul"))
test3 %>% status_code
test3 %>% content

test4 <- GET("http://localhost:8000/bdcom", query = list(adresse="148 rue de Crimée", rayon=200, commerce= "[CH302,SB201]"))
test4 %>% status_code # 500
test4 %>% content

test4 <- GET("http://localhost:8000/bdcom", query = list(adresse="148 rue de Crimée", rayon=200, commerce= "[CH302,SB201]"))
test4 %>% status_code # 500
test4 %>% content
