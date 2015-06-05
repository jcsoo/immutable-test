/* Main Javascript File */

import Promise from 'blackbird'
import Immutable from 'immutable';
import XHR from 'xhr-promise';
import { Hello } from '../common/components/hello';
import { Model } from '../common/model';

window.addEventListener('load', function() {
  var m = Immutable.Map({a:1, b:2});

  var xhr = new XHR();
    xhr.send({url: '/'}).then(function(r) {
  });
  var t = new Model('Thing');  
  React.render(<Hello model={t}/>, document.body);
});
