'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');

const { planEmployee } = require('../src/rules/planner');
const { parseDay } = require('../src/rules/attendance');
const { ms, setupFor, attendanceDoc, session } = require('./helpers');

const SETTINGS = { autoCheckOutAfterMinutes: 120, allowedPauseMinutes: 0, timeZone: '' };
const EMAIL = 'sara@co.com';

/** Plan at [nowIso] with the stored days given as {dayKey: docOrNull}. */
function plan({ nowIso, todayKey, docs = {}, setup = setupFor(), settings = SETTINGS, options = {} }) {
  const days = {};
  for (const [key, doc] of Object.entries(docs)) days[key] = doc ? parseDay(`${EMAIL}_${key}`, doc) : null;
  return planEmployee({ setup, todayKey, days, settings, nowMs: ms(nowIso), options });
}
const events = (p) => p.candidates.map((c) => c.event).sort();

test('missed_check_in: due at start + Late After (Riyadh Thu 09:15), not before', () => {
  assert.deepEqual(events(plan({ nowIso: '2026-10-08T06:14:00Z', todayKey: '2026-10-08' })), []);
  const p = plan({ nowIso: '2026-10-08T06:15:00Z', todayKey: '2026-10-08' });
  assert.deepEqual(events(p), ['missed_check_in']);
  const c = p.candidates[0];
  assert.equal(c.markerId, `${EMAIL}_2026-10-08__missed_check_in__${ms('2026-10-08T06:15:00Z')}`);
  assert.equal(c.occurrenceMs, ms('2026-10-08T06:15:00Z'));
  assert.deepEqual(c.leaveCheck, { kind: 'whole_day' });
  assert.equal(c.createDayIfMissing, true);
  assert.equal(c.gate, 'check_in');
  assert.equal(c.changes.alertsToAdd[0].type, 'missed_check_in');
});

test('missed_check_in: window closes at the shift end', () => {
  assert.deepEqual(events(plan({ nowIso: '2026-10-08T14:00:00Z', todayKey: '2026-10-08' })), []);
});

test('missed_check_in: KSA Sun–Thu — none on Friday; Cairo location same UTC instant is still Thursday', () => {
  // 2026-12-10 21:30Z = Fri 00:30 Riyadh, Thu 23:30 Cairo. Overnight shift 22:00–06:00, grace 0.
  const night = { start: 22 * 60, end: 6 * 60, lateAfter: 0, days: [7, 1, 2, 3, 4] };
  const riyadh = plan({ nowIso: '2026-12-10T21:30:00Z', todayKey: '2026-12-11', setup: setupFor({ ...night, timeZone: 'Asia/Riyadh' }) });
  // Riyadh: today = Friday (off); yesterday = Thursday's 22:00 shift → due for THURSDAY.
  assert.deepEqual(riyadh.candidates.map((c) => `${c.event}@${c.dayKey}`), ['missed_check_in@2026-12-10']);
  const cairo = plan({ nowIso: '2026-12-10T21:30:00Z', todayKey: '2026-12-10', setup: setupFor({ ...night, timeZone: 'Africa/Cairo' }) });
  assert.deepEqual(cairo.candidates.map((c) => `${c.event}@${c.dayKey}`), ['missed_check_in@2026-12-10']);
  // Friday 10:00 Riyadh with a day shift: nothing at all.
  assert.deepEqual(events(plan({ nowIso: '2026-10-09T07:00:00Z', todayKey: '2026-10-09' })), []);
});

test('missed_check_in: Egypt Sat–Thu week fires on Saturday, KSA does not', () => {
  const sat = '2026-10-10';
  const egypt = setupFor({ timeZone: 'Africa/Cairo', days: [6, 7, 1, 2, 3, 4] });
  assert.deepEqual(events(plan({ nowIso: '2026-10-10T06:30:00Z', todayKey: sat, setup: egypt })), ['missed_check_in']);
  assert.deepEqual(events(plan({ nowIso: '2026-10-10T06:30:00Z', todayKey: sat })), []);
});

test('missed_check_in: skipped for an HR shift (unknown week, decision 9)', () => {
  const hr = setupFor({ known: false, days: [1, 2, 3, 4, 5, 6, 7], lateAfter: 0 });
  assert.deepEqual(events(plan({ nowIso: '2026-10-08T06:30:00Z', todayKey: '2026-10-08', setup: hr })), []);
});

