'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');

const h = require('../src/history');
const { PlainTimestamp } = require('../src/timestamp');
const { ts, ms } = require('./helpers');

const T0 = ms('2026-10-09T06:00:00Z');
const T1 = ms('2026-10-09T07:00:00Z');

test('history: create appends one row to every field + timestamps', () => {
  const doc = h.appendRow(null, { A: 1, B: 'x' }, T0);
  assert.deepEqual(doc.A, [1]);
  assert.deepEqual(doc.B, ['x']);
  assert.equal(doc.timestamps.length, 1);
  assert.ok(doc.timestamps[0] instanceof PlainTimestamp);
  assert.equal(doc.timestamps[0].toMillis(), T0);
});

test('history: append keeps index alignment and the last value is current', () => {
  const v1 = h.appendRow(null, { A: 1, B: 'x' }, T0);
  const v2 = h.appendRow(v1, { A: 2, B: 'y' }, T1);
  assert.deepEqual(v2.A, [1, 2]);
  assert.deepEqual(v2.B, ['x', 'y']);
  assert.equal(h.lastOf(v2, 'A'), 2);
  assert.deepEqual(v2.timestamps.map((t) => t.toMillis()), [T0, T1]);
});

test('history: a stored field the writer does not pass is CARRIED (app code-review rule)', () => {
  const v1 = h.appendRow(null, { A: 1, Alerts: { Values: [{ Alert_Type: 'late_arrival' }] } }, T0);
  const v2 = h.appendRow(v1, { A: 2 }, T1); // e.g. the app writes without knowing Alerts
  assert.deepEqual(v2.Alerts, [{ Values: [{ Alert_Type: 'late_arrival' }] }, { Values: [{ Alert_Type: 'late_arrival' }] }]);
  assert.deepEqual(v2.A, [1, 2]);
});

test('history: a field added later is front-padded with null; short timestamps with epoch 0', () => {
  const v1 = h.appendRow(null, { A: 1 }, T0);
  const v2 = h.appendRow(v1, { A: 2, New: 'n' }, T1);
  assert.deepEqual(v2.New, [null, 'n']);
  const odd = { A: [1, 2, 3], timestamps: [ts(T0)] };
  const v3 = h.appendRow(odd, { A: 4 }, T1);
  assert.deepEqual(v3.A, [1, 2, 3, 4]);
  assert.deepEqual(v3.timestamps.map((t) => t.toMillis()), [0, 0, T0, T1]);
});

test('history: legacy int-millisecond stamps are read and upgraded to Timestamps', () => {
  const legacy = { A: [1], timestamps: [T0] };
  const next = h.appendRow(legacy, { A: 2 }, T1);
  assert.ok(next.timestamps.every((t) => typeof t.toMillis === 'function'));
  assert.deepEqual(next.timestamps.map((t) => t.toMillis()), [T0, T1]);
  assert.equal(h.lastWriteMs(next), T1);
});

test('history: lastOf on a scalar / missing field', () => {
  assert.equal(h.lastOf({ A: 'scalar' }, 'A'), 'scalar');
  assert.equal(h.lastOf({}, 'A'), null);
  assert.deepEqual(h.historyOf({ A: null }, 'A'), []);
});

test('history: rowCount / rowAt read the document as it was at a row', () => {
  const v1 = h.appendRow(null, { A: 1 }, T0);
  const v2 = h.appendRow(v1, { A: 2, B: 'b' }, T1);
  assert.equal(h.rowCount(v2), 2);
  const row0 = h.rowAt(v2, 0);
  assert.deepEqual(row0.A, [1]);
  assert.deepEqual(row0.B, [null]);
});

test('history: wrap / unwrap of list-valued entries', () => {
  assert.deepEqual(h.wrap([1, 2]), { Values: [1, 2] });
  assert.deepEqual(h.unwrap({ Values: [1, 2] }), [1, 2]);
  assert.deepEqual(h.unwrap([3]), [3]);
  assert.deepEqual(h.unwrap('x'), []);
});

test('history: audit trio — creator + creation date carry, modifier is the actor', () => {
  const created = h.nextAudit(null, 'sara@co.com', T0);
  assert.equal(created.Created_By, 'sara@co.com');
  assert.equal(created.Creation_Date.toMillis(), T0);
  const stored = h.appendRow(null, created, T0);
  const next = h.nextAudit(stored, 'system', T1);
  assert.equal(next.Created_By, 'sara@co.com');
  assert.equal(next.Creation_Date.toMillis(), T0);
  assert.equal(next.Modified_By, 'system');
});
