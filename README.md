# ImmuneSpaceAPI

<!-- badges: start -->
[![R-CMD-check](https://github.com/RGLab/ImmuneSpaceAPI/workflows/R-CMD-check/badge.svg)](https://github.com/RGLab/ImmuneSpaceAPI/actions)
[![docker](https://github.com/RGLab/ImmuneSpaceAPI/actions/workflows/docker-build.yaml/badge.svg)](https://hub.docker.com/r/rglab/immunespaceapi)
[![Codecov test coverage](https://codecov.io/gh/RGLab/ImmuneSpaceAPI/branch/main/graph/badge.svg)](https://codecov.io/gh/RGLab/ImmuneSpaceAPI?branch=main)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://www.tidyverse.org/lifecycle/#stable)
<!-- badges: end -->

This package holds all API endpoints for use within ImmuneSpace internally by reports or front-end elements. The `inst/api/main.R` script defines all the endpoints used by `plumber::plumb()` that is started when a docker container is created from an image defined by the `inst/Dockerfile`. The endpoint functions are simple wrappers for private functions in the `/R` directory. Since these higher level private functions depend on file inputs often, the unit tests are focused on the analysis and data munging functionality.

## Local Development

To do local development, the file-loading function `loadLocalFile()` that pulls in .rds artifacts for munging is found in `utils.R`. It looks for a `localPath` environmental variable specifying the local path to use. If this is not found, then it assumes the location is the server and will use the `/app` directory specified during the `docker run` command. So, it is recommended to put `localPath` in your .Renviron file.

```sh
mkdir /share/resources
scp rsT:'/share/resources/*.rds' /share/resources

cd /labkey/git
git clone https://github.com/RGLab/ImmuneSpaceAPI.git
cd ImmuneSpaceAPI
git checkout dev
docker build -t immunespaceapi .
docker run -p 1169:8000 -v /share/resources:/app immunespaceapi
```

## Server Deployment

After changes are made locally, push changes to the respective branch on GitHub. GitHub Actions will build and push the image to Docker Hub and GitHub Packages.

Pull the latest image on the wsT/wsP machine and start a new container with a command that includes an "always" restart policy:

```sh
# on wsT
ssh wsT
s
docker pull rglab/immunespaceapi:dev
docker run -d --restart always -p 1169:8000 -v /share/resources:/app rglab/immunespaceapi:dev

# on wsP
ssh wsP
s
docker pull rglab/immunespaceapi:latest
docker run -d --restart always -p 1169:8000 -v /share/resources:/app rglab/immunespaceapi:latest
```

## Proxy Note

- In order to ensure that the API is accessible via the web, then an ImmuneSpace administrator must set the path within LabKey
- gear symbol > folder  > management > module properties > property: target uri) to the localhost (http://localhost:8000/).
- Importantly this is not 'https'.

## Extending

- Add endpoint in the `inst/api/main.R`
- Add functions in `/R` with the format `<ModuleName>_<endpointName>.R`

## Resources

- https://github.com/rstudio/plumber/blob/master/Dockerfile
- https://www.rplumber.io/articles/hosting.html#docker-basic-