test('missed_check_in: not when checked in, on a stored leave day, or before the assignment starts', () => {
  const checkedIn = attendanceDoc({ email: EMAIL, dayKey: '2026-10-08', sessions: [session({ checkIn: '2026-10-08T06:20:00Z', checkOut: '2026-10-08T06:40:00Z' })] });
  assert.deepEqual(events(plan({ nowIso: '2026-10-08T07:00:00Z', todayKey: '2026-10-08', docs: { '2026-10-08': checkedIn } })), []);
  const vacation = attendanceDoc({ email: EMAIL, dayKey: '2026-10-08', status: 'vacation' });
  assert.deepEqual(events(plan({ nowIso: '2026-10-08T07:00:00Z', todayKey: '2026-10-08', docs: { '2026-10-08': vacation } })), []);
  const notYet = setupFor({ startDateKey: '2026-10-11' });
  assert.deepEqual(events(plan({ nowIso: '2026-10-08T07:00:00Z', todayKey: '2026-10-08', setup: notYet })), []);
});

test('shift_start_reminder: 15 minutes before the start, until the start', () => {
  assert.deepEqual(events(plan({ nowIso: '2026-10-08T05:44:00Z', todayKey: '2026-10-08' })), []);
  const p = plan({ nowIso: '2026-10-08T05:45:00Z', todayKey: '2026-10-08' });
  assert.deepEqual(events(p), ['shift_start_reminder']);
  assert.equal(p.candidates[0].vars.time, ms('2026-10-08T06:00:00Z'));
  assert.deepEqual(events(plan({ nowIso: '2026-10-08T06:00:00Z', todayKey: '2026-10-08' })), []);
  // not on Friday
  assert.deepEqual(events(plan({ nowIso: '2026-10-09T05:50:00Z', todayKey: '2026-10-09' })), []);
});

test('shift_start_reminder: a 00:10 start is reminded at 23:55 of the PREVIOUS day (midnight)', () => {
  const setup = setupFor({ start: 10, end: 480, days: [1, 2, 3, 4, 5, 6, 7], lateAfter: 0 });
  // 2026-10-08 23:55 Riyadh = 20:55Z; today is the 8th, the shift belongs to the 9th.
  const p = plan({ nowIso: '2026-10-08T20:55:00Z', todayKey: '2026-10-08', setup });
  assert.deepEqual(p.candidates.map((c) => `${c.event}@${c.dayKey}`), ['shift_start_reminder@2026-10-09']);
});

test('shift_end_reminder → missed_check_out (+30) → auto check-out (+120), only while checked in', () => {
  const open = attendanceDoc({ email: EMAIL, dayKey: '2026-10-08', sessions: [session({ checkIn: '2026-10-08T06:00:00Z' })] });
  const docs = { '2026-10-08': open };
  assert.deepEqual(events(plan({ nowIso: '2026-10-08T13:59:00Z', todayKey: '2026-10-08', docs })), []);
  const atEnd = plan({ nowIso: '2026-10-08T14:00:00Z', todayKey: '2026-10-08', docs });
  assert.deepEqual(events(atEnd), ['shift_end_reminder']);
  assert.equal(atEnd.candidates[0].vars.time, ms('2026-10-08T14:00:00Z'));
  const missed = plan({ nowIso: '2026-10-08T14:30:00Z', todayKey: '2026-10-08', docs });
  assert.deepEqual(events(missed), ['missed_check_out']);
  assert.deepEqual(missed.candidates[0].vars, { minutes: 30 });
  assert.equal(missed.candidates[0].changes.alertsToAdd[0].type, 'missed_check_out');
  assert.deepEqual(events(plan({ nowIso: '2026-10-08T16:00:00Z', todayKey: '2026-10-08', docs })), ['automatic_check_out_applied']);
  const closed = attendanceDoc({ email: EMAIL, dayKey: '2026-10-08', sessions: [session({ checkIn: '2026-10-08T06:00:00Z', checkOut: '2026-10-08T14:05:00Z' })] });
  assert.deepEqual(events(plan({ nowIso: '2026-10-08T14:30:00Z', todayKey: '2026-10-08', docs: { '2026-10-08': closed } })), []);
});

