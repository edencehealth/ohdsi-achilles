#!/usr/bin/Rscript
# Wrapper around OHDSI Achilles and OHDSI DataQualityDashboard
# edenceHealth NV <info@edence.health>

library(Achilles)
library(DataQualityDashboard)
library(stringr)
library(rbasecfg)

wrapper_version_str <- "1.9"

Config <- R6::R6Class(
  "Config",
  inherit = BaseCfg,
  public = list(
    num_threads = opt(
      default = 1,
      type = "integer",
      doc = "The number of threads to use when running achilles"
    ),
    optimize_atlas_cache = opt(
      default = false,
      type = "bool",
      doc = "Enables the optimizeAtlasCache option to the achilles function"
    ),
    source_name = opt(
      default = "NA",
      type = "string",
      doc = "The source name used by the achilles function and included as part of the output path"
    ),
    timestamp = opt(
      default = "AUTO",
      type = "string",
      doc = "The timestamp_style string to use when calculating some file output paths. Defaults to a string derived from the current date & time"
    ),
    skip_achilles = opt(
      default = false,
      type = "bool",
      doc = "This option prevents Achilles from running, which can be useful for running the other utilities like the DQD Shiny App"
    ),
    output_base = opt(
      default = "/output",
      type = "string",
      doc = "The output path used by achilles"
    ),
    s3_target = opt(
      default = "",
      type = "string",
      doc = "Optional AWS S3 bucket path to sync with the output_base directory (for uploading results to S3)"
    ),
    cdm_version = opt(
      default = 5,
      type = "string",
      doc = "Which standard version of the CDM to use"
    ),
    cdm_schema = opt(
      default = "public",
      type = "string",
      doc = "DB schema name for CDM data"
    ),
    results_schema = opt(
      default = "results",
      type = "string",
      doc = "DB schema name for results data"
    ),
    vocab_schema = opt(
      default = "omopcdm",
      type = "string",
      doc = "DB schema name for vocabulary data"
    ),
    db_dbms = opt(
      default = "postgresql",
      type = "string",
      doc = "The database management system for the CDM database"
    ),
    db_hostname = opt(
      default = "db",
      type = "string",
      doc = "The hostname the database server is listening on"
    ),
    db_port = opt(
      default = 5432,
      type = "string",
      doc = "The port the database server is listening on"
    ),
    db_name = opt(
      default = cdm,
      type = "string",
      doc = "The name of the database on the database server"
    ),
    db_username = opt(
      default = pgadmin,
      type = "string",
      doc = "The username to connect to the database server with"
    ),
    db_password = opt(
      default = postgres,
      type = "string",
      doc = "The password to connect to the database server with"
    ),
    db_extra_settings = opt(
      default = "",
      type = "string",
      doc = "Optional additional settings for the database driver (in JDBC connection format)"
    ),
    databaseconnector_jar_folder = opt(
      default = "/usr/local/lib/DatabaseConnectorJars",
      type = "string",
      doc = "The path to the driver jar files used by the DatabaseConnector to connect to various DBMS"
    ),
    json_export = opt(
      default = false,
      type = "bool",
      doc = "Whether to run the Achilles exportToJson function"
    ),
    json_compress = opt(
      default = false,
      type = "bool",
      doc = "JSON files should be compressed into one zip file"
    ),
    json_output_base = opt(
      default = "/output",
      type = "string",
      doc = "The output path used by exportToJson"
    ),
    dqd = opt(
      default = false,
      type = "bool",
      doc = "Whether to run the DataQualityDashboard functions"
    ),
    dqd_sql_only = opt(
      default = false,
      type = "bool",
      doc = "Return DQD queries but do not run them"
    ),
    dqd_verbose = opt(
      default = false,
      type = "bool",
      doc = "Whether to write DataQualityDashboard info"
    ),
    dqd_json_file = opt(
      default = false,
      type = "bool",
      doc = "Whether to write a JSON file to disk"
    ),
    dqd_skip_db_write = opt(
      default = false,
      type = "bool",
      doc = "Skip writing results to the dqdashboard_results table in the results schema"
    ),
    dqd_check_names = opt(
      default = "",
      type = "string",
      doc = "Optional comma_separated list of check names to execute"
    ),
    dqd_check_levels = opt(
      default = "TABLE,FIELD,CONCEPT",
      type = "string",
      doc = "Comma_separated list of which DQ check levels to execute"
    ),
    dqd_exclude_tables = opt(
      default = "",
      type = "string",
      doc = "Comma_separated list of CDM tables to exclude from the checks"
    ),
    dqd_output_base = opt(
      default = "/output",
      type = "string",
      doc = "The output path used by the dqd functions"
    ),
    dqd_table_threshold_file = opt(
      default = "default",
      type = "string",
      doc = "The optional location of the threshold file for evaluating the table checks; this is useful for overriding thresholds"
    ),
    dqd_field_threshold_file = opt(
      default = "default",
      type = "string",
      doc = "The optional location of the threshold file for evaluating the field checks; this is useful for overriding thresholds"
    ),
    dqd_concept_threshold_file = opt(
      default = "default",
      type = "string",
      doc = "The optional location of the threshold file for evaluating the concept checks; this is useful for overriding thresholds"
    ),
    dqd_web = opt(
      default = false,
      type = "bool",
      doc = "Whether to run the DataQualityDashboard Shiny App"
    ),
    dqd_web_host = opt(
      default = "0.0.0.0",
      type = "string",
      doc = "The network host address the DataQualityDashboard Shiny App should listen on"
    ),
    dqd_web_port = opt(
      default = 5641,
      type = "integer",
      doc = "The network port number the DataQualityDashboard Shiny App should listen on"
    ),
    dqd_web_display_mode = opt(
      default = "normal",
      type = "string",
      doc = "The Shiny App display.mode to use for the app, options include 'showcase' or 'normal'"
    ),
    dqd_web_input_json = opt(
      default = "AUTO",
      type = "string",
      doc = "Optionally override the input path used by the DataQualityDashboard Shiny App, by default this is derived from the output path by the DQD step"
    )
  )
)

