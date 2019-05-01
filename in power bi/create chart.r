library(ggplot2)
#Rename a column
names(dataset)[names(dataset)=="Quarter"] <- "TimeScenario";

# Order data
df <- dataset[order(dataset$MetricScenario,dataset$TimeScenario),];

df_plot <- df[!(df$TimeScenario == "QoQ") & !is.na(df$Revenue4Plot),c("Revenue4Plot","MetricScenario","TimeScenario")];
df_plot <- tail(df_plot[order(df_plot$TimeScenario),],3);
df_plot$order <- 1;
df_plot$order[df_plot$MetricScenario == "Sold In - Distributed Out"] <- 1;
df_plot$order[df_plot$MetricScenario == "Sold In - Distributed In"] <- 2;
df_plot$order[df_plot$MetricScenario == "Sold Out - Distributed In"] <- 3;
df_plot <- df_plot[order(df_plot$order),];
df_plot$textPos <- 1;
df_plot$textPos[df_plot$order == 1] <- df_plot$Revenue4Plot[df_plot$order == 1] / 2;
df_plot$textPos[df_plot$order == 2] <- df_plot$Revenue4Plot[df_plot$order == 1] + (df_plot$Revenue4Plot[df_plot$order == 2] / 2);
df_plot$textPos[df_plot$order == 3] <- df_plot$Revenue4Plot[df_plot$order == 1] + df_plot$Revenue4Plot[df_plot$order == 2] + (df_plot$Revenue4Plot[df_plot$order == 3] / 2); 
ggplot(aes(y=Revenue4Plot,x=TimeScenario, fill=factor(order)),data = df_plot) + 
geom_bar(stat = "identity") + 
xlab("") + 
ylab("") + 
coord_flip() + 
scale_fill_manual("Scenario",values = c("lightsteelblue2","lightsteelblue3","lightsteelblue4")) + 
geom_text(aes(label=paste(paste("$",as.character(Revenue4Plot),sep=""),"M",sep=""),y=textPos)) + 
theme(legend.position="none");