test('overnight session in YESTERDAY\'s document gets the end reminders the next morning', () => {
  const setup = setupFor({ start: 22 * 60, end: 6 * 60, days: [1, 2, 3, 4, 5, 6, 7], lateAfter: 0 });
  const yesterday = attendanceDoc({ email: EMAIL, dayKey: '2026-10-08', sessions: [session({ checkIn: '2026-10-08T19:00:00Z' })] });
  const p = plan({ nowIso: '2026-10-09T03:00:00Z', todayKey: '2026-10-09', setup, docs: { '2026-10-08': yesterday, '2026-10-09': null } });
  assert.deepEqual(p.candidates.map((c) => `${c.event}@${c.dayKey}`), ['shift_end_reminder@2026-10-08']);
});

test('extra work started after the shift end gets no end reminders and no auto check-out', () => {
  const late = attendanceDoc({ email: EMAIL, dayKey: '2026-10-08', sessions: [session({ checkIn: '2026-10-08T15:00:00Z' })] });
  assert.deepEqual(events(plan({ nowIso: '2026-10-08T18:00:00Z', todayKey: '2026-10-08', docs: { '2026-10-08': late } })), []);
});

test('late_arrival_recorded (server fallback, flag on): minutes from the shift START, once per day', () => {
  const doc = attendanceDoc({ email: EMAIL, dayKey: '2026-10-08', sessions: [session({ checkIn: '2026-10-08T06:20:00Z' })] });
  const on = { lateArrivalOnServer: true };
  const p = plan({ nowIso: '2026-10-08T06:25:00Z', todayKey: '2026-10-08', docs: { '2026-10-08': doc }, options: on });
  const late = p.candidates.find((c) => c.event === 'late_arrival_recorded');
  assert.equal(late.vars.minutes, 20); // 09:20 − 09:00, not − 09:15
  assert.equal(late.changes.alertsToAdd[0].minutesOver, 20);
  assert.equal(late.leaveCheck.kind, 'late');
  // within the grace → not late
  const onTime = attendanceDoc({ email: EMAIL, dayKey: '2026-10-08', sessions: [session({ checkIn: '2026-10-08T06:15:00Z' })] });
  assert.equal(plan({ nowIso: '2026-10-08T06:25:00Z', todayKey: '2026-10-08', docs: { '2026-10-08': onTime }, options: on }).candidates.some((c) => c.event === 'late_arrival_recorded'), false);
  // the app already wrote the alert with the check-in → server stays silent
  const appDid = attendanceDoc({ email: EMAIL, dayKey: '2026-10-08', sessions: [session({ checkIn: '2026-10-08T06:20:00Z' })], alerts: [{ Alert_Type: 'late_arrival', At: null, Minutes_Over: 20 }] });
  assert.equal(plan({ nowIso: '2026-10-08T06:25:00Z', todayKey: '2026-10-08', docs: { '2026-10-08': appDid }, options: on }).candidates.some((c) => c.event === 'late_arrival_recorded'), false);
  // flag off (default, decision B3 = app action)
  assert.equal(plan({ nowIso: '2026-10-08T06:25:00Z', todayKey: '2026-10-08', docs: { '2026-10-08': doc }, options: { lateArrivalOnServer: false } }).candidates.length, 0);
});

test('upkeep: a server-created missed-check-in day becomes absent after the shift end', () => {
  const created = attendanceDoc({ email: EMAIL, dayKey: '2026-10-08', alerts: [{ Alert_Type: 'missed_check_in', At: null, Minutes_Over: 0 }] });
  const before = plan({ nowIso: '2026-10-08T13:00:00Z', todayKey: '2026-10-08', docs: { '2026-10-08': created } });
  assert.equal(before.upkeep.length, 0);
  const after = plan({ nowIso: '2026-10-08T14:00:00Z', todayKey: '2026-10-08', docs: { '2026-10-08': created } });
  assert.equal(after.upkeep.length, 1);
  assert.equal(after.upkeep[0].changes.markAbsent, true);
  // an app-created empty day (no missed_check_in alert) is never touched
  const appDay = attendanceDoc({ email: EMAIL, dayKey: '2026-10-08' });
  assert.equal(plan({ nowIso: '2026-10-08T15:00:00Z', todayKey: '2026-10-08', docs: { '2026-10-08': appDay } }).upkeep.length, 0);
});
