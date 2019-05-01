
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
		server=SASMARTSQL10;
		database=Yahoo_Transition;
		trusted_connection=yes;"
);

scn2 <- odbcDriverConnect(
	connection="
		Driver={SQL Server Native Client 11.0};
		server=localhost;
		database=master;
		trusted_connection=yes;"
);

# Customer Transition Date
	# Truncate dest table
	t1 <- sqlQuery(dcn,"
		Select
		  Cast(TransitionDateStart As Date) As TransitionDateStart,
		  Cast(TransitionDateEnd As Date) As TransitionDateEnd,
		  Cast(RevenueDateStart As Date) As RevenueDateStart,
		  Cast(RevenueDateEnd As Date) As RevenueDateEnd
		From
		  StgTransitionDateRangeYTD_PostTranRevGrowth
		Where
		  CompletedFiscalMonthName In 
		  (
			Select
				FiscalMonthName
			From
				StgDateMapping
			Where
				FiscalMonthPosition = -1
		  ) 
	");

	# Load Data
	query <- paste("
			Select
				CustomerID,
				TransitionDate
			From
				(
					select 
						CustomerId, 
						Cast
						(
							Case
								When TransitionDate Is Null Then ModifiedDtim
								Else TransitionDate
							End
							As Date
						) As TransitionDate
					from 
						[ConsolidatedDB].[TransitionCustomerGroup]
					Where
						TransitionStatusName = 'Customer transitioned' 
						And
						CustomerId Is Not null
				) t
			Where
				TransitionDate Between '",t1$TransitionDateStart[1],"' And '",t1$TransitionDateEnd[1],"'",sep="");
	t2 <- sqlQuery(scn,query);

	# Analysis
		# summary
		#summary(t2)
		
		# top few rows
		#head(t2)
	
		# number of rows
		#nrow(t2)
		
rds <- t1[,c("RevenueDateStart")][1]
rde <- t1[,c("RevenueDateEnd")][1]
rdsp <- as.Date(rds,"%Y-%m-%d")
rdsp <- paste(as.character(as.numeric(format(rdsp,"%Y")) - 1),
	"-",
	format(rdsp,"%m"),
	"-",
	format(rdsp,"%d"),
	sep="");
rdsp <- gsub("^\\s+|\\s+$", "",as.character(rdsp))
rdep <- as.Date(rde,"%Y-%m-%d")
rdep <- paste(as.character(as.numeric(format(rdep,"%Y")) - 1),
	"-", 
	format(rdep,"%m"),
	"-", 
	format(rdep,"%d"),
	sep="");
rdep <- gsub("^\\s+|\\s+$", "",as.character(rdep))

# Load Data - Transition Date
msStrt <- date()
t7 <- data.frame(Rev = numeric(70000),SoldBy = character(70000),AccountType = character(70000),Publisher = character(70000),CustomerID = numeric(70000),FiscalMonth = character(70000),Segment = character(70000),Vertical = character(70000),stringsAsFactors = FALSE);
t7r <- 1
for(td in unique(t2[order(t2$TransitionDate),c("TransitionDate")])){
	# CustomerIDList
	td2 <- as.Date(td, origin="1970-01-01")
	print(paste("transaction date: ",td2,sep="")) #test
	print(paste("transaction date loop start: ",date(),sep="")) #test
	v1 <- as.vector(t2[t2$TransitionDate == td2,c("CustomerID")])
	cbid <- 1
	r <- 1
	tbln <- nrow(t2[t2$TransitionDate == td2,])
	t3 <- data.frame(CustomerBatchID = numeric(tbln),CustomerID = character(tbln), stringsAsFactors = FALSE);
	for(cID in v1){
		t3$CustomerBatchID[r] <- cbid
		t3$CustomerID[r] <- paste("[ACCOUNT].[CUSTOMER ID].[",cID,"]",sep="") 
		r <- r + 1
		if((r-1) %% 200 == 0){
			print(paste("# of customers for transition date ",td2," & customer batch ",cbid,": ",nrow(t3[t3$CustomerBatchID == cbid,]),sep="")) #test
			cbid <- cbid + 1
		}
	}; 
	if(nrow(t3[t3$CustomerBatchID == cbid,]) < 200){
		print(paste("# of customers for transition date ",td2," & customer batch ",cbid,": ",nrow(t3[t3$CustomerBatchID == cbid,]),sep="")) #test
	}
	
	r <- 1
	tbln <- ceiling(tbln / 200)
	t4 <- data.frame(CustomerBatchID = numeric(tbln),CustomerIDList = character(tbln), stringsAsFactors = FALSE);
	for(cbid in unique(t3[,c("CustomerBatchID")])){
		t4$CustomerBatchID[r] <- cbid
		lst <- ""
		for(cID in unique(t3[t3$CustomerBatchID == cbid,c("CustomerID")])){
			lst <- paste(lst,",",cID,sep="") 
		}
		t4$CustomerIDList[r] <- substr(lst,2,nchar(lst))
		r <- r + 1
	}; 

	# Load Data - Customer ID
	for(cbID in unique(t4[,c("CustomerBatchID")])){
		# Microsoft Managed
		cIDl <- t4[t4$CustomerBatchID == cbID,c("CustomerIDList")][1]
		print(paste("before ms-rev pull: ",date(),sep="")) #test
		t5 <- NULL;
		query <- paste("
				Select
					Measures.[Net Revenue] On Columns
				From
					[ARC]	
				Where
					(
						{",cIDl,"}, 
						{
							[Calendar].[Day].&[",rdsp,"T00:00:00]:[Calendar].[Day].&[",rdep,"T00:00:00],
							[Calendar].[Day].&[",rds,"T00:00:00]:[Calendar].[Day].&[",rde,"T00:00:00]
						},
						{[Publisher].[Publisher Network].&[Microsoft - O&O]},
						Except(
							[Segment - Current].[Service].Members,
							{
								[Segment - Current].[Service].[All]
							})
					)"
		,sep="");
		query <- paste("Select 
				\"[Measures].[Net Revenue]\" As Rev 
				From OpenQuery(LinkedSASMBRPT03,'",query,"')",sep="");
		t5 <- sqlQuery(scn2,query);
		print(paste("after ms-rev pull: ",date(),sep="")) #test
		if(!is.null(t5)){if(is.na(t5)){t5 <- NULL}}
		print(paste("MS-Rev for transition date ",td2," & customer batch ",cbID,":",t5,sep="")) #test
		t12 <- NULL
		if(exists("t5") && !is.null(t5)){
			print(paste("before ms-detail pull: ",date(),sep="")) #test
			query <- paste("With Member Measures.[Rev] As IIF(Measures.[Net Revenue] = 0,NULL,Measures.[Net Revenue]) 
					Select
						{
							[Measures].[Rev]
						} On Columns, 
						NON EMPTY 
						(
							Except([Channel - Service].[Country Name].members,[Channel - Service].[Country Name].[All]) *  
							Except([Sold By - Historical].[Sold By].members,[Sold By - Historical].[Sold By].[All]) *  
							Except([Account Type].[Account Type].members,[Account Type].[Account Type].[All]) * 
							Except([Publisher].[Publisher].members,[Publisher].[Publisher].[All]) * 
							{",cIDl,"} * 
							Except([Calendar].[Fiscal Month].members,[Calendar].[Fiscal Month].[All]) * 
							Except(
								[Segment - Current].[Service].Members,
								{
									[Segment - Current].[Service].[All]
								})  * 
							[Verticals - Algo].[Algo Verticals].[Primary].Members
						) On Rows
					From
						[ARC] Where 
						(
							{[Publisher].[Publisher Network].&[Microsoft - O&O]},
							{
								[Calendar].[Day].&[",rdsp,"T00:00:00]:[Calendar].[Day].&[",rdep,"T00:00:00],
								[Calendar].[Day].&[",rds,"T00:00:00]:[Calendar].[Day].&[",rde,"T00:00:00]
							}
						)"
			,sep="");
			query <- paste("Select 
					\"[Measures].[Rev]\" As Rev,
					\"[Sold By - Historical].[Sold By].[Sold By].[MEMBER_CAPTION]\" As SoldBy,
					\"[Account Type].[Account Type].[Account Type].[MEMBER_CAPTION]\" As AccountType,
					\"[Publisher].[Publisher].[Publisher].[MEMBER_CAPTION]\" As Publisher,
					\"[ACCOUNT].[CUSTOMER ID].[CUSTOMER ID].[MEMBER_CAPTION]\" As CustomerID,
					\"[Calendar].[Fiscal Month].[Fiscal Month].[MEMBER_CAPTION]\" AS FiscalMonth,
					\"[Segment - Current].[Service].[Service].[MEMBER_CAPTION]\" As Segment,
					\"[Verticals - Algo].[Algo Verticals].[Primary].[MEMBER_CAPTION]\" As Vertical
					From OpenQuery(LinkedSASMBRPT03,'",query,"')",sep="");
			t12 <- sqlQuery(scn2,query);
			print(paste("after ms-detail pull: ",date(),sep="")) #test
		}

		if(exists("t12") && !is.null(t12) && (nrow(t12) > 0)){
			#print(paste("before ms-detail copy: ",date(),sep="")) #test
			v1 <- as.vector(t12[,c("Rev")])
			v2 <- as.vector(t12[,c("SoldBy")])
			v3 <- as.vector(t12[,c("AccountType")])
			v4 <- as.vector(t12[,c("Publisher")])
			v5 <- as.vector(t12[,c("CustomerID")])
			v6 <- as.vector(t12[,c("FiscalMonth")])
			v7 <- as.vector(t12[,c("Segment")])
			v8 <- as.vector(t12[,c("Vertical")])
			for(t12r in 1:nrow(t12)){
				t7$Rev[t7r] <- v1[t12r]
				t7$SoldBy[t7r] <- v2[t12r]
				t7$AccountType[t7r] <- v3[t12r]
				t7$Publisher[t7r] <- v4[t12r]
				t7$CustomerID[t7r] <- v5[t12r]
				t7$FiscalMonth[t7r] <- v6[t12r]
				t7$Segment[t7r] <- v7[t12r]
				t7$Vertical[t7r] <- v8[t12r]
				t7r <- t7r + 1
			}
			#print(paste("after detail copy: ",date(),sep="")) #test
			print(paste("# of source rows so far at transition date ",td2," & customer batch ",cbID,":",nrow(t7[t7$Rev > 0,]),sep="")) #test
		}
		
		# Analysis
			# summary
			#summary(t5)
			
			# top few rows
			#head(t5)

			# number of rows
			#nrow(t5)

			# Distinct list of Segment
			#attach(t5)
			#unique(t5[order(Segment),c("Segment")])

			# Count of CustomerID per Segment
			#[add script]

			# Count of CustomerID per RevenueDate
			#[add script]
	}; # End of Customer Batch for loop
	print(paste("transaction date loop end: ",date(),sep="")) #test
}; # End of Transition Date for loop
#print(paste("MS data pull run time:",difftime(msStrt,date(),units = "mins")," minutes",sep="")) #test

# Yahoo Managed
query <- "  Select Distinct 
			a.CustomerID,
			b.Name As CustomerName
		From
			ConsolidatedDB.TransitionCustomerGroup a
			Left Outer Join BingAds.Customer b On 
				a.CustomerID = b.CustomerId"
t8 <- sqlQuery(scn,query);

	# Analysis
		# number of rows
		nrow(t8)

		# Add a cnt column so I can apply the sum aggregation
		#t8$Cnt <- 1

		# reduce number of columns before aggregation
		#t8_1 <- t8[,c("CustomerID","Cnt")]

		# count number of rows per customer
		#attach(t8_1)
		#t8_2 <- aggregate(t8_1,by=list(CustomerID),FUN=sum)

		# number of customers with duplicates
		#nrow(t8_2[t8_2$Cnt > 1,]) 

r <- 1
cbid <- 1
tbln <- nrow(t8)
t9 <- data.frame(CustomerBatchID = numeric(tbln),CustomerID = character(tbln), stringsAsFactors = FALSE);
for(cID in unique(t8$CustomerID)){
	t9$CustomerBatchID[r] <- cbid
	t9$CustomerID[r] <- paste("[ACCOUNT].[CUSTOMER ID].[",cID,"]",sep="") 
	r <- r + 1
	if((r-1) %% 200 == 0){
		print(paste("# of customers for customer batch ",cbid,": ",nrow(t9[t9$CustomerBatchID == cbid,]),sep="")) #test
		cbid <- cbid + 1
	}
}; 
if(nrow(t9[t9$CustomerBatchID == cbid,]) < 200){
	print(paste("# of customers for customer batch ",cbid,": ",nrow(t9[t9$CustomerBatchID == cbid,]),sep="")) #test
}
	
r <- 1
tbln <- ceiling(tbln / 200)
t10 <- data.frame(CustomerBatchID = numeric(tbln),CustomerIDList = character(tbln), stringsAsFactors = FALSE);
for(cbid in unique(t9[,c("CustomerBatchID")])){
	t10$CustomerBatchID[r] <- cbid
	lst <- ""
	for(cID in unique(t9[t9$CustomerBatchID == cbid,c("CustomerID")])){
		lst <- paste(lst,",",cID,sep="") 
	}
	t10$CustomerIDList[r] <- substr(lst,2,nchar(lst))
	r <- r + 1
};

t13 <- data.frame(Rev = numeric(300000),SoldBy = character(300000),AccountType = character(300000),Publisher = character(300000),CustomerID = numeric(300000),FiscalMonth = character(300000),Segment = character(300000),Vertical = character(300000),stringsAsFactors = FALSE);
t13r <- 1
for(cbid in unique(t10[order(t10$CustomerBatchID),c("CustomerBatchID")])){
	print(paste("y-CustomerBatchID: ",cbid,sep="")) #test
	print(paste("y-CustomerBatch loop start: ",date(),sep="")) #test
	cIDl <- t10[t10$CustomerBatchID == cbID,c("CustomerIDList")][1]
	print(paste("before y-rev pull: ",date(),sep="")) #test
	t11 <- NULL;
	query <- paste("
			Select
				Measures.[Net Revenue] On Columns
			From
				[ARC]	
			Where
				(
					{",cIDl,"}, 
					{
						[Calendar].[Day].&[",rdsp,"T00:00:00]:[Calendar].[Day].&[",rdep,"T00:00:00],
						[Calendar].[Day].&[",rds,"T00:00:00]:[Calendar].[Day].&[",rde,"T00:00:00]
					},
					{[Publisher].[Publisher Network].&[Microsoft - O&O]},
					Except(
						[Segment - Current].[Service].Members,
						{
							[Segment - Current].[Service].[All]
						})
				)"				
	,sep="");
	query <- paste("Select 
			\"[Measures].[Net Revenue]\" As Rev 
			From OpenQuery(LinkedSASMBRPT03,'",query,"')",sep="");
	t11 <- sqlQuery(scn2,query);
	print(paste("after y-rev pull: ",date(),sep="")) #test
	if(!is.null(t11)){if(is.na(t11)){t11 <- NULL}}
	print(paste("Y-Rev for customer batch ",cbID,":",t11,sep="")) #test
	t12 <- NULL
	if(exists("t11") && !is.null(t11)){
		print(paste("before y-detail pull: ",date(),sep="")) #test
		query <- paste("With Member Measures.[Rev] As IIF(Measures.[Net Revenue] = 0,NULL,Measures.[Net Revenue]) 
				Select
					{
						[Measures].[Rev]
					} On Columns, 
					NON EMPTY 
					(
						Except([Channel - Service].[Country Name].members,[Channel - Service].[Country Name].[All]) *  
						Except([Sold By - Historical].[Sold By].members,[Sold By - Historical].[Sold By].[All]) *  
						Except([Account Type].[Account Type].members,[Account Type].[Account Type].[All]) * 
						Except([Publisher].[Publisher].members,[Publisher].[Publisher].[All]) * 
						{",cIDl,"} * 
						Except([Calendar].[Fiscal Month].members,[Calendar].[Fiscal Month].[All]) * 
						Except(
							[Segment - Current].[Service].Members,
							{
								[Segment - Current].[Service].[All]
							})  * 
						[Verticals - Algo].[Algo Verticals].[Primary].Members
					) On Rows
				From
					[ARC] Where 
					(
						{[Publisher].[Publisher Network].&[Microsoft - O&O]},
						{
							[Calendar].[Day].&[",rdsp,"T00:00:00]:[Calendar].[Day].&[",rdep,"T00:00:00],
							[Calendar].[Day].&[",rds,"T00:00:00]:[Calendar].[Day].&[",rde,"T00:00:00]
						} -- Revenue Date Range
					)"
		,sep="");
		query <- paste("Select 
				\"[Measures].[Rev]\" As Rev,
				\"[Sold By - Historical].[Sold By].[Sold By].[MEMBER_CAPTION]\" As SoldBy,
				\"[Account Type].[Account Type].[Account Type].[MEMBER_CAPTION]\" As AccountType,
				\"[Publisher].[Publisher].[Publisher].[MEMBER_CAPTION]\" As Publisher,
				\"[ACCOUNT].[CUSTOMER ID].[CUSTOMER ID].[MEMBER_CAPTION]\" As CustomerID, 
				\"[Calendar].[Fiscal Month].[Fiscal Month].[MEMBER_CAPTION]\" AS FiscalMonth,
				\"[Segment - Current].[Service].[Service].[MEMBER_CAPTION]\" As Segment,
				\"[Verticals - Algo].[Algo Verticals].[Primary].[MEMBER_CAPTION]\" As Vertical
				From OpenQuery(LinkedSASMBRPT03,'",query,"')",sep="");
		t12 <- sqlQuery(scn2,query);
		print(paste("after y-detail pull: ",date(),sep="")) #test
	} # End of t11 if condition

	if(exists("t12") && !is.null(t12) && (nrow(t12) > 0)){
		#print(paste("before y-detail copy: ",date(),sep="")) #test
		v1 <- as.vector(t12[,c("Rev")])
		v2 <- as.vector(t12[,c("SoldBy")])
		v3 <- as.vector(t12[,c("AccountType")])
		v4 <- as.vector(t12[,c("Publisher")])
		v5 <- as.vector(t12[,c("CustomerID")])
		v6 <- as.vector(t12[,c("FiscalMonth")])
		v7 <- as.vector(t12[,c("Segment")])
		v8 <- as.vector(t12[,c("Vertical")])
		for(t12r in 1:nrow(t12)){
			t13$Rev[t13r] <- v1[t12r]
			t13$SoldBy[t13r] <- v2[t12r]
			t13$AccountType[t13r] <- v3[t12r]
			t13$Publisher[t13r] <- v4[t12r]
			t13$CustomerID[t13r] <- v5[t12r]
			t13$FiscalMonth[t13r] <- v6[t12r]
			t13$Segment[t13r] <- v7[t12r]
			t13$Vertical[t13r] <- v8[t12r]
			t13r <- t13r + 1
		}
		#print(paste("after y-detail copy: ",date(),sep="")) #test
		print(paste("# of y-source rows so far at customer batch ",cbID,":",nrow(t13[t13$Rev != 0,]),sep="")) #test
	} # End of t12 if condition
	print(paste("y-CustomerBatch loop end: ",date(),sep="")) #test
}; # End of looping through cbid for t10

# Analysis
	# summary
	#summary(t13)

	# top few rows
	#head(t13)

	# number of rows
	#nrow(t13)

	# Distinct list of Segment
	#attach(t13)
	#unique(t13[order(Segment),c("Segment")])

	# Count of CustomerID per Segment
	#[add script]

	# Count of CustomerID per RevenueDate
	#[add script]

# "LoadFY16CustomerToBeTransitioned package" and "Limit to Planned Transfers"
	# Instead of doing these tasks after the Yahoo data pull from ARC I am using them to limit the data Yahoo data pull from ARC.

# LoadFY16CustomerCountry - Run the R script that represents this package & watch out for duplicate dataframe names

# LoadFY16CustomerTransitionSegment - Run the R script that represents this package & watch out for duplicate dataframe names

# Close DB connection when done
close(dcn);
close(scn);
close(scn2);

