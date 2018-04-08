var exec 	= require('child_process').exec;
var fs 		= require('fs');


var volupCMD 	="amixer set 'Digital',0 '2%+' | egrep -o '[0-9]+%'";
var voldownCMD 	="amixer set 'Digital',0 '2%-'| egrep -o '[0-9]+%'";

var playCMD 	="mpc play 1";
var pauseCMD 	="mpc stop";

var linestart	="systemctl start polyos-linein"
var linestop	="systemctl stop polyos-linein"

var tosstart	="systemctl start polyos-tosin"
var tosstop	="systemctl stop polyos-tosin"


function volSet(res,postData){

}




function volUp(res,postData){

	exec(volupCMD,{timeout:100000, maxBuffer:20000*1024},
			function (error, stdout, stderr){
				res.writeHead(200, {"Content-Type": "text/plain"});
				res.write(stdout);
				res.end();
			})
	console.log("Called VOLUP");

}





function volDown(res,postData){

exec(voldownCMD,{timeout:100000, maxBuffer:20000*1024},
			function (error, stdout, stderr){
				res.writeHead(200, {"Content-Type": "text/plain"});
				res.write(stdout);
				res.end();
			})
	console.log("Called VOLDOWN");


}





function play(res,postData){

exec(playCMD,{timeout:100000, maxBuffer:20000*1024},
			function (error, stdout, stderr){
				res.writeHead(200, {"Content-Type": "text/plain"});
				res.write(stdout);
				res.end();
			})
	console.log("Called PLAY");

}






function pause(res,postData){

exec(pauseCMD,{timeout:100000, maxBuffer:20000*1024},
			function (error, stdout, stderr){
				res.writeHead(200, {"Content-Type": "text/plain"});
				res.write(stdout);
				res.end();
			})
	console.log("Called PLAY");

}

function lineinstart(res,postData){

exec(linestart,{timeout:100000, maxBuffer:20000*1024},
			function (error, stdout, stderr){
				res.writeHead(200, {"Content-Type": "text/plain"});
				res.write("LINE-IN activated!");
				res.end();
			})
	console.log("Called LINE-IN START");

}

function lineinstop(res,postData){

exec(linestop,{timeout:100000, maxBuffer:20000*1024},
			function (error, stdout, stderr){
				res.writeHead(200, {"Content-Type": "text/plain"});
				res.write("LINE-IN deactivated!");
				res.end();
			})
	console.log("Called LINE-IN STOP");

}

function tosinstart(res,postData){

exec(tosstart,{timeout:100000, maxBuffer:20000*1024},
			function (error, stdout, stderr){
				res.writeHead(200, {"Content-Type": "text/plain"});
				res.write("TOSLINK-IN activated!");
				res.end();
			})
	console.log("Called TOSLINK-IN START");

}

function tosinstop(res,postData){

exec(tosstop,{timeout:100000, maxBuffer:20000*1024},
			function (error, stdout, stderr){
				res.writeHead(200, {"Content-Type": "text/plain"});
				res.write("TOSLINK-IN deactivated!");
				res.end();
			})
	console.log("Called TOSLINK-IN STOP");

}





function notImplemented(res){

	console.log("requesthandler was called with WRONG method");
	res.writeHead(405, {"Content-Type": "text/plain"});
	res.write("Method not allowed.");
	res.end();

}



exports.volUp 	= volUp;
exports.volDown	= volDown;
exports.volSet	= volSet;
exports.play	= play;
exports.pause	= pause;
exports.lineinstart = lineinstart
exports.lineinstop = lineinstop
exports.tosinstart = tosinstart
exports.tosinstop = tosinstop
