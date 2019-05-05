# filePath = "C:/AnO/FY15 Country Walk_tab1.csv"

# get AnO metric names from SQL Server DB
getAnOMetricNames <- function(){
	metrics <- c(
		"Windows Consumer Share",
		"Total BOS Attach",
		"Consumer BOS Attach",
		"Premium Retail Mix"
	)
}

# get metrics not used in any reports
getMetricsNotUsedInReports <- function(){
	r <- 0
	# get list of all metrics

	# get list of metrics used in A&O Scorecard

	# remove metrics that are used in A&O Scorecard

	# get list of metrics used in GSDS Scorecard

	# remove metrics that are used in GSDS Scorecard

	# get list of metrics used in Audience Walk

	# remove list of metrics used in Audience Walk

	# get list of metrics used in Country Walk

	# remove list of metrics used in Country Walk

	# return list of metrics not used in any report
}

# get Pricing Levels from SQL Server DB (Get Name)
getAnOPLs <- function(){
list(
c("-1","No Member","NONE"),
c("1","Brand","Brand"),
c("2","Performance","Performance"),
c("3","House","House Ads")
)
}

# search all files in directory for Pricing Levels (Look Name)
searchDirectoryFilesForPL <- function(directoryPath){
	# get all files in directory
	files <- list.files(path=directoryPath, pattern="*.csv", full.names=T, recursive=FALSE)

	# create holder for found PLs
	foundPLs <- c()

	# loop through files and search each one
	for(f in files){
		foundPLs <- c(foundPLs,searchFileForPL(f))
	}

	# return found PLs
	unique(foundPLs) 
}

# search file for Pricing Levels (look Name)
searchFileForPL <- function(filePath){
	
	# get list of Pricing Levels to search for (ID, Name, Code)
	pls <- getAnOPLs()

	# read data from file
	data <- read.table(
		file = filePath,
		header = FALSE,
		sep = ",",
		colClasses = "character"
	)

	# get data frame dimensions
	rowCnt <- nrow(data)
	colCnt <- ncol(data)

	# create holder for found Pricing Levels
	foundPLs <- c()
	
	# loop through all Pricing Levels
	for(pl in pls) {
		cubeAttribute <- c(
					paste0("[PricingLevel].[Detail Pricing Level].&[",pl[1],"]",collapse = NULL),
					paste0("[PricingLevel].[Detail Pricing Level].[",pl[2],"]",collapse = NULL)
				)
		r <- 1

		# loop through rows in data
		for(r in 1:rowCnt){

			c <- 1

			# loop through columns in data
			for(c in 1:colCnt){
				dataCell <- data[r,c]
			
				dataCellLen <- nchar(dataCell)

				# loop through versions of attribute
				for(v in cubeAttribute){

					# remove found metric from dataCell
					dataCell <- sub(
						pattern = v,
						replacement = "",
						x = dataCell,
						fixed=TRUE
					)

					# check if the Pricing Level was found
					if(nchar(dataCell) < dataCellLen){

						# record the found Pricing Level
						foundPLs<- c(foundPLs,v)
					}
				}


			}
		}
	}

	# return the list of found Pricing Levels
	unique(foundPLs) 
}

# search file for Pricing Levels reference pattern
searchFileForPLPattern <- function(filePath){}

# get RSCs from SQL Server DB (Get ID, Name, Code)
getAnORSCs <- function(){
list(
c("-1","No Member","No Member"),
c("0","Not Mapped","Not Mapped"),
c("1","E&D Advertising","E&D Advertising"),
c("4","MSN Mobile","MSN Mobile"),
c("5","MSN Video","MSN Video"),
c("6","MSN Homepage","MSN Homepage"),
c("7","MSN Verticals & Channels","MSN Verticals and Channels")
)
}

# RSCs used in file that do not exist in DB (look ID, Name, Code)
searchFileForUnusedRSC <- function(filePath){}

# search all files in directory for RSCs (look ID, Name, Code)
searchDirectoryFilesForRSC <- function(directoryPath){
	# get all files in directory
	files <- list.files(path=directoryPath, pattern="*.csv", full.names=T, recursive=FALSE)

	# create holder for found RSCs
	foundRSCs <- c()

	# loop through files and search each one
	for(f in files){
		foundRSCs <- c(foundRSCs,searchFileForRSC(f))
	}

	# return found RSCs
	unique(foundRSCs) 
}

# search file for RSCs (look IDs, codes, names)
searchFileForRSC <- function(filePath){
	
	# get list of RSC to search for (ID, Name, Code)
	rscs <- getAnORSCs()

	# read data from file
	data <- read.table(
		file = filePath,
		header = FALSE,
		sep = ",",
		colClasses = "character"
	)

	# get data frame dimensions
	rowCnt <- nrow(data)
	colCnt <- ncol(data)

	# create holder for found RSCs
	foundRSCs <- c()
	
	# loop through all RSCs
	for(rsc in rscs) {
		cubeAttribute <- c(
					paste0("[RevSum].[RevSum].[Category].&[",rsc[1],"]",collapse = NULL),
					paste0("[RevSum].[RevSum].[Category].[",rsc[2],"]",collapse = NULL),
					paste0("[RevSum].[Category].[",rsc[2],"]",collapse = NULL),
					"[RevSum].[RevSum].[All]"
				)
		r <- 1

		# loop through rows in data
		for(r in 1:rowCnt){

			c <- 1

			# loop through columns in data
			for(c in 1:colCnt){
				dataCell <- data[r,c]
			
				dataCellLen <- nchar(dataCell)

				# loop through versions of attribute
				for(v in cubeAttribute){

					# remove found metric from dataCell
					dataCell <- sub(
						pattern = v,
						replacement = "",
						x = dataCell,
						fixed=TRUE
					)

					# check if the RSC was found
					if(nchar(dataCell) < dataCellLen){

						# record the found RSC
						foundRSCs <- c(foundRSCs,v)
					}
				}


			}
		}
	}

	# return the list of found RSCs
	unique(foundRSCs) 
}

