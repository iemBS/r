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

mongo.is.connected(mongo)
