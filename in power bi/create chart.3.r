# chart
chartTitle <- paste("Avg Score for",format(sum(dataset$OpportunityCount,na.rm=TRUE),big.mark=",",scientific=FALSE));
chartTitle <- paste(chartTitle,"opportunities");
dataset$Score[is.na(dataset$Score)] <- 0;
dataset$OpportunitySoldCount[is.na(dataset$OpportunitySoldCount)] <- 0;
library(ggplot2);
library(gridExtra);
library(dplyr);
library(reshape2);
df1 <- dataset[,c("OpportunitySoldCount","Score","OpportunityCount","OpportunityCreateMonth")];
df1$ScoreOpportunityCount <- df1$Score * df1$OpportunityCount;
df1$Score <- NULL;
g <- group_by(df1,OpportunityCreateMonth);
df2 <- (g %>% summarise_each(funs(sum)));  
#df2$SoldRate <- (df2$OpportunitySoldCount/df2$OpportunityCount) * 100;
df2$Score <- (df2$ScoreOpportunityCount/df2$OpportunityCount) * 100;
#df2$Index <- ifelse(df2$ScoreOpportunityCount== 0,0, (df2$SoldRate/(df2$ScoreOpportunityCount/df2$OpportunityCount)) * 100);
df2$OpportunityCount <- NULL;
df2$OpportunitySoldCount <- NULL;
df2$ScoreOpportunityCount <- NULL;
df3 <- melt(df2, id = "OpportunityCreateMonth");
ymax <- max(df3$value,na.rm = TRUE);
ymin <- min(df3$value,na.rm = TRUE);
chart <- ggplot(df3,aes(x=OpportunityCreateMonth,y=value,group=variable, colour=variable,linetype="solid")) +     
geom_line(size=2.5) + 
geom_point() + 
xlab("Opportunity Created Month") + 
ylab("Rate (0 to 100)") + 
labs(title = chartTitle) + 
theme(axis.text.x = element_text(angle=60, hjust=1)) + 
labs(colour="Rate") +
scale_colour_discrete(labels=c("Avg Score")) +  
scale_linetype_discrete(guide=FALSE) + 
annotate("segment", x="2016-01", xend="2016-01", y=ymin, yend=ymax) + 
annotate("text", x = "2016-01", y = ymax, label = "Q2 End");

# chart A
chartTitleA <- paste("Sell Rate for",format(sum(dataset$OpportunityCount,na.rm=TRUE),big.mark=",",scientific=FALSE));
chartTitleA <- paste(chartTitleA,"opportunities");
dataset$Score[is.na(dataset$Score)] <- 0;
dataset$OpportunitySoldCount[is.na(dataset$OpportunitySoldCount)] <- 0;
dfa1 <- dataset[,c("OpportunitySoldCount","Score","OpportunityCount","OpportunityCreateMonth")];
dfa1$ScoreOpportunityCount <- dfa1$Score * dfa1$OpportunityCount;
dfa1$Score <- NULL;
gA <- group_by(dfa1,OpportunityCreateMonth);
dfa2 <- (gA %>% summarise_each(funs(sum)));  
dfa2$SoldRate <- (dfa2$OpportunitySoldCount/dfa2$OpportunityCount) * 100;
#dfa2$Score <- (dfa2$ScoreOpportunityCount/dfa2$OpportunityCount) * 100;
#dfa2$Index <- ifelse(dfa2$ScoreOpportunityCount== 0,0, (dfa2$SoldRate/(dfa2$ScoreOpportunityCount/dfa2$OpportunityCount)) * 100);
dfa2$OpportunityCount <- NULL;
dfa2$OpportunitySoldCount <- NULL;
dfa2$ScoreOpportunityCount <- NULL;
dfa3 <- melt(dfa2, id = "OpportunityCreateMonth");
ymaxA <- max(dfa3$value,na.rm = TRUE);
yminA <- min(dfa3$value,na.rm = TRUE);
chartA <- ggplot(dfa3,aes(x=OpportunityCreateMonth,y=value,group=variable, colour=variable,linetype="solid")) +     
geom_line(size=2.5) + 
geom_point() + 
xlab("Opportunity Created Month") + 
ylab("Rate (0 to 100)") + 
labs(title = chartTitleA) + 
theme(axis.text.x = element_text(angle=60, hjust=1)) + 
labs(colour="Rate") +
scale_colour_discrete(labels=c("Sell Rate")) +  
scale_linetype_discrete(guide=FALSE) + 
annotate("segment", x="2016-01", xend="2016-01", y=yminA, yend=ymaxA) + 
annotate("text", x = "2016-01", y = ymaxA, label = "Q2 End");
grid.arrange(chart,chartA, ncol = 2, nrow = 1);
