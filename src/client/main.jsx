/* Main Javascript File */

import Promise from 'blackbird'
import Immutable from 'immutable';
import XHR from 'xhr-promise';
import { Test } from './abc';
import { Model } from '../common/model.js';

window.addEventListener('load', function() {
  var m = Immutable.Map({a:1, b:2});

  var xhr = new XHR();
    xhr.send({url: '/'}).then(function(r) {
  });
  var t = new Model('Thing');
  React.render(<div><h1>Hello There, {m.get('a')}</h1>{t.getName()}</div>, document.body);
});
