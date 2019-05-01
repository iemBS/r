
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
dataQuery <- sqlQuery(cn,"Select Top 10 * From FactScorecard");



# Close DB connection when done
close(cn);