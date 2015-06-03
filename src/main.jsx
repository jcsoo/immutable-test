/* Main Javascript File */

import { Test } from './abc';

window.addEventListener('load', function() {
  React.render(<h1>Hello There, {Test}</h1>, document.body);
});
