'use strict';
/**
 * Lets `node --test functions/time_tracker/test` work: Node resolves the
 * directory to this file, which loads every `*.test.js` beside it.
 * (`node --test "functions/time_tracker/test/*.test.js"` works too.)
 */
const fs = require('node:fs');
const path = require('node:path');

for (const name of fs.readdirSync(__dirname).filter((n) => n.endsWith('.test.js')).sort()) {
  require(path.join(__dirname, name));
}
