
# Install non-default libraries if not already installed
	# install.packages("RODBC")
# Create Linked Server connection to use for scn connection
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
		server=localhost\\SQL2016;
		database=master;
		trusted_connection=yes;"
);

# Load Data

	# OLE DB Source
	query <- 
	"
		Select
			{Measures.[Period Performing Advertisers]} On Columns, 
			NON EMPTY 
			(
				{
				[Calendar].[Fiscal Monthly].[Fiscal Month]
				} * 
				{
					[Channel - Distribution].[Country Name].&[DIST - NAAS - US], 
					[Channel - Distribution].[Country Name].&[DIST - EMEA - UK], 
					[Channel - Distribution].[Country Name].&[DIST - EMEA - DE], 
					[Channel - Distribution].[Country Name].&[DIST - EMEA - FR], 
					[Channel - Distribution].[Country Name].&[DIST - NAAS - CA], 
					[Channel - Distribution].[Country Name].&[DIST - APAC - AU],
					[Channel - Distribution].[Country Name].[ALL]
				} * 
				Except([Segment - Current].[Service].Members,{[Segment - Current].[Service].[All]})
			) On Rows
		From
			[ARC] 
		Where 
			(
				{
					[Marketing Alignment].[Supression Type].&[], 
					[Marketing Alignment].[Supression Type].&[Aggregator], 
					[Marketing Alignment].[Supression Type].&[YahooManaged], 
					[Marketing Alignment].[Supression Type].&[BadAdvertiser]
				},
				{[Account Type].[Account Type Groups].[Account Grouping].&[Non-Reseller]},
				{[Segment - Current].[Service Levels].[Service Segment].&[Current - GS3 - Scale/T3 - Scale]},
				[Calendar].[Fiscal Yearly].[Fiscal Year].&[2017]
			)
	";
	
	query <- paste(
			"Select
				\"[Calendar].[Fiscal Monthly].[Fiscal Month].[MEMBER_CAPTION]\" As Mth,
				\"[Channel - Distribution].[Country Name].[Country Name].[MEMBER_CAPTION]\" As Country,
				\"[Segment - Current].[Service].[Service].[MEMBER_CAPTION]\" As Segment,
				\"[Measures].[Period Performing Advertisers]\" As Val 
			From OpenQuery(LinkedSASMBRPT03,'",
			query,
			"')",
			collapse=""
	);

	# Staging Table (Use the stringsAsFactors=FALSE flag when making your data frame to force my character type fields to be a character type.)
	stg <- data.frame(Mth = character(),Country = character(), Segment = character(), Val = numeric(), stringsAsFactors = FALSE);
	tmp <- sqlQuery(
		scn,
		query
	);

	for(i in 1:nrow(tmp)){
		stg[i,1] <- as.character(tmp[i,1])
		stg[i,2] <- as.character(tmp[i,2])
		stg[i,3] <- as.character(tmp[i,3])
		stg[i,4] <- tmp[i,4]
	}

	# Derived Column (These columns need to be character in order to update)
	stg$Segment[stg$Segment == "Self-Serve"] <- "Scale"
	stg$Country[is.na(stg$Country)] <- "WW"	

# Analysis
	# Get the top few rows
	head(stg)

	# Number of rows
	nrow(stg)

	# Order by Country & Mth ascending
	attach(stg)
	stg[order(Country,Mth),c("Country","Mth","Segment","Val")]

	# Get distinct Segment, order by Segment ascending
	attach(stg)
	unique(stg[order(Segment),c("Segment")])

# Close DB connection when done
close(scn);

