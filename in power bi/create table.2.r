library(gridExtra)
library(grid);
library(tools);

df <- dataset;

# first row
c1 <- (x1y1 <- "Rank")
c2 <- (x2y1 <- "Total Top Advertisers")
c3 <- (x3y1 <- "YTD")
c4 <- (x4y1 <- "YoY$")
c5 <- (x5y1 <- "YoY%")
c6 <- (x6y1 <- "% of Total")

# second row
df_row2 <- df[df$Rnk == "1",c("Rnk","AdvertiserName","ytdRevenue","yoyRevenue","yoyPct","mtdPctOfTotal","IsDirectAdvertiser")];
c7  <- (x1y2 <- df_row2$Rnk[1])
c8  <- (x2y2 <- df_row2$AdvertiserName[1])
c8ff <- if(df_row2$IsDirectAdvertiser[1] == TRUE) "italic" else "plain"
c9  <- (x3y2 <- df_row2$ytdRevenue[1])
c10 <- (x4y2 <- df_row2$yoyRevenue[1])
c11 <- (x5y2 <- df_row2$yoyPct[1])
c12 <- (x6y2 <- df_row2$mtdPctOfTotal[1])

# third row
df_row3 <- df[df$Rnk == "2",c("Rnk","AdvertiserName","ytdRevenue","yoyRevenue","yoyPct","mtdPctOfTotal","IsDirectAdvertiser")];
c13 <- (x1y3 <- df_row3$Rnk[1])
c14 <- (x2y3 <- df_row3$AdvertiserName[1])
c14ff <- if(df_row3$IsDirectAdvertiser[1] == TRUE) "italic" else "plain"
c15 <- (x3y3 <- df_row3$ytdRevenue[1])
c16 <- (x4y3 <- df_row3$yoyRevenue[1])
c17 <- (x5y3 <- df_row3$yoyPct[1])
c18 <- (x6y3 <- df_row3$mtdPctOfTotal[1])

# fourth row
df_row4 <- df[df$Rnk == "3",c("Rnk","AdvertiserName","ytdRevenue","yoyRevenue","yoyPct","mtdPctOfTotal","IsDirectAdvertiser")];
c19 <- (x1y4 <- df_row4$Rnk[1])
c20 <- (x2y4 <- df_row4$AdvertiserName[1])
c20ff <- if(df_row4$IsDirectAdvertiser[1] == TRUE) "italic" else "plain"
c21 <- (x3y4 <- df_row4$ytdRevenue[1])
c22 <- (x4y4 <- df_row4$yoyRevenue[1])
c23 <- (x5y4 <- df_row4$yoyPct[1])
c24 <- (x6y4 <- df_row4$mtdPctOfTotal[1])

# fifth row
df_row5 <- df[df$Rnk == "4",c("Rnk","AdvertiserName","ytdRevenue","yoyRevenue","yoyPct","mtdPctOfTotal","IsDirectAdvertiser")];
c25 <- (x1y5 <- df_row5$Rnk[1])
c26 <- (x2y5 <- df_row5$AdvertiserName[1])
c26ff <- if(df_row5$IsDirectAdvertiser[1] == TRUE) "italic" else "plain"
c27 <- (x3y5 <- df_row5$ytdRevenue[1])
c28 <- (x4y5 <- df_row5$yoyRevenue[1])
c29 <- (x5y5 <- df_row5$yoyPct[1])
c30 <- (x6y5 <- df_row5$mtdPctOfTotal[1])

# sixth row
df_row6 <- df[df$Rnk == "5",c("Rnk","AdvertiserName","ytdRevenue","yoyRevenue","yoyPct","mtdPctOfTotal","IsDirectAdvertiser")];
c31 <- (x1y6 <- df_row6$Rnk[1])
c32 <- (x2y6 <- df_row6$AdvertiserName[1])
c32ff <- if(df_row6$IsDirectAdvertiser[1] == TRUE) "italic" else "plain"
c33 <- (x3y6 <- df_row6$ytdRevenue[1])
c34 <- (x4y6 <- df_row6$yoyRevenue[1])
c35 <- (x5y6 <- df_row6$yoyPct[1])
c36 <- (x6y6 <- df_row6$mtdPctOfTotal[1])

