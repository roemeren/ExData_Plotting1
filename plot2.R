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

# generate the plot
plot(x = powerConsumption$DateTime,
     y = powerConsumption$Global_active_power,
     type = "l",
     xlab = "",
     ylab = "Global Active Power (kilowatts)")

# export to PNG (defaults: width = 480px, height = 480px, res = 72dpi)
dev.copy(device = png, file = "plot2.png")
dev.off()