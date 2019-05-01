chartTitle <- paste("(Sell Rate / Pitch Rate), Sold Rate, & Pitch Rate for",format(sum(dataset$OpportunityCount,na.rm=TRUE),big.mark=",",scientific=FALSE));
chartTitle <- paste(chartTitle,"opportunities");
dataset$OpportunityPitchedCount[is.na(dataset$OpportunityPitchedCount)] <- 0;
dataset$OpportunitySoldCount[is.na(dataset$OpportunitySoldCount)] <- 0;
library(ggplot2);
library(dplyr);
library(reshape2);
df1 <- dataset[,c("OpportunitySoldCount","OpportunityPitchedCount","OpportunityCount","OpportunityCreateMonth")];
g <- group_by(df1,OpportunityCreateMonth);
df2 <- (g %>% summarise_each(funs(sum)));
df2$SoldRate <- (df2$OpportunitySoldCount/df2$OpportunityCount) * 100;
df2$PitchRate <- (df2$OpportunityPitchedCount/df2$OpportunityCount) * 100;
df2$Index <- ifelse(df2$PitchRate== 0,0, (df2$SoldRate/df2$PitchRate) * 100);
df2$OpportunityCount <- NULL;
df2$OpportunitySoldCount <- NULL;
df2$OpportunityPitchedCount <- NULL;
df3 <- melt(df2, id = "OpportunityCreateMonth");
ymax <- max(df3$value,na.rm = TRUE);
ymin <- min(df3$value,na.rm = TRUE);
ggplot(df3,aes(x=OpportunityCreateMonth,y=value,group=variable, colour=variable,linetype="solid",alpha=ifelse(variable=="Index",1,0.6))) +     
geom_line(size=2.5) + 
geom_point() + 
xlab("Opportunity Created Month") + 
ylab("Rate (0 to 100)") + 
labs(title = chartTitle) + 
theme(axis.text.x = element_text(angle=60, hjust=1)) + 
labs(colour="Rate") +
scale_colour_discrete(labels=c("Sell Rate","Pitch Rate","(Sell Rate / Pitch Rate)")) +  
scale_linetype_discrete(guide=FALSE) + 
scale_alpha(guide = 'none') + 
annotate("segment", x="2015-10", xend="2015-10", y=ymin, yend=ymax) + 
annotate("segment", x="2016-01", xend="2016-01", y=ymin, yend=ymax) + 
annotate("text", x = "2015-10", y = ymax, label = "Q1 End") + 
annotate("text", x = "2016-01", y = ymax, label = "Q2 End");
