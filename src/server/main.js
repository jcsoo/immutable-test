
var express = require('express');
var app = express();

import {Model} from '../common/model';

app.get('/', function(req, res) {
  var m = new Model('Thing');
  res.send('Hello, World! '+m.getName());
});


var server = app.listen(5000, function () {
  var host = server.address().host;
  var port = server.address().port;
  console.log('Listening on %s:%s', host, port);
})
