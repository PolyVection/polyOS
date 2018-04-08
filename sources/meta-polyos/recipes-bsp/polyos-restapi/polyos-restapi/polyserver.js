var http = require("http");
var url  = require("url");


function start(route,handle){

	function onRequest(req, res){
		
		var postData = "";
		var pathname = url.parse(req.url).pathname;
		console.log("Requesting: "+ pathname);
		
		req.setEncoding("utf8");
		req.addListener("data", function(postDataChunk){
				postData+=postDataChunk;
				console.log("Received POST data chunk: "+postDataChunk);
			});
		
		req.addListener("end", function(){
				route(handle,pathname,res,postData);
			});
	}

	http.createServer(onRequest).listen(8080);
	console.log("Server has started");

}



exports.start = start;



