dbName <- "[db name]"

conn <- mongo.create(
	host = "[mongoDB instance]",
	db = dbName,
	username = "[user name]",
	password = "[pwd]"
);

json <- '{"frequency.period":"yearly"}'
coll <- "widget"
ns <- paste(dbName,coll,sep=".");

if(conn.is.connected(conn) == TRUE){
	max <- conn.count(
			conn,
			ns,
			query=json
		)
