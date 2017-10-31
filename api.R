library(plumber)
r <- plumb("plumber.R")  # Where 'myfile.R' is the location of the file shown above
r$run(port=1234)
