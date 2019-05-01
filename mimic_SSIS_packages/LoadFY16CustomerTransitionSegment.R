
# Install non-default libraries if not already installed
	# install.packages("RODBC")

# Load non-default libraries
library(RODBC)

# Get connection to DB
cn <- odbcDriverConnect(
	connection="
		Driver={SQL Server Native Client 11.0};
		server=SASMARTSQL10;
		database=Yahoo_Transition;
		trusted_connection=yes;"
)

# Get Data
dataQuery <- sqlQuery(cn,"
	Select
		CustomerID
	From
		ConsolidatedDB.TransitionCustomerGroup
");

# Analysis
	# Get the top few rows
	head(dataQuery)

	# Number of rows
	nrow(dataQuery)

	# Order by CustomerID descending
	attach(dataQuery)
	dataQuery[order(CustomerID,decreasing = TRUE),c("CustomerID")]

# Close DB connection when done
close(cn);

