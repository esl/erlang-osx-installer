var http = require('http');
var fs = require('fs');

var count = 0;

function handle(req, res) {
    var content = "";
    var contentType = "";
    switch(req.url) {
        case "/releases":
            content = fs.readFileSync(__dirname + '/releases.json');
            contentType = "text/plain";
            break;
        case "/updates":
            content = fs.readFileSync(__dirname + '/updates.xml');
            contentType = "text/xml";
            break;
    }
    
    res.writeHead(200, {'Content-Type': contentType, 'content-length' : content.length});
    res.end(content);
}

http.createServer(handle).listen(9090);