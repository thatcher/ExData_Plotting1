# Homework assignment for Coursera exdata-011
# Week 1
# plot1.R
# See etl.R for the data extract/transform/load routines.  We consolidated
# them into one file so each of the plots  can leverage the same process
# without duplicating the code.  This saves a lot of time during
# development since we arent reloading the data to develop the graph.

source('etl.R')

power_data = etl.load()

# Finally construct the plot
with(power_data, {

    # open the png for writing but make sure we close it even in the
    # event of an error.
    png('plot1.png')

    tryCatch( hist(
        as.numeric(Global_active_power),
        main="Global Active Power",
        xlab="Global Active Power (kilowatts)",
        col="red"
    ), finally=dev.off())

})

