var express = require('express');
var fs = require('fs');

var app = express();

app.post('/frames/:name', function(req,res) {
	var origin = req.headers.origin || req.headers.referer || "";
	if (!/^https?:\/\/localhost(:\d+)?\//.test(origin)) {
		res.status(403).send('forbidden');
		return;
	}

	var filename = 'frames/'+req.params.name;

	var dataURI = "";

	req.on('data', function(data) {
		dataURI += data;
	});

	req.on('end', function() {
		var regex = /^data:.+\/(.+);base64,(.*)$/;
		var matches = dataURI.match(regex);
		var data = matches[2];
		var buffer = new Buffer(data, 'base64');
		fs.writeFile(filename, buffer, function(err) {
			if (err) {
				res.status(400).send('failed');
				console.log("FAILED "+filename);
			}
			else {
				res.status(201).send('success');
				console.log("saved "+filename);
			}
		});
	});

});

app.listen(3000);
