var http = require('http');
var fs = require('fs');

var count = 0;

function handle(req, res) {
    var index = fs.readFileSync(__dirname + '/updates.xml');
    res.writeHead(200, {'Content-Type': 'text/xml', 'content-length' : index.length});
    res.end(index);
}

http.createServer(handle).listen(9091);