'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');

const t = require('../src/rules/time');
const { ms } = require('./helpers');

test('time: Riyadh wall time → UTC (UTC+3, no DST)', () => {
  assert.equal(t.atMinutes('2026-10-08', 9 * 60, 'Asia/Riyadh'), ms('2026-10-08T06:00:00Z'));
  assert.equal(t.dayStartMs('2026-10-08', 'Asia/Riyadh'), ms('2026-10-07T21:00:00Z'));
});

test('time: Cairo summer (UTC+3) vs winter (UTC+2)', () => {
  assert.equal(t.atMinutes('2026-10-08', 9 * 60, 'Africa/Cairo'), ms('2026-10-08T06:00:00Z'));
  assert.equal(t.atMinutes('2026-12-08', 9 * 60, 'Africa/Cairo'), ms('2026-12-08T07:00:00Z'));
});

test('time: Cairo spring-forward at MIDNIGHT — local 00:00 does not exist, day starts 01:00', () => {
  // 2026-04-24 (last Friday of April): 00:00 EET → 01:00 EEST.
  const start = t.dayStartMs('2026-04-24', 'Africa/Cairo');
  assert.equal(start, ms('2026-04-23T22:00:00Z'));
  assert.equal(t.dayKeyOf(start, 'Africa/Cairo'), '2026-04-24');
  assert.equal(t.zonedParts(start, 'Africa/Cairo').hour, 1);
  assert.equal(t.dayKeyOf(start - 1, 'Africa/Cairo'), '2026-04-23');
  // a 09:00 shift that day is 06:00Z (UTC+3 already)
  assert.equal(t.atMinutes('2026-04-24', 540, 'Africa/Cairo'), ms('2026-04-24T06:00:00Z'));
});

test('time: Cairo fall-back day keeps 09:00 at UTC+2 after the change', () => {
  // 2026-10-29 24:00 EEST → 23:00 EET; 2026-10-30 09:00 is UTC+2.
  assert.equal(t.atMinutes('2026-10-30', 540, 'Africa/Cairo'), ms('2026-10-30T07:00:00Z'));
  assert.equal(t.atMinutes('2026-10-29', 540, 'Africa/Cairo'), ms('2026-10-29T06:00:00Z'));
});

test('time: day key at the midnight boundary depends on the zone', () => {
  const instant = ms('2026-10-08T21:30:00Z'); // 00:30 Fri in Riyadh, 00:30 Fri in Cairo (summer)
  assert.equal(t.dayKeyOf(instant, 'Asia/Riyadh'), '2026-10-09');
  assert.equal(t.dayKeyOf(instant, 'Africa/Cairo'), '2026-10-09');
  const winter = ms('2026-12-10T22:30:00Z'); // Riyadh 01:30 Fri 11 Dec · Cairo 00:30 Fri 11 Dec
  assert.equal(t.dayKeyOf(winter, 'Asia/Riyadh'), '2026-12-11');
  const lateThu = ms('2026-12-10T21:30:00Z'); // Riyadh 00:30 FRIDAY · Cairo 23:30 THURSDAY
  assert.equal(t.dayKeyOf(lateThu, 'Asia/Riyadh'), '2026-12-11');
  assert.equal(t.dayKeyOf(lateThu, 'Africa/Cairo'), '2026-12-10');
  assert.equal(t.weekdayOfKey('2026-12-11'), 5); // Friday
  assert.equal(t.weekdayOfKey('2026-12-10'), 4); // Thursday
});

test('time: weekday numbering is Dart (Mon=1 … Sun=7)', () => {
  assert.equal(t.weekdayOfKey('2026-10-04'), 7); // Sunday
  assert.equal(t.weekdayOfKey('2026-10-05'), 1); // Monday
  assert.equal(t.weekdayOfKey('2026-10-10'), 6); // Saturday
});

test('time: calendar arithmetic over month / year ends', () => {
  assert.equal(t.addDays('2026-12-31', 1), '2027-01-01');
  assert.equal(t.addDays('2026-03-01', -1), '2026-02-28');
  assert.equal(t.parseDayKey('2026-02-31'), null);
});

test('time: overnight minutes roll into the next day', () => {
  assert.equal(t.atMinutes('2026-10-08', 24 * 60 + 6 * 60, 'Asia/Riyadh'), ms('2026-10-09T03:00:00Z'));
});

test('time: {{time}} formatting EN / AR in the location zone', () => {
  const at = ms('2026-10-08T10:30:00Z');
  assert.equal(t.formatClock(at, 'Asia/Riyadh', 'en'), '1:30 PM');
  assert.equal(t.formatClock(at, 'Asia/Riyadh', 'ar'), '1:30 م');
  assert.equal(t.formatClock(ms('2026-10-08T06:05:00Z'), 'Asia/Riyadh', 'ar'), '9:05 ص');
  assert.equal(t.formatClock(ms('2026-10-07T21:00:00Z'), 'Asia/Riyadh', 'en'), '12:00 AM');
  assert.equal(t.formatClock(ms('2026-12-08T10:00:00Z'), 'Africa/Cairo', 'en'), '12:00 PM');
});

test('time: zone fallback (location → company → default)', () => {
  assert.equal(t.pickTimeZone('', 'Africa/Cairo', 'Asia/Riyadh'), 'Africa/Cairo');
  assert.equal(t.pickTimeZone('Not/AZone', '', 'Asia/Riyadh'), 'Asia/Riyadh');
  assert.equal(t.pickTimeZone('Asia/Dubai', 'Africa/Cairo', 'Asia/Riyadh'), 'Asia/Dubai');
  assert.equal(t.isValidTimeZone(''), false);
});

test('time: minutesBetween truncates and never goes negative', () => {
  assert.equal(t.minutesBetween(0, 59_999), 0);
  assert.equal(t.minutesBetween(0, 120_000), 2);
  assert.equal(t.minutesBetween(120_000, 0), 0);
});
