var express = require('express');
var fs = require('fs');
var path = require('path');
var cookieParser = require('cookie-parser');
var csrf = require('csurf');

var app = express();
app.use(cookieParser());
app.use(csrf({ cookie: true }));

var framesDir = path.resolve(__dirname, 'frames');

app.post('/frames/:name', function(req,res) {
	var filename = path.resolve(framesDir, req.params.name);
	if (filename.indexOf(framesDir + path.sep) !== 0) {
		return res.status(400).send('invalid name');
	}

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
