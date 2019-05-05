'Use this link to see how lon lat can be retreived using an address.
'http://stackoverflow.com/questions/20937682/r-trying-to-find-latitude-longitude-data-for-cities-in-europe-and-getting-geocod
'https://gist.github.com/josecarlosgonz/6417633

'tips on using rmongodb
'https://cran.r-project.org/web/packages/rmongodb/vignettes/rmongodb_introduction.html
'https://cran.r-project.org/web/packages/rmongodb/vignettes/rmongodb_cheat_sheet.pdf

'lon & lat digits mapped to familiar distances
'http://gis.stackexchange.com/questions/8650/how-to-measure-the-accuracy-of-latitude-and-longitude

'install.packages("rmongodb")
'install.packages("jsonlite")
'install.packages("RCurl")
'install.packages("RJSONIO")

library(rmongodb)
library(jsonlite)
library(RCurl)
library(RJSONIO)

dbName <- "dance_by_me"

mongo <- mongo.create(
	host = "ds031701.mongolab.com:31701",
	db = dbName,
	username = "superlumins",
	password = "Love75Love75"
);

json <- '{"frequency.period":"yearly"}'
coll <- "eventArchiveTest"
ns <- paste(dbName,coll,sep=".");

if(mongo.is.connected(mongo) == TRUE){
	max <- mongo.count(
			mongo,
			ns,
			query=json
		)
	c <- mongo.find.all(
			mongo,
			ns,
			query=json,
			sort='{"venue.country":1,"venue.state":1,"venue.city":1,"venue.address":1}',
			fields='{"venue.address":1,"venue.city":1,"venue.state":1,"venue.country":1,"venue.lonLat.coordinates":1,"_id":0}'
		)
}

url <- function(address, return.call = "json", sensor = "false") {
  root <- "http://maps.google.com/maps/api/geocode/"
  u <- paste(root, return.call, "?address=", address, "&sensor=", sensor, sep = "")
  return(URLencode(u))
}

geoCode <- function(address,verbose=FALSE) {
  if(verbose) cat(address,"\n")
  u <- url(address)
  doc <- getURL(u)
  x <- fromJSON(doc,simplify = FALSE)
  if(x$status=="OK") {
    lat <- x$results[[1]]$geometry$location$lat
    lng <- x$results[[1]]$geometry$location$lng
    location_type  <- x$results[[1]]$geometry$location_type
    formatted_address  <- x$results[[1]]$formatted_address
    return(c(lat, lng, location_type, formatted_address))
    Sys.sleep(0.5)
  } else {
    return(c(NA,NA,NA, NA))
  }
}

i <- 1
addr <- ""
addrPrev <- ""
while(i <= max){
	cntry <- c[[i]]$venue$country;
	state <- c[[i]]$venue$state;
	city  <- c[[i]]$venue$city;
	addr <- c[[i]]$venue$address;
	ll <- c[[i]]$venue$lonLat$coordinates;
	fullAddr <- paste(addr,city,state,cntry,sep=",");
	if(addr == "[Personal address]")
	gc <- geoCode(fullAddr);
	haveLon <- round(as.numeric(ll[1]),4);
	haveLat <- round(as.numeric(ll[2]),4);
	if(is.na(gc[2])){
		calcLon <- "NA";
	}
	else{
		calcLon <- round(as.numeric(gc[2]),4);
	}
	
	if(is.na(gc[1])){
		calcLat <- "NA";
	}
	else{
		calcLat <- round(as.numeric(gc[1]),4);
	}
	
	decCnt <-function(x) {min(which( x*10^(0:20)==floor(x*10^(0:20)) )) - 1} 

	if((haveLon != calcLon || haveLat != calcLat) && decCnt(haveLon) >= 4 && decCnt(haveLat) >= 4){
		if(addr != addrPrev){
			print("");
			print("Different coordinates:")
			print(cntry);
			print(state);
			print(city);
			print(addr);
			print(paste("have",haveLon,haveLat,sep=":"));
			print(paste("calc",calcLon,calcLat,sep=":"));
		}
		addrPrev <- addr;
	}
	else if(decCnt(haveLon) < 4 || decCnt(haveLat) < 4){
		if(addr != addrPrev){
			print("");
			print("Less than 4 decimal places:")
			print(cntry);
			print(state);
			print(city);
			print(addr);
			print(paste("have",haveLon,haveLat,sep=":"));
			print(paste("calc",calcLon,calcLat,sep=":"));
		}
		addrPrev <- addr;
	}	

	i <- i + 1;
}