cfg <- Config$new()
cat(cfg, "\n")

version_str <- paste(
  "edenceHealth Achilles/DQD Wrapper:",
  wrapper_version_str,
  "/ Achilles:",
  packageVersion("Achilles"),
  "/ DataQualityDashboard:",
  packageVersion("DataQualityDashboard"),
  "\n"
)
# args <- docopt(doc_str, version = version_str)
# arg_defaults <- docopt(doc_str, args = c(), version = version_str)
arg_names <- names(args)

# environment variables like DQD_WEB_HOST override args like --dqd-web-host if
# the args have their default value. (user-set cli args must override envvars)
for (name in arg_names[!grepl("--", arg_names, fixed = TRUE)]) {
  envvar_name <- toupper(name)
  envvar_value <- Sys.getenv(c(envvar_name), NA)
  if (!is.na(envvar_value)) {
    if (args[[name]] == arg_defaults[[name]]) {
      if (typeof(arg_defaults[[name]]) == "logical") {
        print(str_glue("Importing logical envvar {envvar_name} into {name}\n"))
        args[[name]] <- parse_bool(envvar_value)
      } else {
        print(str_glue("Importing string envvar {envvar_name} into {name}\n"))
        args[[name]] <- envvar_value
      }
    } else {
      print(str_glue("Ignoring envvar {envvar_name}, CLI arg has precedence\n"))
    }
  }
}

# arg conversions: null to string
for (i in seq_along(args)) {
  if (is.null(args[[i]])) {
    args[[i]] <- ""
  }
}

# arg conversions: string to numeric
numeric_args <- c("db_port", "dqd_web_port", "num_threads")
for (name in numeric_args) {
  args[[name]] <- as.numeric(args[[name]])
}

# arg conversions: csv to vector
args$dqd_check_names <- unlist(strsplit(args$dqd_check_names, ","))
args$dqd_check_levels <-
  toupper(unlist(strsplit(args$dqd_check_levels, ",")))
args$dqd_exclude_tables <-
  unlist(strsplit(args$dqd_exclude_tables, ","))

