
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
dataQuery <- sqlQuery(cn,"Select TimeId,ScenarioID From FactScorecard Where AccountID = 663");

# Get values for a column to look at
mth <- dataQuery$TimeId;

# Show Histogram
hist(
	mth,         # apply history function on
	right=FALSE, # intervals closed on the left
	labels=TRUE,  # show labels on graph
	main="Month Frequency", # show chart name
      xlab="Fiscal Month ID", # x-axis label
	breaks=5 # Number of groupings
);

# Close DB connection when done
close(cn);