dbName <- "[db name]"

mongo <- mongo.create(
	host = "[mongoDB instance]",
	db = dbName,
	username = "[user name]",
	password = "[pwd]"
);

json <- '{"frequency.period":"yearly"}'
coll <- "widget"
ns <- paste(dbName,coll,sep=".");

if(mongo.is.connected(mongo) == TRUE){
	max <- mongo.count(
			mongo,
			ns,
			query=json
		)
