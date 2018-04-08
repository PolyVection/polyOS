var http = require("http");
var url  = require("url");


function route(handle,pathname,res,postData){

	console.log("about to route request for "+pathname);
	
	if(typeof handle[pathname] === "function"){
		handle[pathname](res, postData);		
			
	}

	else{
		console.log("No request handler found for "+pathname);
		res.writeHead(404, {"Content-Type": "text/plain"});
		res.write("404 Not found");
		res.end();
	}
}

exports.route = route;
