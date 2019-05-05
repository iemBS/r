
# Install non-default libraries if not already installed
	# install.packages("RODBC")
# Create Linked Server connection to use for scn2 connection
	# EXECUTE sp_addlinkedserver @server = 'LinkedSASMBRPT03',@provider = 'MSOLAP',@srvproduct = '',@datasrc = 'SASMBRPT03', @catalog='ARC'
	# EXECUTE sp_serveroption 'LinkedSASMBRPT03', 'rpc', 'true'
	# EXECUTE sp_serveroption 'LinkedSASMBRPT03', 'rpc out', 'true'
	# EXEC master.dbo.sp_MSset_oledb_prop N'MOLAP', N'AllowInProcess', 1
# Create Linked Server connection to use for scn connection

# Load non-default libraries
library(RODBC)

# Get connection to DB (on my laptop)
scn <- odbcDriverConnect(
	connection="
		Driver={SQL Server Native Client 11.0};
		server=localhost;
		database=master;
		trusted_connection=yes;"
);

# Load Account Number & Account ID from CSV to R data frame
setwd("C:/AnO");
csv <- read.csv(file="AcctNumList.csv",header=TRUE,sep=",");

queryTemplate <- "
Select
{
  Measures.[Net Revenue]
} On Columns, 
(
  {INSERT} * 
  {[Account].[Account ID].[Account ID].Members} 
)  
Having IsEmpty(Measures.[Net Revenue]) 
On Rows
From
	ARC
Where 
 (
  {
	[Calendar].[Fiscal Monthly].[Fiscal Month].&[2015-10],
	[Calendar].[Fiscal Monthly].[Fiscal Month].&[2015-11],
	[Calendar].[Fiscal Monthly].[Fiscal Month].&[2015-12],
	[Calendar].[Fiscal Monthly].[Fiscal Month].&[2016-01],
	[Calendar].[Fiscal Monthly].[Fiscal Month].&[2016-02]
  }, 
  {
	[Segment - Current].[Service].&[Current - SMB - Mid-Market],
	[Segment - Current].[Service].&[Current - Strategic - Strategic]
  }
)"

# Create destination table
t2 <- data.frame(AccountNumber = character(70000),AccountID = numeric(70000),stringsAsFactors = FALSE);

# Number of rows to expect in destination table
tRow <- nrow(csv);

# Mark what batch account number will be pulled in
i <- 1;
csv$batch <- 0;
for(r in csv[,c("AccountNumber")]){
	csv$batch[i] <- round(i/50);
	i <- i + 1;
}

i <- 1;
j <- 1;
# Loop through batches of account numbers
for(b in unique(csv[,c("batch")])){

	r <- csv[csv$batch == b,c("AccountNumber")]
	
	# update account numbers to look like cube attributes
	r <- paste(paste("[Account].[Acct_Num].&[",r,sep=""),"]",sep="");

	# turn array into comma delimited list
	lst <- r[1];
	for(m in 2:length(r)){
		lst <- paste(lst,r[m],sep=",");
	}

	# put account numbers into query
	query <- queryTemplate;
	query <- gsub("INSERT",lst,query);
	query <- paste("Select \"[Account].[Acct_Num].[Acct_Num].[MEMBER_CAPTION]\" As AccountNumber,\"[Account].[Account ID].[Account ID].[MEMBER_CAPTION]\" As AccountID From OpenQuery(LinkedSASMBRPT03,'",query,"')",sep="");

	# Pull Account Number, Account ID from cube
	t1 <- NULL;
	t1 <- sqlQuery(scn,query);

	# increment query execution number
	print(paste("query execution:",j,sep=""));
	j <- j + 1;
	
	# skip if there is an error
	if(is.null(nrow(t1))){next;}

	# skip if no data returned
	if(nrow(t1) == 0){next;}

	# append new data to existing data
	v1 <- as.vector(t1[,c("AccountNumber")]);
	v2 <- as.vector(t1[,c("AccountID")]);

	k <- 1;
	while(k <= nrow(t1)){
		t2$AccountNumber[i] <- v1[k];
		t2$AccountID[i] <- v2[k];

		# increment destination table row number
		print(paste("row:",i,sep=""));
		i <- i + 1;
		k <- k + 1;
	}
}
# Export data to CSV file
write.csv(t2,file = "map2AccountID.csv");

# Close DB connection when done
close(scn);

