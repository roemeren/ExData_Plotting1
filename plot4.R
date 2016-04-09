# close all open graphics devices
graphics.off()

# download zip file if not present in working directory
dataZIP <- "exdata_data_household_power_consumption.zip"
if (!(file.exists(dataZIP))) {
    downloadURL <- paste("https://d396qusza40orc.cloudfront.net/",
                         "exdata%2Fdata%2Fhousehold_power_consumption.zip",
                         sep = "")
    download.file(downloadURL, dataZIP)
}

# get the headers from the first row (since not the whole file will be loaded)
dataTxt <- "household_power_consumption.txt"
dataHeader <- read.table(file = unz(dataZIP, dataTxt), 
                         sep = ";", 
                         nrows = 1,
                         stringsAsFactors = FALSE)

# read data from dates 2007-02-01 and 2007-02-02
# since the data are sorted by increasing date it suffices to get the first
# and last row numbers that match these dates
dateMatch <- grep("^(1|2)/2/2007", readLines(conTxt <- unz(dataZIP, dataTxt)))
close(conTxt)
readStart <- head(dateMatch, 1)
readEnd <- tail(dateMatch, 1)
powerConsumption <- read.table(file = unz(dataZIP, dataTxt),
                               sep = ";",
                               col.names = dataHeader,
                               na.strings = "?",
                               skip = readStart - 1,
                               nrows = readEnd - readStart + 1,
                               stringsAsFactors = FALSE)

# combine Date and Time in DateTime and also reformat Date
powerConsumption$DateTime <- with(powerConsumption, paste(Date, Time))
powerConsumption$DateTime <- strptime(x = powerConsumption$DateTime,
                                      format = "%d/%m/%Y %H:%M:%S")
powerConsumption$Date <- as.Date(powerConsumption$Date, "%d/%m/%Y")

# directly plot in the PNG with default parameters
png("plot4.png")

# set the number of plots per row and column
par(mfrow = c(2,2))

# subplot 1: Global_active_power ~ DateTime
plot(x = powerConsumption$DateTime,
     y = powerConsumption$Global_active_power,
     type = "l",
     xlab = "",
     ylab = "Global Active Power")

# subplot 2: Voltage ~ DateTime
plot(x = powerConsumption$DateTime,
     y = powerConsumption$Voltage,
     type = "l",
     xlab = "datetime",
     ylab = "Voltage")

# subplot 3: Sub_metering_i ~ DateTime
# 3a. initialize plot
seriesItems = paste("Sub_metering_", c(1:3), sep = "")
yRange <- range(powerConsumption[, seriesItems])

plot(x = powerConsumption$DateTime,
     y = powerConsumption$Sub_metering_2,
     type = "n",
     xlab = "",
     ylab = "Energy sub metering",
     ylim = yRange)

# 3b. add series and legend without border
seriesColors = c("black", "red", "blue")
for (i in 1:3) {
    lines(x = powerConsumption$DateTime, 
          y = powerConsumption[[seriesItems[i]]],
          col = seriesColors[i]) 
}
legend("topright", 
       lty = c(1, 1, 1), 
       col = seriesColors, 
       legend = seriesItems,
       bty = "n")

# subplot 4: Global_reactive_power ~ DateTime
plot(x = powerConsumption$DateTime,
     y = powerConsumption$Global_reactive_power,
     type = "l",
     xlab = "datetime",
     ylab = "Global_reactive_power")

# close the PNG device
dev.off()