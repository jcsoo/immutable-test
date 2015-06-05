var React = require('react');
var express = require('express');
var app = express();

import {Model} from '../common/model';

app.get('/', function(req, res) {
  var m = new Model('Thing');
  var msg = <h1>Hello, World!</h1>;
  res.send(React.renderToString(msg));
});


var server = app.listen(5000, function () {
  var host = server.address().host || '';
  var port = server.address().port;
  console.log('Listening on %s:%s', host, port);
})