# 7th row
df_row7 <- df[df$Rnk == "6",c("Rnk","AdvertiserName","ytdRevenue","yoyRevenue","yoyPct","mtdPctOfTotal","IsDirectAdvertiser")];
c37 <- (x1y7 <- df_row7$Rnk[1])
c38 <- (x2y7 <- df_row7$AdvertiserName[1])
c38ff <- if(df_row7$IsDirectAdvertiser[1] == TRUE) "italic" else "plain"
c39 <- (x3y7 <- df_row7$ytdRevenue[1])
c40 <- (x4y7 <- df_row7$yoyRevenue[1])
c41 <- (x5y7 <- df_row7$yoyPct[1])
c42 <- (x6y7 <- df_row7$mtdPctOfTotal[1])

# 8th row
df_row8 <- df[df$Rnk == "7",c("Rnk","AdvertiserName","ytdRevenue","yoyRevenue","yoyPct","mtdPctOfTotal","IsDirectAdvertiser")];
c43 <- (x1y8 <- df_row8$Rnk[1])
c44 <- (x2y8 <- df_row8$AdvertiserName[1])
c44ff <- if(df_row8$IsDirectAdvertiser[1] == TRUE) "italic" else "plain"
c45 <- (x3y8 <- df_row8$ytdRevenue[1])
c46 <- (x4y8 <- df_row8$yoyRevenue[1])
c47 <- (x5y8 <- df_row8$yoyPct[1])
c48 <- (x6y8 <- df_row8$mtdPctOfTotal[1])

# 9th row
df_row9 <- df[df$Rnk == "8",c("Rnk","AdvertiserName","ytdRevenue","yoyRevenue","yoyPct","mtdPctOfTotal","IsDirectAdvertiser")];
c49 <- (x1y9 <- df_row9$Rnk[1])
c50 <- (x2y9 <- df_row9$AdvertiserName[1])
c50ff <- if(df_row9$IsDirectAdvertiser[1] == TRUE) "italic" else "plain"
c51 <- (x3y9 <- df_row9$ytdRevenue[1])
c52 <- (x4y9 <- df_row9$yoyRevenue[1])
c53 <- (x5y9 <- df_row9$yoyPct[1])
c54 <- (x6y9 <- df_row9$mtdPctOfTotal[1])

# 10th row
df_row10 <- df[df$Rnk == "9",c("Rnk","AdvertiserName","ytdRevenue","yoyRevenue","yoyPct","mtdPctOfTotal","IsDirectAdvertiser")];
c55 <- (x1y10 <- df_row10$Rnk[1])
c56 <- (x2y10 <- df_row10$AdvertiserName[1])
c56ff <- if(df_row10$IsDirectAdvertiser[1] == TRUE) "italic" else "plain"
c57 <- (x3y10 <- df_row10$ytdRevenue[1])
c58 <- (x4y10 <- df_row10$yoyRevenue[1])
c59 <- (x5y10 <- df_row10$yoyPct[1])
c60 <- (x6y10 <- df_row10$mtdPctOfTotal[1])

# 11th row
df_row11 <- df[df$Rnk == "10",c("Rnk","AdvertiserName","ytdRevenue","yoyRevenue","yoyPct","mtdPctOfTotal","IsDirectAdvertiser")];
c61 <- (x1y11 <- df_row11$Rnk[1])
c62 <- (x2y11 <- df_row11$AdvertiserName[1])
c62ff <- if(df_row11$IsDirectAdvertiser[1] == TRUE) "italic" else "plain"
c63 <- (x3y11 <- df_row11$ytdRevenue[1])
c64 <- (x4y11 <- df_row11$yoyRevenue[1])
c65 <- (x5y11 <- df_row11$yoyPct[1])
c66 <- (x6y11 <- df_row11$mtdPctOfTotal[1])

