# Install non-default libraries if not already installed
	# install.packages("RODBC")
	
# Create Linked Server connection to use for scn2 connection
	# EXECUTE sp_addlinkedserver @server = 'LinkedSASMBRPT03',@provider = 'MSOLAP',@srvproduct = '',@datasrc = 'SASMBRPT03', @catalog='ARC'
	# EXECUTE sp_serveroption 'LinkedSASMBRPT03', 'rpc', 'true'
	# EXECUTE sp_serveroption 'LinkedSASMBRPT03', 'rpc out', 'true'
	# EXEC master.dbo.sp_MSset_oledb_prop N'MOLAP', N'AllowInProcess', 1

# Load non-default libraries
library(RODBC)

# Get connection to DB
scn <- odbcDriverConnect(
	connection="
		Driver={SQL Server Native Client 11.0};
		server=localhost;
		database=master;
		trusted_connection=yes;"
);

# Query cube
			query <- "
With Member Measures.[Rev] As IIF(Measures.[Net Revenue] = 0,NULL,Measures.[Net Revenue]) 
Select
	{
		[Measures].[Rev]
	} On Columns, 
	NON EMPTY 
	(
		Except([Channel - Service].[Country Name].members,[Channel - Service].[Country Name].[All]) *  
		Except([Calendar].[Fiscal Month].members,[Calendar].[Fiscal Month].[All]) * 
		[Account].[Customer].[Customer ID].members
	) On Rows
From
	[ARC] Where 
	(
		{[Publisher].[Publisher Network].&[Microsoft - O&O]},
		{
			[Calendar].[Day].&[2015-12-01T00:00:00]:[Calendar].[Day].&[2015-12-14T00:00:00]
		}
	)"
			query <- paste("Select 
					\"[Measures].[Rev]\" As Rev,
					\"[Channel - Service].[Country Name].[Country Name].[MEMBER_CAPTION]\" As Country,
					\"[ACCOUNT].[CUSTOMER].[CUSTOMER ID].[MEMBER_CAPTION]\" As CustomerID,
					\"[Calendar].[Fiscal Month].[Fiscal Month].[MEMBER_CAPTION]\" AS FiscalMonth
					From OpenQuery(LinkedSASMBRPT03,'",query,"')",sep="");
			t1 <- sqlQuery(scn,query);

# Add column that can be counted so a sum function can be used in the aggregate function
t1$Cnt <- 1



# Analysis
	# head
	head(t1)

	# summary
	summary(t1)

	# row count
	nrow(t1)

	# reduce number of columns before aggregation
	t2 <- t1[,c("CustomerID","Cnt")]

	# count number of rows per customer
	attach(t2)
	t3 <- aggregate(t2,by=list(CustomerID),FUN=sum)

	# number of customers with duplicates
	nrow(t3[t3$Cnt > 1,]) 

	# Gives me list of some of the CustomerID with more than one record. 
	# Note: "Group.1" & "CustomerID" labels are swapped in t3
	head(t3[t3$Cnt > 1,]) 
	
	# Look at a specific customerID
	t1[t1$CustomerID == 2024,] 

# Close DB connection when done
close(scn);