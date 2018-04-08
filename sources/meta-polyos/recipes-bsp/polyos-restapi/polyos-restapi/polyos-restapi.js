
var http    		= require('http');
var fs 			= require('fs');
var qs 			= require('querystring');
var exec 		= require('child_process').exec;
var url 		= require('url');

var server		= require("./polyserver");
var router		= require("./polyrouter");

var settingHandlers 	= require("./polysettings");
var sourceHandlers	= require("./polysource");
var commandHandlers	= require("./polycommand");
var logHandlers		= require("./polylog");

var handle = {}


/* JSON handlers */
handle["/settings/wifi/connect"] 	= settingHandlers.connectWifi;
handle["/settings/wifi/scan"] 		= settingHandlers.scanWifi;
handle["/settings/wifi/scan/lastresult"]= settingHandlers.showWifiLastResult;

handle["/command/listall"]            	= commandHandlers.listAll;
handle["/command/volup"]          	= commandHandlers.volUp;
handle["/command/voldown"]           	= commandHandlers.volDown;
handle["/command/volset"]            	= commandHandlers.volSet;
handle["/command/play"]              	= commandHandlers.play;
handle["/command/pause"]		= commandHandlers.pause;
handle["/command/linein-start"]		= commandHandlers.lineinstart;
handle["/command/linein-stop"]		= commandHandlers.lineinstop;
handle["/command/tosin-start"]		= commandHandlers.tosinstart;
handle["/command/tosin-stop"]		= commandHandlers.tosinstop;

handle["/source/listall"]		= sourceHandlers.listAll;
handle["/source/status"]		= sourceHandlers.status;
handle["/source/active"]		= sourceHandlers.active;

handle["/logs/dmesg"]			= logHandlers.dmesg;
handle["/logs/watchdog"]		= logHandlers.watchdog;
handle["/logs/server"]			= logHandlers.server;
handle["/logs/netradio"]		= logHandlers.netradio;



//DIR vars

var site 			= __dirname + '/public';
var statedir			= "/usr/sbin/polyos-restapi";


function logger(msg) {
	
	fs.writeFile(logdir, msg, function(err) {
    		if(err) console.log(err);
    		else console.log(msg);
    	}); 

}

server.start(router.route, handle);









