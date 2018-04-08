var exec 	= require('child_process').exec;
var fs 		= require('fs');


var dmesgLOG    	= "dmesg"


function dmesg(res,postData){

	exec(dmesgLOG,{timeout:100000, maxBuffer:20000*1024},
			function (error, stdout, stderr){
				res.writeHead(200, {"Content-Type": "text/plain"});
				res.write(stdout);
				res.end();
			})
	console.log("Called DMESG logs");

}



function notImplemented(res){

	console.log("requesthandler was called with WRONG method");
	res.writeHead(405, {"Content-Type": "text/plain"});
	res.write("Method not allowed.");
	res.end();

}




exports.dmesg 		= dmesg;