# arg conversions: misc
if (args$timestamp == "AUTO") {
  args$timestamp <- strftime(Sys.time(), format = "%Y-%m-%dT%H.%M.%S")
}

# achilles::achilles wants a cdmVersion argument that doesn't include a patch
# version number: "Use major release number or minor number only (e.g. 5, 5.3)"
# this regex sub strips the patch number from a semver, we want the following:
# given: return
# 5     : 5
# 5.3   : 5.3
# 5.3.1 : 5.3
# NOTE: we're storing this in args for convenience so that it gets reported on
# startup, but we're not allowing it to be set directly by cli args nor envvars
args$short_cdm_version <- sub("^(\\d+(?:\\.\\d+)?)(\\.\\d+)?$",
                              "\\1",
                              args$cdm_version,
                              perl = TRUE)

# print parsed runtime configuration to stdout at startup
filtered_args <- args
for (name in arg_names[grepl("password", arg_names, fixed = TRUE)]) {
  filtered_args[name] <- "REDACTED"
}
for (name in arg_names[grepl("--", arg_names, fixed = TRUE)]) {
  filtered_args[name] <- NULL
}
filtered_args["help"] <- NULL
cat("Runtime configuration:\n")
print(filtered_args)

valid_dbms <- list(
  "bigquery",
  "netezza",
  "oracle",
  "pdw",
  "postgresql",
  "redshift",
  "sql server",
  "sqlite"
)

# these dbms require the database name to be appended to the hostname
name_concat_dbms <- list("netezza",
                         "oracle",
                         "postgresql",
                         "redshift")

no_index_dbms <- list("netezza",
                      "redshift")

# ensure output paths
output_path <- file.path(cfg$output_base,
                         cfg$source_name,
                         cfg$timestamp)
json_output_path <- file.path(cfg$json_output_base,
                              cfg$source_name,
                              cfg$timestamp)
dqd_output_path <- file.path(cfg$dqd_output_base,
                             cfg$source_name,
                             cfg$timestamp)
for (path in c(output_path, json_output_path, dqd_output_path)) {
  dir.create(path,
             showWarnings = FALSE,
             recursive = TRUE,
             mode = "0755")
}

# create database connection details
if (!cfg$skip_achilles || cfg$dqd) {
  if (!(cfg$db_dbms %in% valid_dbms)) {
    stop("Cannot proceed with invalid dbms: ", cfg$db_dbms)
  }

  # Some connection packages need the database on the server argument.
  # see ?createConnectionDetails after loading library(Achilles)
  if (cfg$db_dbms %in% name_concat_dbms) {
    server <- paste(cfg$db_hostname, cfg$db_name, sep = "/")
  } else {
    server <- cfg$db_hostname
  }

  extra_settings <- NULL
  if (cfg$db_extra_settings != "") {
    extra_settings <- cfg$db_extra_settings
  }

  connection_string <- NULL
  if (cfg$db_dbms == "sql server") {
    connection_string <- paste(
      "jdbc:",
      gsub("\\s", "", cfg$db_dbms),
      # removing the space in "sql server"
      "://",
      cfg$db_hostname,
      ":",
      cfg$db_port,
      ";databaseName=",
      cfg$db_name,
      sep = ""
    )
  }
  connection_details <- createConnectionDetails(
    dbms = cfg$db_dbms,
    user = cfg$db_username,
    password = cfg$db_password,
    server = server,
    port = cfg$db_port,
    extraSettings = extra_settings,
    connectionString = connection_string,
    pathToDriver = cfg$databaseconnector_jar_folder
  )
}

# run achilles
if (!cfg$skip_achilles) {
  cat("---> Starting Achilles\n")

  # https://ohdsi.github.io/Achilles/reference/achilles.html
  achilles(
    connection_details,
    cdmDatabaseSchema = cfg$cdm_schema,
    resultsDatabaseSchema = cfg$results_schema,
    vocabDatabaseSchema = cfg$vocab_schema,
    sourceName = cfg$source_name,
    cdmVersion = cfg$short_cdm_version,
    createIndices = !(cfg$db_dbms %in% no_index_dbms),
    numThreads = cfg$num_threads,
    outputFolder = output_path,
    optimizeAtlasCache = cfg$optimize_atlas_cache
  )

  cat("---> Starting achilles exportToJson\n")
  if (cfg$json_export) {
    # Export Achilles results to output path in JSON format
    exportToJson(
      connection_details,
      cdmDatabaseSchema = cfg$cdm_schema,
      resultsDatabaseSchema = cfg$results_schema,
      vocabDatabaseSchema = cfg$vocab_schema,
      outputPath = json_output_path,
      compressIntoOneFile = cfg$json_compress
    )
  }
}

