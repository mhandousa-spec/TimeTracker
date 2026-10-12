'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');

const { planEmployee } = require('../src/rules/planner');
const { parseDay } = require('../src/rules/attendance');
const { applyAutoCheckOut } = require('../src/rules/autoCheckOut');
const { attendanceWrite } = require('../src/rules/mutations');
const { lastOf, unwrap } = require('../src/history');
const { plainTimestamp } = require('../src/timestamp');
const { ms, ts, setupFor, attendanceDoc, session } = require('./helpers');

const EMAIL = 'sara@co.com';
const DAY = '2026-10-08';
const ID = `${EMAIL}_${DAY}`;
const settings = (auto) => ({ autoCheckOutAfterMinutes: auto, allowedPauseMinutes: 0, timeZone: '' });

function plan(nowIso, doc, { auto = 120, setup = setupFor() } = {}) {
  return planEmployee({ setup, todayKey: DAY, days: { [DAY]: parseDay(ID, doc) }, settings: settings(auto), nowMs: ms(nowIso) });
}
const openDay = (extra = {}) =>
  attendanceDoc({ email: EMAIL, dayKey: DAY, sessions: [session({ checkIn: '2026-10-08T06:10:00Z', ...extra })] });

test('auto check-out: due shift end + Auto_Check_Out_After_Minutes (default 120), dynamic', () => {
  assert.equal(plan('2026-10-08T15:59:00Z', openDay()).candidates.some((c) => c.event === 'automatic_check_out_applied'), false);
  const c = plan('2026-10-08T16:00:00Z', openDay()).candidates.find((x) => x.event === 'automatic_check_out_applied');
  assert.ok(c);
  assert.equal(c.vars.time, ms('2026-10-08T14:00:00Z'));
  assert.deepEqual(c.changes.autoCheckOut, { sessionIndex: 0, checkOutMs: ms('2026-10-08T14:00:00Z') });
  assert.equal(c.changes.alertsToAdd[0].type, 'auto_check_out');
  assert.equal(c.changes.alertsToAdd[0].minutesOver, 0);
  // company sets 60 minutes
  assert.ok(plan('2026-10-08T15:00:00Z', openDay(), { auto: 60 }).candidates.some((x) => x.event === 'automatic_check_out_applied'));
  // ≤ 0 switches it off
  assert.equal(plan('2026-10-09T00:00:00Z', openDay(), { auto: 0 }).candidates.some((x) => x.event === 'automatic_check_out_applied'), false);
});

test('auto check-out: overnight shift ends the next day', () => {
  const setup = setupFor({ start: 22 * 60, end: 6 * 60, days: [1, 2, 3, 4, 5, 6, 7], lateAfter: 0 });
  const doc = attendanceDoc({ email: EMAIL, dayKey: DAY, sessions: [session({ checkIn: '2026-10-08T19:05:00Z' })] });
  const p = planEmployee({ setup, todayKey: '2026-10-09', days: { [DAY]: parseDay(ID, doc), '2026-10-09': null }, settings: settings(120), nowMs: ms('2026-10-09T05:00:00Z') });
  const c = p.candidates.find((x) => x.event === 'automatic_check_out_applied');
  assert.equal(c.dayKey, DAY);
  assert.equal(c.changes.autoCheckOut.checkOutMs, ms('2026-10-09T03:00:00Z'));
});

test('applyAutoCheckOut: check-out = shift end, Is_Auto_Check_Out, running pause / break closed, other keys kept', () => {
  const raw = [
    session({ checkIn: '2026-10-08T06:00:00Z', checkOut: '2026-10-08T07:00:00Z' }),
    session({
      checkIn: '2026-10-08T08:00:00Z',
      pauses: [['2026-10-08T09:00:00Z', '2026-10-08T09:10:00Z'], ['2026-10-08T13:30:00Z', null]],
      breaks: [['2026-10-08T15:00:00Z', null]],
      extra: { Check_Out_Location_Matched: null, Custom_Key: 'kept' },
    }),
  ];
  const next = applyAutoCheckOut(raw, 1, ms('2026-10-08T14:00:00Z'), plainTimestamp);
  assert.equal(next[0], raw[0]);
  const s = next[1];
  assert.equal(s.Check_Out_Date_Time.toMillis(), ms('2026-10-08T14:00:00Z'));
  assert.equal(s.Is_Auto_Check_Out, true);
  assert.equal(s.Custom_Key, 'kept');
  assert.equal(s.Pauses[0].End.toMillis(), ms('2026-10-08T09:10:00Z'));
  assert.equal(s.Pauses[1].End.toMillis(), ms('2026-10-08T14:00:00Z'));
  // a break that began after the recorded check-out is closed at its own start (0 min)
  assert.equal(s.Breaks[0].End.toMillis(), ms('2026-10-08T15:00:00Z'));
  assert.equal(raw[1].Is_Auto_Check_Out, undefined); // input untouched
});

