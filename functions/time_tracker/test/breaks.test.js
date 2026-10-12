'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');

const { planEmployee } = require('../src/rules/planner');
const { parseDay } = require('../src/rules/attendance');
const { finalOverrunUpdates, overrunMinutes } = require('../src/rules/alerts');
const { ms, setupFor, attendanceDoc, session } = require('./helpers');

const EMAIL = 'sara@co.com';
const DAY = '2026-10-08';
const breakSetup = setupFor({ rules: { isBreakAllowed: true, breakMinutes: 30 } });
const pauseSetup = setupFor({ rules: { isPauseAllowed: true, pauseMinutes: 15 } });

function plan(nowIso, doc, { setup = breakSetup } = {}) {
  return planEmployee({
    setup,
    todayKey: DAY,
    days: { [DAY]: parseDay(`${EMAIL}_${DAY}`, doc) },
    settings: { autoCheckOutAfterMinutes: 120 },
    nowMs: ms(nowIso),
  });
}
const onBreak = (start, end = null) =>
  attendanceDoc({ email: EMAIL, dayKey: DAY, sessions: [session({ checkIn: '2026-10-08T06:00:00Z', breaks: [[start, end]] })] });
const onPause = (start, end = null) =>
  attendanceDoc({ email: EMAIL, dayKey: DAY, sessions: [session({ checkIn: '2026-10-08T06:00:00Z', pauses: [[start, end]] })] });

test('break_completed: at the limit (break keeps running), {{time}} = start + limit', () => {
  const doc = onBreak('2026-10-08T10:00:00Z');
  assert.equal(plan('2026-10-08T10:29:00Z', doc).candidates.length, 0);
  const p = plan('2026-10-08T10:30:00Z', doc);
  assert.deepEqual(p.candidates.map((c) => c.event), ['break_completed']);
  assert.equal(p.candidates[0].vars.time, ms('2026-10-08T10:30:00Z'));
  assert.equal(p.candidates[0].occurrenceMs, ms('2026-10-08T10:00:00Z'));
});

test('break_duration_exceeded: limit + 5 min grace → employee + MANAGER (every time) + alert; never HR', () => {
  const p = plan('2026-10-08T10:37:00Z', onBreak('2026-10-08T10:00:00Z'));
  const byEvent = Object.fromEntries(p.candidates.map((c) => [c.event, c]));
  assert.deepEqual(Object.keys(byEvent).sort(), ['break_completed', 'break_duration_exceeded', 'break_policy_violation_manager']);
  assert.equal(byEvent.break_duration_exceeded.receiver, 'employee');
  assert.equal(byEvent.break_policy_violation_manager.receiver, 'manager');
  assert.deepEqual(byEvent.break_policy_violation_manager.vars, { employeeName: true, minutes: 30 });
  const alert = byEvent.break_duration_exceeded.changes.alertsToAdd[0];
  assert.equal(alert.type, 'break_exceeded');
  assert.equal(alert.atMs, ms('2026-10-08T10:35:00Z'));
  assert.equal(alert.minutesOver, 7);
  assert.equal(p.candidates.some((c) => c.receiver === 'hr'), false);
  // one marker per break: a second break has its own occurrence
  assert.notEqual(byEvent.break_duration_exceeded.markerId, byEvent.break_policy_violation_manager.markerId);
});

test('break events need Break allowed with a limit; Pause never raises break events (D2)', () => {
  assert.equal(plan('2026-10-08T11:00:00Z', onBreak('2026-10-08T10:00:00Z'), { setup: setupFor() }).candidates.length, 0);
  // an open PAUSE with a break-allowed employee and no pause limit → nothing
  assert.equal(plan('2026-10-08T11:00:00Z', onPause('2026-10-08T10:00:00Z')).candidates.length, 0);
});

test('pause_duration_exceeded: the employee\'s effective Allowed_Pause_Minutes + Is_Pause_Allowed', () => {
  const doc = onPause('2026-10-08T10:00:00Z');
  assert.equal(plan('2026-10-08T10:14:00Z', doc, { setup: pauseSetup }).candidates.length, 0);
  const p = plan('2026-10-08T10:20:00Z', doc, { setup: pauseSetup });
  assert.deepEqual(p.candidates.map((c) => c.event), ['pause_duration_exceeded']);
  assert.deepEqual(p.candidates[0].vars, { minutes: 15 });
  const alert = p.candidates[0].changes.alertsToAdd[0];
  assert.equal(alert.type, 'pause_exceeded');
  assert.equal(alert.atMs, ms('2026-10-08T10:15:00Z'));
  assert.equal(alert.minutesOver, 5);
  // employee not allowed to pause (decision 10), or no Allowed_Pause_Minutes (= no limit) → nothing
  assert.equal(plan('2026-10-08T10:20:00Z', doc, { setup: setupFor({ rules: { isPauseAllowed: false, pauseMinutes: 15 } }) }).candidates.length, 0);
  assert.equal(plan('2026-10-08T10:20:00Z', doc, { setup: setupFor({ rules: { isPauseAllowed: true, pauseMinutes: 0 } }) }).candidates.length, 0);
});

test('upkeep: final Minutes_Over once the break ends; missing alert for an overrun that ended between runs', () => {
  const ended = attendanceDoc({
    email: EMAIL,
    dayKey: DAY,
    sessions: [session({ checkIn: '2026-10-08T06:00:00Z', breaks: [['2026-10-08T10:00:00Z', '2026-10-08T10:50:00Z']] })],
    alerts: [{ Alert_Type: 'break_exceeded', At: { seconds: ms('2026-10-08T10:35:00Z') / 1000, nanoseconds: 0 }, Minutes_Over: 7 }],
  });
  const p = plan('2026-10-08T11:00:00Z', ended);
  assert.equal(p.candidates.length, 0);
  assert.deepEqual(p.upkeep[0].changes.alertUpdates, [{ index: 0, minutesOver: 20 }]);

  const unseen = onBreak('2026-10-08T12:00:00Z', '2026-10-08T12:40:00Z');
  const q = plan('2026-10-08T13:00:00Z', unseen);
  assert.equal(q.upkeep[0].changes.alertsToAdd[0].type, 'break_exceeded');
  assert.equal(q.upkeep[0].changes.alertsToAdd[0].minutesOver, 10);
  // within limit + grace → no record
  assert.equal(plan('2026-10-08T13:00:00Z', onBreak('2026-10-08T12:00:00Z', '2026-10-08T12:34:00Z')).upkeep.length, 0);
});

test('alerts: overrun math and final updates match by At inside the interval', () => {
  assert.equal(overrunMinutes(0, 45 * 60000, 30), 15);
  assert.equal(overrunMinutes(0, 20 * 60000, 30), 0);
  const day = parseDay(`${EMAIL}_${DAY}`, onPause('2026-10-08T10:00:00Z', '2026-10-08T10:40:00Z'));
  const alerts = [{ type: 'pause_exceeded', atMs: ms('2026-10-08T10:15:00Z'), minutesOver: 0, rawIndex: 2 }];
  assert.deepEqual(finalOverrunUpdates(day.sessions, alerts, { breakMinutes: 0, pauseMinutes: 15 }), [{ index: 2, minutesOver: 25 }]);
});
