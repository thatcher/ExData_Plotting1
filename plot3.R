# Homework assignment for Coursera exdata-011
# Week 1
# plot3.R
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
    png('plot3.png')

    tryCatch({
        plot(
            as.numeric(V1),
            as.numeric(Sub_metering_1),
            ylab="Energy sub metering",
            xlab="",
            xaxt="n",
            type="l"
        )
        lines(
            as.numeric(V1),
            as.numeric(Sub_metering_2),
            col="red"
        )
        lines(
            as.numeric(V1),
            as.numeric(Sub_metering_3),
            col="blue"
        )
        axis(
            1,
            at=c(1, floor(nrow(power_data)/2), nrow(power_data)),
            labels=c("Thur", "Fri", "Sat")
        )
        legend(
            "topright",
            legend = c(
                "Sub_metering_1",
                "Sub_metering_2",
                "Sub_metering_3"

            ),
            col=c(
                "black",
                "red",
                "blue"
            ),
            lty=c(1, 1, 1)
        )
    }, finally=dev.off())

})
