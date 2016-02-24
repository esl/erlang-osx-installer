var http = require('http');
var fs = require('fs');

var count = 0;

function handle(req, res) {
    var index = fs.readFileSync(__dirname + '/releases.json');
    res.writeHead(200, {'Content-Type': 'text/plain', 'content-length' : index.length});
    res.end(index);
}

http.createServer(handle).listen(9090);
