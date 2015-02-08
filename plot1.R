# Homework assignment for Coursera exdata-011
# Week 1
# plot1.R
# Chris Thatcher
#
# Expects the data is available in `getwd()` as household_power_consumption.txt

library(data.table)
library(lubridate)

# fread is fast but its going to force every column to be a character because
# it can only coerse columns with NA's to character during the ingest.  It also
# dumps a bunch of noisy warnings.  we dont care, we just want fast and quiet
# and will deal with the types later
household_power_consumption = suppressWarnings( fread(
    "household_power_consumption.txt",
    sep=";",
    na.strings="?"
));

# convert the Date field to a, uh, Date
household_power_consumption$Date = parse_date_time(
    household_power_consumption$Date, 
    "%d%m%y"
);

# convert the Time field to a, uh, Time
household_power_consumption$Time = parse_date_time(
    household_power_consumption$Time, 
    "%H%M%S"
);
    

# We will only be using data from the dates 2007-02-01 and 2007-02-02. 
time_slice = subset(
    household_power_consumption,
    household_power_consumption$Date >= parse_date_time("2007-02-01", "ymd") &
    household_power_consumption$Date < parse_date_time("2007-02-03", "ymd")
);
    
# Finally construct the plot
with(time_slice, {
    png('plot1.png');
    hist( 
        as.numeric(Global_active_power), 
        main="Global Active Power",
        xlab="Global Active Power (kilowatts)",
        col="red"
    );
    dev.off();
});


