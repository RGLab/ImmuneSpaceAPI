FROM rocker/r-base
MAINTAINER Evan Henrich <ehenrich@fredhutch.org

# plumber: libssl-dev, libcurl4-gnutls-dev
RUN apt-get update -qq && apt-get install -y \
  libssl-dev \
  libcurl4-gnutls-dev \
  libsodium-dev

# Install package dependencies first to minimize re-installation
# if only making changes to the ImmuneSpaceLabKeyAPI package
RUN R -e 'install.packages(c("plumber", "data.table", "uwot"))'

# Build package from source instead of devtools::install_github
# to ensure 'main.R' script is easily accessible in container.
WORKDIR '/app'
COPY . /app/ImmuneSpaceLabKeyAPI/
RUN R CMD build --no-build-vignettes ImmuneSpaceLabKeyAPI
RUN R CMD INSTALL ImmuneSpaceLabKeyAPI_*tar.gz

EXPOSE 8000
ENTRYPOINT ["R", "-e", "pr <- plumber::plumb(commandArgs()[4]); pr$run(host='0.0.0.0', port=8000)"]
CMD ["/app/ImmuneSpaceLabKeyAPI/inst/main.R"]