# search file for RSC reference pattern
searchFileForRSCPattern <- function(filePath){}

# search SQL Server DB for RSCs (look IDs, codes, names)
searchDBForRSC <- function(){}

# search all files in directory for metric names
searchDirectoryFilesForAccount <- function(directoryPath){
	# get all files in directory
	files <- list.files(path=directoryPath, pattern="*.csv", full.names=T, recursive=FALSE)

	# create holder for found metrics
	foundMetrics <- c()

	# loop through files and search each one
	for(f in files){
		foundMetrics <- c(foundMetrics,searchFileForAccount(f))
	}

	# return found metrics
	unique(foundMetrics) 
}

# search file for metric names
searchFileForAccount <- function(filePath){
	
	# get list of metrics to search for 
	metrics <- getAnOMetricNames()

	# read data from file
	data <- read.table(
		file = filePath,
		header = FALSE,
		sep = ",",
		colClasses = "character"
	)

	# get data frame dimensions
	rowCnt <- nrow(data)
	colCnt <- ncol(data)

	# create holder for found metrics
	foundMetrics <- c()
	
	# loop through all metrics
	for(metric in metrics) {
		cubeAttribute <- c(
					paste0("[Account].[Accounts].&[",metric,"]",collapse = NULL),
					paste0("[Account].[Accounts].[",metric,"]",collapse = NULL)
				)
		r <- 1

		# loop through rows in data
		for(r in 1:rowCnt){

			c <- 1

			# loop through columns in data
			for(c in 1:colCnt){
				dataCell <- data[r,c]
			
				dataCellLen <- nchar(dataCell)

				# loop through versions of attribute
				for(v in cubeAttribute){

					# remove found metric from dataCell
					dataCell <- sub(
						pattern = v,
						replacement = "",
						x = dataCell,
						fixed=TRUE
					)

					# check if the metric was found
					if(nchar(dataCell) < dataCellLen){

						# record the found metric
						foundMetrics <- c(foundMetrics,v)
					}
				}


			}
		}
	}

	# return the list of found metrics
	unique(foundMetrics) 
}

# search file for Account reference pattern
searchFileForAccountPattern <- function(filePath){
	
	# load library for str_locate function
	library(stringr)

	# read data from file
	data <- read.table(
		file = filePath,
		header = FALSE,
		sep = ",",
		colClasses = "character"
	)

	# get data frame dimensions
	rowCnt <- nrow(data)
	colCnt <- ncol(data)

	# create holder for found metrics
	foundMetrics <- c()
		
		# create list of patterns to look for 
		cubeAttribute <- c(
					"[[Account].[Accounts].&[]{1}[:alnum:]{50,}[]]{1}",
					"[[Account].[Accounts].[]{1}[:alnum:]{50,}[]]{1}"
				)
		r <- 1

		# loop through rows in data
		for(r in 1:rowCnt){

			c <- 1

			# loop through columns in data
			for(c in 1:colCnt){
				dataCell <- data[r,c]
			
				# loop through patterns of attribute
				for(v in cubeAttribute){

					# get pattern from dataCell if it exists
					foundMetric <- NULL
					otherPart  <- NULL

					#foundMetric <- regexec(
					#	pattern = v,
					#	text = dataCell,
					#	ignore.case = TRUE,
					#	fixed = FALSE,
					#	useBytes = FALSE
					#)

					#otherPart <- strsplit(
					#	x = c(dataCell),
					#	split = v,
					#	fixed = FALSE,
					#	perl = FALSE,
					#	useBytes = FALSE
					#)

					foundMetric <- grep(
							pattern = v,
							x = dataCell,
							ignore.case = TRUE,
							perl = FALSE,
							value = TRUE,
							fixed = FALSE,
							useBytes = FALSE,
							invert = FALSE
					)

					#reg.out <- regexpr(
    					#	v,
    					#	dataCell,
    					#	perl=FALSE
					#)
					#foundMetric <- substr(dataCell,reg.out,reg.out + attr(reg.out,"match.length")-1)

					#foundMetric <- sub(
					#	v,
					#	"1",
					#	dataCell[grepl(v,dataCell)]
					#)

					# check if the metric was found
					if(nchar(foundMetric[1]) > 0){
	
						#onlyMatch <- regmatches(
						#	x = dataCell,
						#	m = foundMetric,
						#	invert = FALSE
						#)

						# remove other part
						#foundStart <- str_locate(dataCell,"[Account].[Accounts]")
						#if(is.na(foundStart[1])){foundStart[1] <- 0}
						#print(dataCell,foundStart[1],100)

						#for(o in otherPart){
						#	# left side
						#	foundMetric <- sub(
						#		pattern = otherPart[1],
						#		replacement = "",
						#		x = foundMetric,
						#		ignore.case = TRUE,
						#		perl = FALSE,
						#		fixed = TRUE, 
						#		useBytes = FALSE
						#	)
						#	# right side
						#	foundMetric <- sub(
						#		pattern = otherPart[2],
						#		replacement = "",
						#		x = foundMetric,
						#		ignore.case = TRUE,
						#		perl = FALSE,
						#		fixed = TRUE, 
						#		useBytes = FALSE
						#	)
						#}

						# record the found metric					
						foundMetrics <- c(foundMetrics,foundMetric)
					}
				}
			}
		}

	# return the list of found metrics
	unique(foundMetrics) 
}