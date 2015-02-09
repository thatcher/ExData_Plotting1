# Homework assignment for Coursera exdata-011
# Week 1
# etl.R
# Basic routines for fetching the data from the web, read into R,
# transform any fields we need to clean/manipulate, and load
# the required subset for exploratory analysis.
#
# Important to note we are using data.table so the data is not
# copied in memory and downstream modifications will effect the
# the data in place.
#
# Extract will only download the data if it cant find the file locally.
#
# Tranform checks the field types to ensure we dont re-manipulate the fields.
#
# Load returns the subset and only runs extract and transform if the data
# isnt already in memory.

# Chris Thatcher
library(data.table)
library(lubridate)

HOUSEHOLD_POWER_URL = "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
HOUSEHOLD_POWER_FILE = "data/household_power_consumption.txt"
HOUSEHOLD_POWER_SUBSET = "data/household_power_consumptions_2007-02-01_to_2007-02-02.csv"


etl.extract = function(refresh=FALSE){
    # Make sure we have the data to work with locally, otherwise go get it.
    if( refresh || !file.exists(HOUSEHOLD_POWER_FILE) ){

        message("Extracting data from url.")

        data_zip = "data/temp.zip"

        if("Windows" == Sys.info()["sysname"]){
            download.file(HOUSEHOLD_POWER_URL, destfile=data_zip)
        } else {
            download.file(HOUSEHOLD_POWER_URL, destfile=data_zip, method="curl")
        }

        unzip(data_zip, exdir='data')
        file.remove(data_zip)
    }
}


etl.transform = function(refresh=FALSE){

    if(refresh || !file.exists(HOUSEHOLD_POWER_SUBSET)){
        # fread is fast but its going to force every column to be a character
        # because it can only coerse columns with NA's to character during the
        # ingest.  It also dumps a bunch of noisy warnings.  we dont care, we
        # just want fast and quiet and will deal with the types later
        household_power_consumption = suppressWarnings( fread(
            HOUSEHOLD_POWER_FILE,
            na.strings="?"
        ))

        # Join the character colunms "Date" and "Time" into a new colum "DateTime"
        # and actually parse it as a Posix DateTime via lubridates parse_date_time
        message("Joining Date,Time columns into DateTime column.")

        household_power_consumption[, DateTime:=parse_date_time(
            sprintf("%s %s", Date, Time),
            "%d%m%y %H%M%S"
        )]

        # Now we can effectively slice the data into just the period of days
        # we are interested in. We can then save back out that file and
        # can reload just that data when working on our exploratory charts.
        message("Slicing data by DateTime, 2007-02-01 to 2007-02-03.")

        slice_start = parse_date_time("2007-02-01 00:00:00", "%y%m%d %H%M%S")
        end_start = parse_date_time("2007-02-03 00:00:00", "%y%m%d %H%M%S")
        time_slice = subset(
            household_power_consumption,
            household_power_consumption$DateTime >= slice_start &
            household_power_consumption$DateTime < end_start
        )

        message(sprintf("Saving slice to %s", HOUSEHOLD_POWER_SUBSET))
        write.csv(time_slice, file=HOUSEHOLD_POWER_SUBSET )
    }
}


etl.load = function(refresh=FALSE){
    # loads the data slice we need for our plot exploration
    if(refresh || !file.exists(HOUSEHOLD_POWER_SUBSET)){
        etl.extract(refresh=refresh)
        etl.transform(refresh=refresh)
    }

    message(sprintf("Loading data slice %s", HOUSEHOLD_POWER_SUBSET))
    data_slice = fread(HOUSEHOLD_POWER_SUBSET)
    data_slice[, DateTime:=as.POSIXct(DateTime)]

    data_slice
}

