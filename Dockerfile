FROM edence/rcore:1
LABEL maintainer="edenceHealth <info@edence.health>"

RUN set -eux; \
  export \
    AG="apt-get -yq" \
    DEBIAN_FRONTEND="noninteractive" \
  ; \
  apt-get -yq update; \
  apt-get -yq install --no-install-recommends \
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

COPY renv.lock ./
RUN --mount=type=cache,sharing=private,target=/renv_cache \
  set -eux; \
  Rscript \
    -e 'renv::activate("/app");' \
    -e 'renv::restore();' \
    -e 'renv::isolate();' \
  ;

# https://ohdsi.github.io/DatabaseConnector/articles/Connecting.html#the-jar-folder
ENV DATABASECONNECTOR_JAR_FOLDER="/usr/local/lib/DatabaseConnectorJars"
RUN set -eux; \
  Rscript \
    -e 'renv::activate("/app")' \
    -e 'library(DatabaseConnector)' \
    -e 'downloadJdbcDrivers("oracle")' \
    -e 'downloadJdbcDrivers("postgresql")' \
    -e 'downloadJdbcDrivers("redshift")' \
    -e 'downloadJdbcDrivers("spark")' \
    -e 'downloadJdbcDrivers("sql server")' \
  ;

WORKDIR /output

COPY ["achilles.R", "entrypoint.sh", "/app/"]
USER nonroot

ENTRYPOINT ["/app/entrypoint.sh"]