# 12th row
df_row12 <- df[df$AdvertiserName == "Top 10",c("AdvertiserName","ytdRevenue","yoyRevenue","yoyPct","mtdPctOfTotal","IsDirectAdvertiser")];
c67 <- (x1y12 <- "")
c68 <- (x2y12 <- df_row12$AdvertiserName[1])
c69 <- (x3y12 <- df_row12$ytdRevenue[1])
c70 <- (x4y12 <- df_row12$yoyRevenue[1])
c71 <- (x5y12 <- df_row12$yoyPct[1])
c72 <- (x6y12 <- df_row12$mtdPctOfTotal[1])

# 13th row
df_row13 <- df[df$AdvertiserName == "Total",c("AdvertiserName","ytdRevenue","yoyRevenue","yoyPct","mtdPctOfTotal","IsDirectAdvertiser")];
c73 <- (x1y13 <- "")
c74 <- (x2y13 <- df_row13$AdvertiserName[1])
c75 <- (x3y13 <- df_row13$ytdRevenue[1])
c76 <- (x4y13 <- df_row13$yoyRevenue[1])
c77 <- (x5y13 <- df_row13$yoyPct[1])
c78 <- (x6y13 <- df_row13$mtdPctOfTotal[1])

# Get max advertiser name
df$AdvNameLen <- apply(df,2,nchar)[,c("AdvertiserName")]
v_AdvName <- df[order(-df$AdvNameLen),c("AdvNameLen")]
nameLen <- v_AdvName[1]

# Put table data together. Cell 1 to cell 78 (c1 to c78).
tData <- lapply(1:78,function(c){
		# Format first row
		if(c %in% list(1,2,3,4,5,6)){
			f <- "ivory4";
			ff <- "bold";
		}
				
		# Format data row
		if(c %in% list(8,14,20,26,32,38,44,50,56,62)){
			f <- "ivory1";
			ff <- get(paste("c",paste(c,"ff",sep=""),sep=""));	
		}

		if(!(c %in% list(8,14,20,26,32,38,44,50,56,62)) & c > 6 & c < 67){
			f <- "ivory1";
			ff <- "plain";
		}

		# Format Top 10 row
		if(c %in% list(67,68,69,70,71,72)){
			f <- "ivory3";
			ff <- "bold";
		}
		
		# Format Total row
		if(c %in% list(73,74,75,76,77,78)){
			f <- "ivory4";
			ff <- "bold";
		}
		
		# Create grob
		if(c %in% list(8,14,20,26,32,38,44,50,56,62,68,74)){
		grobTree(
			rectGrob(
				gp=gpar(fill=f,alpha=0.5)
			),
			textGrob(
				get(paste("c",c,sep="")),
				gp=gpar(fontface=ff),
				just="left",
				hjust="left"
			)
		)
		}
		else{
		grobTree(
			rectGrob(
				gp=gpar(fill=f,alpha=0.5)
			),
			textGrob(
				get(paste("c",c,sep="")),
				gp=gpar(fontface=ff)
			)
		)
		}
	}
);	

# Specify table layout
tLayout <- rbind(
	c(1,2,3,4,5,6),
	c(7,8,9,10,11,12),
	c(13,14,15,16,17,18),
	c(19,20,21,22,23,24),
	c(25,26,27,28,29,30),
	c(31,32,33,34,35,36),
	c(37,38,39,40,41,42),
	c(43,44,45,46,47,48),
	c(49,50,51,52,53,54),
	c(55,56,57,58,59,60),
	c(61,62,63,64,65,66),
	c(67,68,69,70,71,72),
	c(73,74,75,76,77,78)
);

# Display table
	#tt <- ttheme_default(colhead=list(fg_params = list(parse=TRUE)))
grid.arrange(grobs = tData, layout_matrix = tLayout,widths=c(.5,1.5,1,1,1,1));
