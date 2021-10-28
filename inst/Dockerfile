FROM rstudio/plumber
MAINTAINER ImmuneSpace Maintainer <immunespace@gmail.com>

ARG BRANCH=main
RUN Rscript -e "remotes::install_github('RGLab/ImmuneSpaceAPI@${BRANCH}')"

RUN cp /usr/local/lib/R/site-library/ImmuneSpaceAPI/api/main.R ~/plumber.R

CMD ["~/plumber.R"]
