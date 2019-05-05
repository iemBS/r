'no need to declare "conn" variable beforehand
conn <- mongo.create(
	host = "[mongoDB instance]",
	db = dbName,
	username = "[user name]",
	password = "[pwd]"
);
