# Achilles Container

The container can be used and configured via command-line arguments (for example passed to `docker run`) or with environment variables.

## environment variables

Each command line argument has an equivalent environment variable, to determine name of the environment variable:


1. start with the argument and remote the leading dashes
2. convert to uppper-case
3. replace dashes with underscores
4. boolean, flag-style arguments like `--skip-achilles` are assumed to be false, but they can be enabled by setting them with the values: `1`, `TRUE`, `YES`, `Y`, or `ON`

For example:
  * `--skip-achilles` becomes `SKIP_ACHILLES=1`
  * `--output-base=xyz` becomes `OUTPUT_BASE=xyz`

## interactive help text

The following text is printed when invoking the container with the `-h` or `--help` arguments.

```
Achilles Wrapper

Usage:
  achilles.R [options]

General options:
  -h, --help              Show this help message.
  --num-threads=<n>       The number of threads to use when running achilles
                          [default: 1]
  --optimize-atlas-cache  Enables the optimizeAtlasCache option to the achilles
                          function
  --source-name=<name>    The source name used by the achilles function and
                          included as part of the output path [default: NA]
  --timestamp=<time_str>  The timestamp-style string to use when calculating
                          some file output paths. Defaults to a string derived
                          from the current date & time. [default: AUTO]
  --skip-achilles         This option prevents Achilles from running, which can
                          be useful for running the other utilities like the
                          DQD Shiny App
  --output-base=<str>     The output path used by achilles [default: /output]

CDM Options:
  --cdm-version=<semver>  Which standard version of the CDM to use [default: 5]

Schema Options:
  --cdm-schema=<name>     DB schema name for CDM data [default: public]
  --results-schema=<name> DB schema name for results data [default: results]
  --vocab-schema=<name>   DB schema name for vocabulary data
                          [default: vocabulary]

CDM DB Options:
  --db-dbms=<name>        The database management system for the CDM database
                          [default: postgresql]
  --db-hostname=<name>    The hostname the database server is listening on
                          [default: db]
  --db-port=<n>           The port the database server is listening on
                          [default: 5432]
  --db-name=<name>        The name of the database on the database server
                          [default: cdm]
  --db-username=<name>    The username to connect to the database server with
                          [default: pgadmin]
  --db-password=<name>    The password to connect to the database server with
                          [default: postgres]
  --db-drivers=<DIRECTORY>
        The path to the driver jar files used by the DatabaseConnector to
        connect to various DBMS
        [default: /usr/local/lib/R/site-library/DatabaseConnectorJars/java/]

JSON Export Options:
  --json-export           Whether to run the Achilles exportToJson function
  --json-compress         JSON files should be compressed into one zip file
  --json-output-base=<DIRECTORY>
        The output path used by exportToJson [default: /output]

DataQualityDashboard Options:
  --dqd                   Whether to run the DataQualityDashboard functions
  --dqd-sql-only          Return DQD queries but do not run them
  --dqd-verbose           Whether to write DataQualityDashboard info
  --dqd-json-file         Whether to write a JSON file to disk
  --dqd-skip-db-write     skip writing results to the dqdashboard_results table
                          in the results schema
  --dqd-check-names=<list>
        optional comma-separated list of check names to execute
  --dqd-check-levels=<list>
        comma-separated list of which DQ check levels to execute
        [default: TABLE,FIELD,CONCEPT]
  --dqd-exclude-tables=<list>
        comma-separated list of CDM tables to exclude from the checks
  --dqd-output-base=<DIRECTORY>
        The output path used by the dqd functions [default: /output]
  --dqd-table-threshold-file
        The optional location of the threshold file for evaluating the table
        checks; this is useful for overriding thresholds
        [default: default]
  --dqd-field-threshold-file
        The optional location of the threshold file for evaluating the field
        checks; this is useful for overriding thresholds
        [default: default]
  --dqd-concept-threshold-file
        The optional location of the threshold file for evaluating the concept
        checks; this is useful for overriding thresholds
        [default: default]

DQDWeb Options:
  --dqd-web               Whether to run the DataQualityDashboard Shiny App
  --dqd-web-host=<hostname>
        The network host address the DataQualityDashboard Shiny App should
        listen on  [default: 0.0.0.0]
  --dqd-web-port=<n>
        The network port number the DataQualityDashboard Shiny App should
        listen on [default: 5641]
  --dqd-web-display-mode=<mode>
        The Shiny App display.mode to use for the app, options include
        "showcase" or "normal" [default: normal]
  --dqd-web-input-json=<PATH>
        Optionally override the input path used by the DataQualityDashboard
        Shiny App, by default this is derived from the output path by the DQD
        step [default: AUTO]
```
