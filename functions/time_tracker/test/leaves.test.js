'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');

const { isCoveredByLeave, excusesLateArrival } = require('../src/rules/leaves');
const { parseRequest } = require('../src/rules/approvals');
const { parseSettings, hasHrModule, companyTimeZoneOf } = require('../src/rules/settings');
const { ms, requestDoc, setupFor, historyDoc } = require('./helpers');

const EMAIL = 'sara@co.com';
const setup = setupFor();
const leave = (opts) => parseRequest('L', requestDoc({ requester: EMAIL, status: 'approved', ...opts }));

test('leaves: an approved all-day leave covers its days (D3); under review still holds', () => {
  const r = leave({ start: '2026-10-07T00:00:00+03:00', end: '2026-10-08T23:59:00+03:00' });
  assert.equal(isCoveredByLeave([r], EMAIL, '2026-10-08', setup), true);
  assert.equal(isCoveredByLeave([r], EMAIL, '2026-10-09', setup), false);
  const review = leave({ status: 'under_review', start: '2026-10-08T00:00:00+03:00', end: '2026-10-08T23:59:00+03:00' });
  assert.equal(isCoveredByLeave([review], EMAIL, '2026-10-08', setup), true);
});

test('leaves: pending, rejected, other people and transactions never excuse', () => {
  const day = { start: '2026-10-08T00:00:00+03:00', end: '2026-10-08T23:59:00+03:00' };
  assert.equal(isCoveredByLeave([leave({ ...day, status: 'pending' })], EMAIL, '2026-10-08', setup), false);
  assert.equal(isCoveredByLeave([leave({ ...day, status: 'rejected' })], EMAIL, '2026-10-08', setup), false);
  assert.equal(isCoveredByLeave([leave({ ...day, isTransaction: true })], EMAIL, '2026-10-08', setup), false);
  assert.equal(isCoveredByLeave([leave(day)], 'other@co.com', '2026-10-08', setup), false);
});

test('leaves: a partial request covers a day only when it spans the whole shift (finding 8)', () => {
  const whole = leave({ allDay: false, start: '2026-10-08T08:30:00+03:00', end: '2026-10-08T17:30:00+03:00' });
  assert.equal(isCoveredByLeave([whole], EMAIL, '2026-10-08', setup), true);
  const hour = leave({ allDay: false, start: '2026-10-08T09:00:00+03:00', end: '2026-10-08T10:00:00+03:00' });
  assert.equal(isCoveredByLeave([hour], EMAIL, '2026-10-08', setup), false);
  // …but that 1-hour morning permission DOES excuse a late check-in (B3)
  assert.equal(excusesLateArrival([hour], EMAIL, '2026-10-08', setup, ms('2026-10-08T06:50:00Z')), true);
  const afternoon = leave({ allDay: false, start: '2026-10-08T14:00:00+03:00', end: '2026-10-08T15:00:00+03:00' });
  assert.equal(excusesLateArrival([afternoon], EMAIL, '2026-10-08', setup, ms('2026-10-08T06:50:00Z')), false);
});

test('leaves: days are read in the LOCATION zone', () => {
  // all-day leave written as Cairo 00:00–23:59 (Oct, UTC+3) seen by a Riyadh location → same day
  const r = leave({ start: '2026-10-08T00:00:00+03:00', end: '2026-10-08T23:59:00+03:00' });
  assert.equal(isCoveredByLeave([r], EMAIL, '2026-10-08', setupFor({ timeZone: 'Africa/Cairo' })), true);
  assert.equal(isCoveredByLeave([r], EMAIL, '2026-10-09', setupFor({ timeZone: 'Africa/Cairo' })), false);
});

test('settings: Settings/general holds ONLY Auto_Check_Out_After_Minutes (default 120); HR licence', () => {
  assert.deepEqual(parseSettings(null), { autoCheckOutAfterMinutes: 120 });
  // a stray pause limit or zone in Settings/general is ignored (approved schema)
  const s = parseSettings(historyDoc({ Auto_Check_Out_After_Minutes: 90, Allowed_Pause_Minutes: 30, Time_Zone: 'Africa/Cairo' }));
  assert.deepEqual(s, { autoCheckOutAfterMinutes: 90 });
  assert.equal(hasHrModule({ Demo_Details: { Modules: { HR: [false, true] } } }), true);
  assert.equal(hasHrModule({ Modules: { hr: { Values: [true, false] } } }), false);
  assert.equal(hasHrModule(null), false);
});

test('company record Time_Zone: nested per-field history, plain, legacy camelCase; invalid = none', () => {
  assert.equal(companyTimeZoneOf({ Time_Zone: { Time_Zone: ['Asia/Riyadh', 'Africa/Cairo'], Timestamp: [1, 2] } }), 'Africa/Cairo');
  assert.equal(companyTimeZoneOf({ Time_Zone: ['Asia/Dubai'] }), 'Asia/Dubai');
  assert.equal(companyTimeZoneOf({ Time_Zone: 'Asia/Riyadh' }), 'Asia/Riyadh');
  assert.equal(companyTimeZoneOf({ timeZone: { timeZone: ['Africa/Cairo'], timestamps: [1] } }), 'Africa/Cairo');
  assert.equal(companyTimeZoneOf({ Time_Zone: 'Mars/Base' }), '');
  assert.equal(companyTimeZoneOf(null), '');
});
