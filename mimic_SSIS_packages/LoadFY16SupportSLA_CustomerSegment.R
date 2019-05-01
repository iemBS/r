
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
dcn <- odbcDriverConnect(
	connection="
		Driver={SQL Server Native Client 11.0};
		server=adcrmsql;
		database=CnO_BI_PowerPivot_FY16;
		trusted_connection=yes;"
);

scn <- odbcDriverConnect(
	connection="
		Driver={SQL Server Native Client 11.0};
		server=localhost;
		database=master;
		trusted_connection=yes;"
);

# CustomerIDList
t1 <- sqlQuery(dcn,"
Select  
	Cast(CustomerID As Varchar(25)) AS CustomerID, 
	(ROW_NUMBER() OVER (ORDER BY CustomerID)) / 50 As CustomerBatchID
From
	(
		Select Distinct CustomerID From StgSupportSLA Where CustomerID != 'No Customer Id'
	) t
");

attach(t1);
t2 <- data.frame(CustomerBatchID = numeric(20000),CustomerID = character(20000), stringsAsFactors = FALSE);
t2Cnt <- 1
for(bID in unique(t1[,c("CustomerBatchID")])){
	v1 <- as.vector(t1[CustomerBatchID == bID,c("CustomerID")])
	for(cID in v1){
		if(is.numeric(cID)){
			t2$CustomerBatchID[t2Cnt] <- bID 
			t2$CustomerID[t2Cnt] <- paste("[ACCOUNT].[CUSTOMER ID].[",cID,"]",sep="")
			t2Cnt <- t2Cnt + 1
		}
	}
};

t2_1 <- t2[grep("Account",t2$CustomerID,ignore.case=T),c("CustomerID","CustomerBatchID")];

t3 <- data.frame(CustomerBatchID = numeric(300),CustomerIDList = character(300), stringsAsFactors = FALSE);
t3Cnt <- 1
for(bID in unique(t2_1[,c("CustomerBatchID")])){
	v2 <- as.vector(t2_1[CustomerBatchID == bID,c("CustomerID")])
	t3$CustomerBatchID[t3Cnt] <- bID
	t3$CustomerIDList[t3Cnt] <- paste(v2,collapse=",")
	t3Cnt <- t3Cnt + 1
};

t3_1 <- t3[grep("Account",t3$CustomerID,ignore.case=T),c("CustomerIDList","CustomerBatchID")];

# For Loop Container
require(stringr);
t5Cnt <- 1;
t5 <- data.frame(CustomerID = character(200000),Acct_Num = character(200000),Segment = character(200000), stringsAsFactors = FALSE);
for(cList in t3_1[,c("CustomerIDList")]){
	# Put Query into variable
	query <- paste(
		"
		Select
			{
				[Measures].[Impressions]
			} On Columns, 
			NON EMPTY (
				[Account].[Customer].[Acct_Num].Members * 
				Except(
					[Segment - Current].[Service].Members,
					{
						[Segment - Current].[Service].[All]
					})
			) 
			DIMENSION PROPERTIES MEMBER_CAPTION, MEMBER_UNIQUE_NAME
			On Rows
		From
			(
				Select
					{[Calendar].[Fiscal Yearly].[Fiscal Year].&[2016]} On Columns,
					{",cList,"} On Rows
				From
					[ARC]		
			)",
		collapse=""
	);
	query <- paste("Select 
				\"[Account].[Customer].[Customer ID].[MEMBER_CAPTION]\" As CustomerID,
				\"[Account].[Customer].[Acct_Num].[MEMBER_CAPTION]\" As Acct_Num,
				\"[Segment - Current].[Service].[Service].[MEMBER_CAPTION]\" As Segment,
				\"[Measures].[Impressions]\" As ImpressionCnt 
				From OpenQuery(LinkedSASMBRPT03,'",query,"')",collapse="");

	# Load Data
	t4 <- sqlQuery(scn,query);

	if(nrow(t4) > 0){
		for(t4Cnt in 1:nrow(t4)){
			t5$CustomerID[t5Cnt] <- t4$CustomerID[t4Cnt]
			t5$Acct_Num[t5Cnt] <- substr(t4$Acct_Num[t4Cnt],1,str_length(t4$Acct_Num[t4Cnt]))
			t5$Segment[t5Cnt] <- substr(t4$Segment[t4Cnt],1,str_length(t4$Segment[t4Cnt]))
			t5Cnt <- t5Cnt + 1
		}
	}
	t4 <- NULL
};

require(stringr)
t5_1 <- t5[str_length(t5$CustomerID) > 0,c("CustomerID","Acct_Num","Segment")];

# Analysis
	# Get the top few rows
	head(t5_1)

	# Number of rows
	nrow(t5_1)

	# Possible invalid CustomerName
	t5_1[grep("\\?",t5_1$Acct_Num,ignore.case=T),c("CustomerID","Acct_Num","Segment")]

	# Number of rows with possible invalid CustomerName
	nrow(t5_1[grep("\\?",t5_1$Acct_Num,ignore.case=T),c("CustomerID","Acct_Num","Segment")])

	# Export possible invalid CustomerName to .CSV file (will not create a file if there is nothing to write)
	write.csv(
		t5_1[grep("\\?",t5_1$Acct_Num,ignore.case=T),c("CustomerID","Acct_Num","Segment")],
		file="E:\\ScottFiles\\temp\\t_151130\\MS_AnO\\invalidAcctNum.csv",
		row.names=FALSE	
	)

	# Export possible invalid CustomerName to .XLSX file (need Java installed to run, have not gotten this to work yet)
		# http://www.statmethods.net/input/exportingdata.html
		# install xlsx package
	library(xlsx)
	write.xlsx(t5_1, "E:\\ScottFiles\\temp\\t_151130\\MS_AnO\\mydata.xlsx") 

	# Order by Segment ascending
	attach(t5_1)
	t5_1[order(Segment),c("CustomerID","Acct_Num","Segment")]

	# Get distinct Segment, order by Segment ascending
	attach(t5_1)
	unique(t5_1[order(Segment),c("Segment")])

	# Same Acct_Num across two different CustomerID
	cust <- t5_1[,c("Acct_Num","CustomerID")]
	cust$IsDupeName <- duplicated(cust$Acct_Num)
	attach(cust)
	cust[order(Acct_Num),c("Acct_Num","IsDupeName","CustomerID")]

	# Customer count per segment
	attach(t5_1)
	t5_1[order(Segment),c("CustomerID","Acct_Num","Segment")]
	
	channelPartner <- sum(Segment == "Channel Partner")
	channelPartner
	midMarket <- sum(Segment == "Mid-Market")
	midMarket
	premiumYahoo <- sum(Segment == "Premium - Yahoo")
	premiumYahoo
	selfServe <- sum(Segment == "Self-Serve")
	selfServe
	strategic <- sum(Segment == "Strategic")
	strategic 

# Close DB connection when done
close(dcn);
close(scn);