test('applyAutoCheckOut: target-schema session (Check_In_At) gets Check_Out_At', () => {
  const next = applyAutoCheckOut([{ Check_In_At: ts('2026-10-08T06:00:00Z'), Pauses: [] }], 0, ms('2026-10-08T14:00:00Z'), plainTimestamp);
  assert.equal(next[0].Check_Out_At.toMillis(), ms('2026-10-08T14:00:00Z'));
  assert.equal(next[0].Check_Out_Date_Time, undefined);
});

test('attendanceWrite: auto check-out appends ONE history row (app codec), recomputes totals, adds the alert', () => {
  const doc = openDay({ pauses: [['2026-10-08T09:00:00Z', '2026-10-08T09:30:00Z']] });
  const c = plan('2026-10-08T16:00:00Z', doc).candidates.find((x) => x.event === 'automatic_check_out_applied');
  const w = attendanceWrite({ id: ID, doc, setup: setupFor(), dayKey: DAY, changes: c.changes, settings: settings(120), nowMs: ms('2026-10-08T16:00:00Z'), actor: 'system', toTimestamp: plainTimestamp });
  assert.equal(w.merge, false);
  assert.equal(w.data.timestamps.length, 2);
  for (const [key, history] of Object.entries(w.data)) assert.equal(history.length, 2, key); // every field appended
  const sessions = unwrap(lastOf(w.data, 'Sessions'));
  assert.equal(sessions[0].Is_Auto_Check_Out, true);
  assert.equal(sessions[0].Check_Out_Date_Time.toMillis(), ms('2026-10-08T14:00:00Z'));
  assert.equal(lastOf(w.data, 'Total_Work_Minutes'), 7 * 60 + 50 - 30); // 09:10→17:00 local minus 30 min pause
  assert.equal(lastOf(w.data, 'Break_Minutes'), 30); // app today: Break_Minutes = Σ pauses
  const alerts = unwrap(lastOf(w.data, 'Alerts'));
  assert.deepEqual(alerts.map((a) => [a.Alert_Type, a.Minutes_Over]), [['auto_check_out', 0]]);
  assert.equal(lastOf(w.data, 'Modified_By'), 'system');
  assert.equal(lastOf(w.data, 'Created_By'), EMAIL); // creator carried
  assert.equal(lastOf(w.data, 'Attendance_Status'), 'present'); // unchanged, carried
  assert.deepEqual(w.data.Alerts[0], null); // front-padded: the field did not exist before
});

test('attendanceWrite: creates a missing day in the app row shape (missed check-in alert)', () => {
  const w = attendanceWrite({
    id: ID,
    doc: null,
    setup: setupFor(),
    dayKey: DAY,
    changes: { alertsToAdd: [{ type: 'missed_check_in', atMs: ms('2026-10-08T06:15:00Z'), minutesOver: 0 }] },
    settings: settings(120),
    nowMs: ms('2026-10-08T06:15:00Z'),
    actor: 'system',
    toTimestamp: plainTimestamp,
    allowCreate: true,
  });
  assert.equal(w.created, true);
  assert.equal(lastOf(w.data, 'Attendance_Id'), ID);
  assert.equal(lastOf(w.data, 'Employee_Email'), EMAIL);
  assert.equal(lastOf(w.data, 'Attendance_Date').toMillis(), ms('2026-10-07T21:00:00Z')); // Riyadh midnight
  assert.deepEqual(unwrap(lastOf(w.data, 'Sessions')), []);
  assert.equal(lastOf(w.data, 'Attendance_Status'), null);
  assert.equal(unwrap(lastOf(w.data, 'Alerts'))[0].Alert_Type, 'missed_check_in');
  assert.equal(lastOf(w.data, 'Created_By'), 'system');
  // without allowCreate a missing day is never created
  assert.equal(attendanceWrite({ id: ID, doc: null, setup: setupFor(), dayKey: DAY, changes: { alertsToAdd: [] }, settings: settings(120), nowMs: 0, actor: 'system', toTimestamp: plainTimestamp }), null);
});

