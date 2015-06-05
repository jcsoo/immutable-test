/* Main Javascript File */

import Promise from 'blackbird'
import Immutable from 'immutable';
import XHR from 'xhr-promise';
import { Test } from './abc';

window.addEventListener('load', function() {
  var m = Immutable.Map({a:1, b:2});

  var xhr = new XHR();
  xhr.send({url: '/'}).then(function(r) {    
  });

  React.render(<h1>Hello There, {m.get('a')} Hello</h1>, document.body);
});
