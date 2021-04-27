FROM rocker/r-base
MAINTAINER ImmuneSpace Maintainer <immunespace@gmail.com>

# plumber: libssl-dev, libcurl4-gnutls-dev
RUN apt-get update -qq && apt-get install -y \
  libssl-dev \
  libcurl4-gnutls-dev \
  libsodium-dev

# Install package dependencies first to minimize re-installation
# if only making changes to the ImmuneSpaceAPI package
RUN R -e 'install.packages(c("plumber", "data.table", "uwot"))'

# Build package from source instead of devtools::install_github
# to ensure 'main.R' script is easily accessible in container.
WORKDIR '/app'
COPY . /app/ImmuneSpaceAPI/
RUN R CMD build --no-build-vignettes ImmuneSpaceAPI
RUN R CMD INSTALL ImmuneSpaceAPI_*tar.gz

EXPOSE 8000
ENTRYPOINT ["R", "-e", "pr <- plumber::plumb(commandArgs()[4]); pr$run(host='0.0.0.0', port=8000)"]
CMD ["/app/ImmuneSpaceAPI/inst/main.R"]

