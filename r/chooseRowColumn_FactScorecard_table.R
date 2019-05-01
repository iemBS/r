
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

# Choose columns
dataQuery[c("TimeId")]

# Choose a row
dataQuery[3,]

# Choose more than one row
dataQuery[c(3,6),] # specific rows
dataQuery[3:6,]    # range of rows

# Choose rows and columns
dataQuery[3,c("TimeId")]

# Close DB connection when done
close(cn);