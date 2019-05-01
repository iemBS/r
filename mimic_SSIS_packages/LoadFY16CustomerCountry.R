
# Install non-default libraries if not already installed
	# install.packages("RODBC")

# Load non-default libraries
library(RODBC)

# Get connection to DB
scn <- odbcDriverConnect(
	connection="
		Driver={SQL Server Native Client 11.0};
		server=SASMBRPT05;
		database=BoBPlanning;
		trusted_connection=yes;"
);

# Load Data

	# OLE DB Source
	query <- 
	"
		Select Distinct
			CustomerID,
			Cast(IsNull(ReportingMarket,'Unknown') As nvarchar) As ReportingMarket
		From
			TransitionMeetingAggSC
		Where
			ReportDate = (Select Max(ReportDate) From TransitionMeetingAggSC)
	";
	
	# Staging Table 
	stg <- sqlQuery(
		scn,
		query
	);

# Analysis
	# Get the top few rows
	head(stg)

	# Number of rows
	nrow(stg)

	# Order by ReportingMarket ascending
	attach(stg)
	stg[order(ReportingMarket),c("ReportingMarket","CustomerID")]

	# Get distinct ReportingMarket, order by ReportingMarket ascending
	attach(stg)
	unique(stg[order(ReportingMarket),c("ReportingMarket")])

	# Count of CustomerID per ReportingMarket, order by CustomerID count desc
	[need to add script here]

	# CustomerID associated to more than one ReportingMarket
	[need to add script here]

# Close DB connection when done
close(scn);

