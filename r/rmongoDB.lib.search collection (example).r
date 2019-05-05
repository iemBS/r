dbName <- "[db name]"

mongo <- mongo.create(
	host = "[mongoDB instance]",
	db = dbName,
	username = "[user name]",
	password = "[pwd]"
);

json <- '{"frequency.period":"yearly"}'
coll <- "widgeCollection"
ns <- paste(dbName,coll,sep=".");

c <- mongo.find.all(
			mongo,
			ns,
			query=json,
			sort='{"venue.country":1,"venue.state":1,"venue.city":1,"venue.address":1}',
			fields='{"venue.address":1,"venue.city":1,"venue.state":1,"venue.country":1,"venue.lonLat.coordinates":1,"_id":0}'
)
