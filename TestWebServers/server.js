var http = require('http');
var fs = require('fs');

var count = 0;

function handle(req, res) {
    var content     = "text/plain";
    var contentType = "";
    var binary      = false;
    var statusCode  = 200;

    switch(req.url) {
        case "/releases":
            content = fs.readFileSync(__dirname + '/releases.json');
            break;
        case "/updates":
            content = fs.readFileSync(__dirname + '/updates.xml');
            contentType = "text/xml";
            break;
        default:
            try {
                content = fs.readFileSync(__dirname + req.url);
                contentType = "application/octet-stream";
                binary = true;
            } catch (e) {
                content = "Not Found";
                statusCode = 404;
            }
            break;
    }

    res.writeHead(statusCode, {'Content-Type': contentType, 'content-length' : content.length});
    if(binary) {
        res.end(content, 'binary');
    } else {
        res.end(content);
    }
    
}

http.createServer(handle).listen(9090);