test('attendanceWrite: same alert twice is not duplicated; mark absent only an empty undecided day', () => {
  const alert = { type: 'missed_check_in', atMs: ms('2026-10-08T06:15:00Z'), minutesOver: 0 };
  const first = attendanceWrite({ id: ID, doc: null, setup: setupFor(), dayKey: DAY, changes: { alertsToAdd: [alert] }, settings: settings(120), nowMs: ms('2026-10-08T06:15:00Z'), actor: 'system', toTimestamp: plainTimestamp, allowCreate: true });
  assert.equal(attendanceWrite({ id: ID, doc: first.data, setup: setupFor(), dayKey: DAY, changes: { alertsToAdd: [alert] }, settings: settings(120), nowMs: ms('2026-10-08T07:00:00Z'), actor: 'system', toTimestamp: plainTimestamp }), null);
  const absent = attendanceWrite({ id: ID, doc: first.data, setup: setupFor(), dayKey: DAY, changes: { markAbsent: true }, settings: settings(120), nowMs: ms('2026-10-08T14:00:00Z'), actor: 'system', toTimestamp: plainTimestamp });
  assert.equal(lastOf(absent.data, 'Attendance_Status'), 'absent');
  assert.equal(unwrap(lastOf(absent.data, 'Alerts')).length, 1); // carried
});

test('attendanceWrite: Alerts keep the HOUSE history shape — one {Values:[…]} entry per revision', () => {
  const alert = (type, iso) => ({ type, atMs: ms(iso), minutesOver: 0 });
  const first = attendanceWrite({ id: ID, doc: openDay(), setup: setupFor(), dayKey: DAY, changes: { alertsToAdd: [alert('missed_check_out', '2026-10-08T14:30:00Z')] }, nowMs: ms('2026-10-08T14:30:00Z'), actor: 'system', toTimestamp: plainTimestamp });
  const second = attendanceWrite({ id: ID, doc: first.data, setup: setupFor(), dayKey: DAY, changes: { alertsToAdd: [alert('auto_check_out', '2026-10-08T16:00:00Z')] }, nowMs: ms('2026-10-08T16:00:00Z'), actor: 'system', toTimestamp: plainTimestamp });
  const history = second.data.Alerts;
  assert.equal(history.length, 3); // created row (front-padded null) + 2 revisions
  assert.equal(history[0], null);
  for (const entry of history.slice(1)) {
    assert.ok(entry && !Array.isArray(entry) && Array.isArray(entry.Values)); // never an array inside an array
  }
  assert.deepEqual(history[1].Values.map((a) => a.Alert_Type), ['missed_check_out']);
  assert.deepEqual(history[2].Values.map((a) => a.Alert_Type), ['missed_check_out', 'auto_check_out']);
  assert.deepEqual(Object.keys(history[2].Values[1]).sort(), ['Alert_Type', 'At', 'Minutes_Over']);
  assert.equal(second.data.timestamps.length, 3);
});

test('attendanceWrite: a stored day WITHOUT timestamps is upgraded to the history shape (never a plain list)', () => {
  const doc = {
    Employee_Email: EMAIL,
    Sessions: [{ Check_In_At: ts('2026-10-08T06:00:00Z'), Check_Out_At: null, Pauses: [], Breaks: [] }],
    Paused_Minutes: 0,
    Break_Minutes: 0,
  };
  const w = attendanceWrite({
    id: ID,
    doc,
    setup: setupFor(),
    dayKey: DAY,
    changes: { autoCheckOut: { sessionIndex: 0, checkOutMs: ms('2026-10-08T14:00:00Z') }, alertsToAdd: [{ type: 'auto_check_out', atMs: ms('2026-10-08T16:00:00Z'), minutesOver: 0 }] },
    nowMs: ms('2026-10-08T16:00:00Z'),
    actor: 'system',
    toTimestamp: plainTimestamp,
  });
  assert.equal(w.merge, false);
  const sessions = unwrap(lastOf(w.data, 'Sessions'));
  assert.equal(sessions[0].Check_Out_At.toMillis(), ms('2026-10-08T14:00:00Z'));
  assert.ok(Array.isArray(lastOf(w.data, 'Sessions').Values));
  assert.equal(unwrap(lastOf(w.data, 'Alerts'))[0].Alert_Type, 'auto_check_out');
  assert.equal(lastOf(w.data, 'Total_Work_Minutes'), 480);
  assert.equal(lastOf(w.data, 'Paused_Minutes'), 0);
  assert.equal(lastOf(w.data, 'Modified_By'), 'system');
  // the old plain Sessions list reads as a one-row history (app codec rule) → row 2, front-padded stamp
  assert.deepEqual(w.data.timestamps.map((t) => t.toMillis()), [0, ms('2026-10-08T16:00:00Z')]);
});
