
# Install non-default libraries if not already installed
	# install.packages("RODBC")

# Load non-default libraries
library(RODBC)

# Get connection to DB
cn <- odbcDriverConnect(
	connection="
		Driver={SQL Server Native Client 11.0};
		server=adcrmsql;
		database=CnO_BI_PowerPivot_FY16;
		trusted_connection=yes;"
)

# Query FactScorecard table
dataQuery <- sqlQuery(cn,"Select Top 1000 * From FactScorecard");

# Find 495 in the TimeID column
495 %in% dataQuery[,2] # Returns only one true or false
495 %in% dataQuery[,c("TimeId")]

# Find 495 in the 2nd row of the TimeID column
495 %in% dataQuery[2,2]

# Find 495 in the 2nd row and in any of the columns
495 %in% dataQuery[2,]

# Close DB connection when done
close(cn);