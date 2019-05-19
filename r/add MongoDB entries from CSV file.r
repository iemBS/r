'Use this link to see how lon lat can be retreived using an address.
'http://stackoverflow.com/questions/20937682/r-trying-to-find-latitude-longitude-data-for-cities-in-europe-and-getting-geocod
'https://gist.github.com/josecarlosgonz/641763

'tips on using rmongodb
'https://cran.r-project.org/web/packages/rmongodb/vignettes/rmongodb_introduction.html
'https://cran.r-project.org/web/packages/rmongodb/vignettes/rmongodb_cheat_sheet.pdf
'RMongoDB cannot handle sub documents so inserts into MongoDB cannot be done in this case. 

'lon & lat digits mapped to familiar distances
'http://gis.stackexchange.com/questions/8650/how-to-measure-the-accuracy-of-latitude-and-longitude

'notes on using iterators
'http://www.r-bloggers.com/iterators-in-r/

install.packages("rmongodb")
install.packages("jsonlite")
install.packages("RCurl")
install.packages("RJSONIO")
install.packages("iterators")

library(rmongodb)
library(jsonlite)
library(RCurl)
library(RJSONIO)
library(iterators)

dbName <- "[db name]"

mongo <- mongo.create(
	host = "[server ip/name]",
	db = dbName,
	username = "[user name]",
	password = "[password]"
);

setwd("[working path on my computer]");
csv <- read.csv(file="[csv file name].csv",header=TRUE,sep=",");

coll <- "widgetArchiveTest"
ns <- paste(dbName,coll,sep=".");
jsonTemplate <- "db.widgetArchiveTest.insert({
	'widgetGroupID':[widgetGroupID],
	'widgetID':[widgetID],
	'name':'[name]'
	});"
	
jsonTemplate <- gsub("\n","",jsonTemplate)

icsv <- iter(csv, by = "row");
while(TRUE){
	r = try(nextElem(icsv))
	if(class(r) == "try-error") break
	
	json <- jsonTemplate;
	json <- gsub("\\[widgetGroupID\\]",r$widgetGroupID,json);
	json <- gsub("\\[widgetID\\]",r$widgetID,json);
	json <- gsub("\\[name\\]",gsub("'","\'",r$name),json);
	
	if(length(unlist(strsplit(toString(r$name),'\'',fixed=TRUE))) > 1){
		print("Escape single quote in name value");
	}
	if(length(unlist(strsplit(toString(r$venue_name),'\'',fixed=TRUE))) > 1){
		print("Escape single quote in venue.name value");
	}
	print(json)
}

	'mongo.insert(
	'	mongo,
	'	ns,
	'	json
	');


	
