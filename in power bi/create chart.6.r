dataset$color <- "Negative"
dataset$color[dataset$DaysToImplementation >= 0] <- "Positive"
chartTitle <- paste("Days to Implementation for",format(sum(dataset$OpportunityCount,na.rm=TRUE),big.mark=",",scientific=FALSE));
chartTitle <- paste(chartTitle,"opportunities");
library(ggplot2)
ggplot(dataset,aes(x=OpportunityCreateMonth,y=DaysToImplementation,size=OpportunityCount,colour=color)) + 
geom_point(alpha=0.3) + 
xlab("Opportunity Created Month") + 
ylab("Days to Implementation") + 
labs(size="Opportunity Count", colour="Positive & Negative Age", title = chartTitle)  + 
scale_colour_discrete(limits=c("Negative","Positive")) + 
theme(axis.text.x = element_text(angle=60, hjust=1));
