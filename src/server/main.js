var React = require('react');
var express = require('express');
var app = express();

import {Model} from '../common/model';

app.get('/', function(req, res) {
  res.sendFile('index.html', {root: __dirname+'/html/'});
});

app.use(express.static(__dirname+'/../client/'));

var server = app.listen(5000, function () {
  var host = server.address().host || '';
  var port = server.address().port;
  console.log('Listening on %s:%s', host, port);
})
