################################################################################
#1.Installing and Load Required packages

utils::install.packages("DatabaseConnector")
utils::install.packages("remotes")
utils::install.packages("DBI")
remotes::install_github("OHDSI/DataQualityDashboard")
remotes::install_github("OHDSI/Achilles")
remotes::install_github("OHDSI/DbDiagnostics")


library(DatabaseConnector)
library(DBI)
library(DataQualityDashboard)
library(Achilles)
library(DbDiagnostics)
source("helperfuns_executeDbProfile_new.R")

################################################################################
#2.Store password credentials in .Renviron

##Why an env var and not a plain password string: so the password never
##appears in this script or in anything committed/shared alongside it.

##store password credentials for postgres in .Renviron and retrieve with Sys.getenv()

#utils::file.edit("~/.Renviron")
#usethis::edit_r_environ() 

### Restart R
#.rs.restartR()

################################################################################
#3.Setup

### Start with a clean environment by removing objects in workspace
rm(list=ls())

### Setting work directory
working_directory <- base::setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

working_directory

################################################################################
#4.Create Network result Schema

database_name <- "omop"
cdm_schema <- "nih_tb_cdm"
results_schema <- "nih_tb_results"
network_results_schema <- "nih_tb_results_network"
vocabulary_schema <- "vocabulary"


#Connecting to local database using connection object
con <- DBI::dbConnect(drv = RPostgres::Postgres(),
                      dbname = database_name, 
                      host = 'localhost', 
                      port = 5432, 
                      user = 'postgres',
                      password = Sys.getenv("postgres_password")
                      )
print(con) 

# Create a new schema
query <- paste0("CREATE SCHEMA IF NOT EXISTS ", network_results_schema, ";")

# Execute the query
out <- DBI::dbExecute(con, query)

DBI::dbDisconnect(con)

################################################################################
#5. Database Profile

## Path to jdbc drivers
driver_path <- base::file.path(working_directory, "JDBC Driver postgresql")
output_folder <- base::file.path(working_directory, "Evidence_Network") #create output folder for individual studies

# Turn off the connection pane to speed up run time
#options(connectionObserver = NULL)

## Create connection to database
cd_evdnet <- DatabaseConnector::createConnectionDetails(
  dbms = "postgresql",
  server = paste0("localhost","/",database_name),
  user = "postgres",
  password = Sys.getenv("postgres_password"),
  port = 5432,
  extraSettings = "tcpKeepAlive=true",
  pathToDriver = driver_path  #path to jdbc drivers
  )

#run Evidence Network 
executeDbProfile_new(connectionDetails = cd_evdnet,
                     cdmDatabaseSchema = cdm_schema,
                     resultsDatabaseSchema = results_schema,  #no capital letters- brings issues with postgres
                     writeTo = network_results_schema, #used to store any missing analyses that need to be run. Only set if appendAchilles = FALSE
                     vocabDatabaseSchema = vocabulary_schema, 
                     cdmSourceName = "NIAID TB Portals Program",
                     siteName = "APHRC", #The name of the site or institution that owns or licenses the data.
                     siteOHDSIParticipation = "No", #Yes/No if the site contributed to an OHDSI study in the past
                     siteOHDSIRunPackage = "No", #Yes/No if site has someone who can run and/or debug an OHDSI study package
                     siteSponsoredStudy = "Yes", #Yes/No if site is interested in participating in sponsored studies
                     dataFullName = "NIAID TB Portals Consortium Program", #The full name of the database
                     dataShortName = "NIAID TB", #	The short name or nickname of the database
                     dataContactName = "Name Here", #person who should be contacted in the event database is identified as a good candidate for a study
                     dataContactEmail = "Email Here", #email address of the person who should be contacted in the event database is identified as a good candidate for a study
                     dataDoiType = "Other", #data object identifier (DOI) the database has. Options are "DOI","CURIE","ARK","Other"
                     governanceTime = "4 weeks", #How long (in weeks) it typically takes to receive approval to run a study on this database
                     dataProvenance = "Other", #type(s) of data in database. Options "Electronic Health Records", "Administrative Claims", "Disease-specific Registry", "Wearable or Sensor Data", "Other"
                     refreshTime = "Yearly", #	 How often the data are refreshed
                     outputFolder = output_folder, # The folder where your results should be written
                     cdmVersion = "5.4", #The version of the OMOP CDM you are currently on. v5.3 and v5.4 are supported
                     appendAchilles = FALSE, # Whether to append existing Achilles tables or create new ones
                     minCellCount = 5, #Minimum cell count to allow in analyses. Default = 0
                     roundTo = 10, # Whether to round to the 10s or 100s place. Valid inputs are 10 or 100, default is 10.
                     excludedConcepts = c(),
                     addDQD = FALSE, #Specify if DQD should be run. Default = TRUE
                     tableCheckThresholds = "default",
                     fieldCheckThresholds = "default",
                     conceptCheckThresholds = "default"
                     )




