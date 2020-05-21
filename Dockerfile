FROM rocker/r-base
MAINTAINER Evan Henrich <ehenrich@fredhutch.org

RUN apt-get update -qq && apt-get install -y \
  git-core \
  libssl-dev \
  libcurl4-gnutls-dev \
  libxml2-dev

RUN R -e 'install.packages(c("plumber", "data.table", "uwot"))'
WORKDIR '/app'
COPY . /app/ImmuneSpaceLabKeyAPI/
RUN R CMD build --no-build-vignettes ImmuneSpaceLabKeyAPI
RUN R CMD INSTALL ImmuneSpaceLabKeyAPI_*tar.gz

EXPOSE 8000
ENTRYPOINT ["R", "-e", "pr <- plumber::plumb(commandArgs()[4]); pr$run(host='0.0.0.0', port=8000)"]
CMD ["/app/ImmuneSpaceLabKeyAPI/inst/main.R"]

