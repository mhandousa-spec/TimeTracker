'use strict';
/**
 * src/index.js wiring, with firebase-admin / firebase-functions STUBBED at
 * the module loader (the packages are not installed and must not be).
 */
const test = require('node:test');
const assert = require('node:assert/strict');
const Module = require('node:module');
const path = require('node:path');

const { PlainTimestamp } = require('../src/timestamp');
const { FakeFirestore, FakeMessaging, requestDoc, employeeDoc, seedRole, ALL_SWITCHES } = require('./helpers');

function loadIndexWithStubs(db, messaging) {
  const captured = { globalOptions: null };
  const stubs = {
    'firebase-admin': {
      initializeApp() {},
      firestore: Object.assign(() => db, { Timestamp: { fromMillis: (ms) => PlainTimestamp.fromMillis(ms) } }),
      messaging: () => messaging,
    },
    'firebase-functions/v2': { setGlobalOptions: (o) => (captured.globalOptions = o) },
    'firebase-functions/v2/scheduler': { onSchedule: (opts, handler) => ({ kind: 'schedule', opts, handler }) },
    'firebase-functions/v2/firestore': { onDocumentWritten: (opts, handler) => ({ kind: 'firestore', opts, handler }) },
    'firebase-functions/logger': { info() {}, warn() {}, error() {}, debug() {} },
  };
  const originalLoad = Module._load;
  Module._load = function load(request, parent, isMain) {
    if (Object.prototype.hasOwnProperty.call(stubs, request)) return stubs[request];
    return originalLoad.call(this, request, parent, isMain);
  };
  const file = path.join(__dirname, '..', 'src', 'index.js');
  try {
    delete require.cache[require.resolve(file)];
    return { exports: require(file), captured };
  } finally {
    Module._load = originalLoad;
    delete require.cache[require.resolve(file)];
  }
}

test('index: exports the 5-minute scheduler and the Requests trigger with the documented options', () => {
  const { exports: fns, captured } = loadIndexWithStubs(new FakeFirestore(), new FakeMessaging());
  assert.deepEqual(Object.keys(fns).sort(), ['ttPendingApprovals', 'ttScheduler']);
  assert.equal(fns.ttScheduler.kind, 'schedule');
  assert.equal(fns.ttScheduler.opts.schedule, 'every 5 minutes');
  assert.equal(fns.ttPendingApprovals.kind, 'firestore');
  assert.equal(fns.ttPendingApprovals.opts.document, 'Demo/{companyId}/Modules/time_tracker/Requests/{requestId}');
  assert.ok(captured.globalOptions.region);
});

test('index: the trigger handler reads before/after + params and sends through the runner', async () => {
  const db = new FakeFirestore();
  db.put('Demo/c9/Modules/time_tracker', {});
  db.put('Demo/c9/Employees_Info/3', employeeDoc({ id: '3', email: 'hala@co.com', first: 'Hala', last: 'H', role: 'HR' }));
  seedRole(db, 'c9', { id: 'hr', name: 'HR', switches: { ...ALL_SWITCHES, Approvals_All_Departments: true } });
  const after = requestDoc({ requester: 'sara@co.com', steps: [{ step: 'hr' }], writeAt: '2026-10-08T07:00:00Z' });
  db.put('Demo/c9/Modules/time_tracker/Requests/q1', after);
  const messaging = new FakeMessaging();
  const { exports: fns } = loadIndexWithStubs(db, messaging);
  await fns.ttPendingApprovals.handler({
    params: { companyId: 'c9', requestId: 'q1' },
    time: '2026-10-08T07:00:00.000Z',
    data: { before: { exists: false }, after: { exists: true, data: () => after } },
  });
  const sent = db.list('Demo/c9/Notifications').map((d) => d.data);
  assert.equal(sent.length, 1);
  assert.equal(sent[0].Reciver_Email, 'hala@co.com');
  assert.equal(sent[0].Request_Id, 'q1');
  assert.equal(messaging.sent.length, 1);
});
