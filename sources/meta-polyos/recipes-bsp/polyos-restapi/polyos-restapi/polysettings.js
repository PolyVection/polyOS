var exec 		= require('child_process').exec;
var fs 			= require('fs');



function scanWifi(res,postData){

}





function showWifiLastResult(res,postData){
	
}









function connectWifi(res,postData){

}






function notImplemented(res){

	console.log("requesthandler was called with WRONG method");
	res.writeHead(405, {"Content-Type": "text/plain"});
	res.write("Method not allowed.");
	res.end();

}




exports.connectWifi 		= connectWifi;
exports.scanWifi 		= scanWifi;
exports.showWifiLastResult 	= showWifiLastResult;
