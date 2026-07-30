# OHDSI-Evidence-Network_CDM_Database_Profile
Profile a harmonized OMOP-CDM database

## Requirements and setup

- Sign up for [Github](https://github.com/) account (If you don't have one).
- We are assuming you have `R Software` and `Rstudio IDE` installed. If not you can download and install 
[**R software**](https://www.r-project.org/), then [**Rtools**](https://cran.r-project.org/bin/windows/Rtools/) corresponding 
to your R version followed by [**RStudio/Posit IDE**](https://posit.co/download/rstudio-desktop/).

## Database Profile
The `executeDbProfile` function in this package relies on the **Achilles** and **DataQualityDashboard** packages to run a subset 
of characterization and data quality analyses, along with metadata about the database.This information is collectively referred 
to as the database profile. It works by connecting to a database through a connectionDetails object created by the `DatabaseConnector`
package. 

It will first look for metadata about the database, either in the parameters of the `executeDbProfile` function or in a csv file 
in the output folder. If neither are present the function will ask the user a series of questions in the form of pop-ups and save 
this information in a csv file to ship along with the output. It will then check to see if Achilles results are already present. 
If so, it will export those results. If not, it will run the required Achilles analyses and then export. Then, it will run a set
of DataQualityDashboard checks and export those results as well.

Once the results are generated they are then loaded to a separate results schema. 

## Sharing the Database Profile Results

Once you have successfully executed the study, your results will be in a zip file located in the output folder. Within this folder
the full results are stored as CSV files which you can inspect before providing the results to a study coordinator.

Once you have reviewed your results and are ready to provide them to the study coordinator, you can use the `sftpUploadFile` function 
from **OhdsiSharing** R package. More details about how to share the data base profile results can be found in 
[OhdsiEvidenceNetwork](https://github.com/ohdsi-studies/OhdsiEvidenceNetwork).

## Run

After cloning the repository or downloading the ZIP, Open `main.Rmd` and run from the beginning.
