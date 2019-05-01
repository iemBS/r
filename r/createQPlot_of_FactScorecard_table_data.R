
# Install non-default libraries if not already installed
	# install.packages("ggplot2")
	# install.packages("RODBC")
	# install.packages("Scale")

# Load non-default libraries
library(ggplot2)
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
dataQuery <- sqlQuery(cn,"Select TimeID,SegmentID,ScenarioID,GeoID,Value From FactScorecard Where AccountID = 663");

# Show QPlot
p <- qplot(
	TimeID,         # identify dimension on x-axis
	SegmentID,      # identify dimension on y-axis
	data = dataQuery,   # value to plot
	color = ScenarioID, # identity a dimension via color
	facets = GeoID ~ . # identify dimension with a plot for each dimension 
);
p 
# Close DB connection when done
close(cn);