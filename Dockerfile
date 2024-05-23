FROM edence/rcore:1
LABEL maintainer="edenceHealth <info@edence.health>"

ARG AG="apt-get -yq --no-install-recommends"
ARG DEBIAN_FRONTEND="noninteractive"

RUN set -eux; \
  $AG update; \
  $AG install \
    awscli \
  ; \
  $AG autoremove; \
  $AG autoclean; \
  $AG clean; \
  rm -rf \
    /var/lib/apt/lists/* \
    /var/lib/dpkg/*-old \
    /var/cache/debconf/*-old \
    /var/cache/apt \
  ;

ARG GITHUB_PAT

WORKDIR /app

COPY renv.txt ./
RUN --mount=type=cache,sharing=private,target=/renv_cache \
  set -eux; \
  Rscript \
    -e 'renv::init();' \
    -e 'renv::install(readLines("renv.txt"));' \
    -e 'renv::update();' \
    -e 'renv::isolate();' \
    -e 'renv::snapshot(type="all");' \
  ;

# # https://ohdsi.github.io/DatabaseConnector/articles/Connecting.html#the-jar-folder
ENV DATABASECONNECTOR_JAR_FOLDER="/usr/local/lib/DatabaseConnectorJars"
RUN Rscript \
    -e 'library(DatabaseConnector)' \
    -e 'downloadJdbcDrivers("all", method="libcurl")' \
  ;

RUN set -eux; \
  printf '\n%s\n' 'source("/app/renv/activate.R")' \
    | tee -a /etc/R/Rprofile.site;


# WORKDIR /output

COPY ["achilles.R", "/app/"]
# USER nonroot

ENTRYPOINT ["/usr/bin/Rscript", "/app/achilles.R"]
