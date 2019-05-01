
# Install non-default libraries if not already installed
	# install.packages("RODBC")

# Load non-default libraries
library(RODBC);

# Get connection to DB
cn <- odbcDriverConnect(
	connection="
		Driver={SQL Server Native Client 11.0};
		server=adcrmsql;
		database=CnO_BI_PowerPivot_FY16;
		trusted_connection=yes;"
)

# Query FactScorecard table
dataQueryMS <- sqlQuery(cn,"Select CustomerID,Sum(NetRevenue) As MSRev From StgPostTranRevGrowthActual_MS Group By CustomerID");
dataQueryY <- sqlQuery(cn,"Select CustomerID,Sum(NetRevenue) As YRev From StgPostTranRevGrowthActual_Yahoo Group By CustomerID");

# Inner Join. If I joined on CustomerID and TimeID I would use by.x = c("CustomerID","TimeID") instead. 
dataQuery <- 
merge(
	dataQueryMS,
	dataQueryY,
	by.x = "CustomerID",
	by.y = "CustomerID",
	all = FALSE
);

# Left Outer Join
dataQuery <- 
merge(
	dataQueryMS,
	dataQueryY,
	by.x = "CustomerID",
	by.y = "CustomerID",
	all,x = TRUE
);

# Right Outer Join
dataQuery <- 
merge(
	dataQueryMS,
	dataQueryY,
	by.x = "CustomerID",
	by.y = "CustomerID",
	all,y = TRUE
);

# Full Outer Join 
dataQuery <- 
merge(
	dataQueryMS,
	dataQueryY,
	by.x = "CustomerID",
	by.y = "CustomerID",
	all = TRUE
);

# Close DB connection when done
close(cn);