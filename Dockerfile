FROM trestletech/plumber
MAINTAINER Joel Gombin <joel.gombin@gmail.com>

RUN R -e "install.packages(c('sf', 'banR', 'sp', 'memoise', 'tidyverse', 'geojsonio'))"

CMD ["/app/protected.R"]