# run DataQualityDashboard
if (cfg$dqd) {
  cat("---> Starting DataQualityDashboard checks\n")

  output_file <- str_glue("DQD_Results{cfg$timestamp}.json")

  # https://ohdsi.github.io/DataQualityDashboard/reference/executeDqChecks.html
  executeDqChecks(
    connectionDetails = connection_details,
    cdmDatabaseSchema = cfg$cdm_schema,
    resultsDatabaseSchema = cfg$results_schema,
    vocabDatabaseSchema = cfg$vocab_schema,
    cdmSourceName = cfg$source_name,
    numThreads = cfg$num_threads,
    sqlOnly = cfg$dqd_sql_only,
    outputFolder = dqd_output_path,
    outputFile = output_file,
    verboseMode = cfg$dqd_verbose,
    writeToTable = !(cfg$dqd_skip_db_write),
    checkLevels = cfg$dqd_check_levels,
    checkNames = cfg$dqd_check_names,
    tablesToExclude = cfg$dqd_exclude_tables,
    cdmVersion = cfg$cdm_version,
    tableCheckThresholdLoc = cfg$dqd_table_threshold_file,
    fieldCheckThresholdLoc = cfg$dqd_field_threshold_file,
    conceptCheckThresholdLoc = cfg$dqd_concept_threshold_file
  )

  # This envvar sets the DQDViz input file
  Sys.setenv(jsonPath = output_file)
}

# run dqd_web (dqdviz)
if (cfg$dqd_web) {
  cat("---> Starting DataQualityDashboard web app\n")
  if (Sys.getenv("jsonPath") == "") {
    # DQDViz relies on the envvar jsonPath;
    # * if the envvar "jsonPath" is already set, use it
    # * else if cfg$dqd_web_input_json is not "AUTO", use its value
    # * otherwise find the most recently modified results file and use that
    if (cfg$dqd_web_input_json != "AUTO") {
      Sys.setenv(jsonPath = cfg$dqd_web_input_json)
    } else {
      # find the most recent results file if the user didn't specify one
      results_files <- file.info(
        list.files(
          path = cfg$dqd_output_base,
          pattern = "DQD_Results.+\\.json",
          all.files = TRUE,
          full.names = TRUE,
          recursive = TRUE,
          ignore.case = TRUE,
          include.dirs = FALSE,
          no.. = TRUE
        )
      )
      if (nrow(results_files) > 0) {
        newest <- rownames(results_files[with(results_files, order(as.POSIXct(mtime), decreasing = TRUE)),])[[1]]
        Sys.setenv(jsonPath = newest)
        cat(str_glue("Using most recently modified results file: {newest}\n"))

      } else {
        cat("WARNING: didn't find any results files for dqd_web to display!\n")
      }
    }
  }

  shiny::runApp(
    appDir = system.file("shinyApps", package = "DataQualityDashboard"),
    host = cfg$dqd_web_host,
    port = cfg$dqd_web_port,
    display.mode = cfg$dqd_web_display_mode,
    launch.browser = FALSE
  )
}

if (cfg$s3_target != "") {
  # https://www.rdocumentation.org/packages/base/versions/3.6.2/topics/system
  system(
    paste(
      "aws",
      "s3",
      "sync",
      sQuote(cfg$output_base),
      sQuote(cfg$s3_target)
    ),
    intern = FALSE,
    ignore.stdout = FALSE,
    ignore.stderr = FALSE,
    wait = TRUE,
    input = NULL,
    show.output.on.console = TRUE,
    minimized = FALSE,
    invisible = TRUE,
    timeout = 0
  )
}
