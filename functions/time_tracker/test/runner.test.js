'use strict';
/**
 * End-to-end: runner + data layer + rules against an in-memory Firestore
 * (no firebase package, no network). Checks the written documents exactly
 * where the app reads them.
 */
const test = require('node:test');
const assert = require('node:assert/strict');

const baseConfig = require('../src/config');
const { createRunner } = require('../src/runner');
const { lastOf, unwrap } = require('../src/history');
const {
  ms,
  FakeFirestore,
  FakeMessaging,
  historyDoc,
  locationDoc,
  assignmentDoc,
  employeeDoc,
  attendanceDoc,
  session,
  requestDoc,
  seedRole,
  ALL_SWITCHES,
  silent,
} = require('./helpers');

const CID = 'c1';
const ROOT = `Demo/${CID}`;
const TT = `${ROOT}/Modules/time_tracker`;
const SARA = 'sara@co.com';
const MONA = 'mona@co.com';
const HALA = 'hala@co.com';

function seed({ hr = false, checkIn = true, settings = { Auto_Check_Out_After_Minutes: 120 }, locationTimeZone = 'Asia/Riyadh', assignment = {} } = {}) {
  const db = new FakeFirestore();
  db.put(TT, {});
  db.put(`Demo_Requests/${CID}`, { Demo_Details: { Modules: { hr } } });
  db.put(`${TT}/Settings/general`, historyDoc(settings));
  // break / pause DEFAULTS on the location (approved schema)
  db.put(`${TT}/Locations/loc1`, locationDoc({ breakAllowed: true, breakMinutes: 30, pauseAllowed: true, pauseMinutes: 15, timeZone: locationTimeZone }));
  db.put(`${TT}/Location_Assignments/${SARA}`, assignmentDoc({ email: SARA, ...assignment }));
  db.put(`${ROOT}/Employees_Info/1`, employeeDoc({ id: '1', email: SARA, first: 'Sara', last: 'Ali', firstAr: 'سارة', lastAr: 'علي', role: 'Employee', supervisor: MONA }));
  db.put(`${ROOT}/Employees_Info/2`, employeeDoc({ id: '2', email: MONA, first: 'Mona', last: 'Saleh', role: 'Employee' }));
  db.put(`${ROOT}/Employees_Info/3`, employeeDoc({ id: '3', email: HALA, first: 'Hala', last: 'Hassan', role: 'HR Officer' }));
  seedRole(db, CID, { id: 'r1', name: 'Employee', switches: { ...ALL_SWITCHES, Check_In_And_Out: checkIn } });
  seedRole(db, CID, { id: 'r2', name: 'HR Officer', switches: { ...ALL_SWITCHES, Approvals_All_Departments: true } });
  return db;
}

function runnerFor(db, nowIso, messaging = new FakeMessaging()) {
  const config = { ...baseConfig, COMPANY_IDS: [], DEFAULT_TIME_ZONE: 'Asia/Riyadh', LATE_ARRIVAL_ON_SERVER: false, FCM_PUSH: true };
  let now = ms(nowIso);
  const runner = createRunner({ db, messaging, logger: silent, config, clock: () => now });
  runner.setNow = (iso) => {
    now = ms(iso);
  };
  return { runner, messaging };
}

const notifications = (db) => db.list(`${ROOT}/Notifications`).map((d) => d.data);
const markers = (db, event) => db.list(`${TT}/Notification_Log`).filter((d) => !event || lastOf(d.data, 'Event_Key') === event);
const day = (db, key, email = SARA) => db.get(`${TT}/Attendance/${email}_${key}`);

test('runner: missed check-in → notification + marker + server-created day with the alert; second run silent', async () => {
  const db = seed();
  const { runner, messaging } = runnerFor(db, '2026-10-08T06:20:00Z'); // Thu 09:20 Riyadh
  const ids = await runner.runScheduler();
  assert.equal(ids.length, 1);
  const sent = notifications(db);
  assert.equal(sent.length, 1);
  assert.equal(sent[0].title, 'Check-In Not Recorded');
  assert.equal(sent[0].title_ar, 'لم يتم تسجيل الحضور');
  assert.equal(sent[0].Reciver_Email, SARA);
  assert.equal(sent[0].Sender_Email, 'system@company.com');
  assert.equal(sent[0].name_of_page, 'TimeTrackerMainPage');
  assert.equal(sent[0].Name_of_module, 'time_tracker');
  const m = markers(db, 'missed_check_in');
  assert.equal(m.length, 1);
  assert.equal(m[0].id, `${SARA}_2026-10-08__missed_check_in__${ms('2026-10-08T06:15:00Z')}`);
  assert.equal(lastOf(m[0].data, 'Outcome'), 'sent');
  const created = day(db, '2026-10-08');
  assert.equal(unwrap(lastOf(created, 'Alerts'))[0].Alert_Type, 'missed_check_in');
  assert.deepEqual(unwrap(lastOf(created, 'Sessions')), []);
  assert.equal(messaging.sent.length, 1);
  assert.equal(messaging.sent[0].topic, 'sara_at_co_dot_com');

  runner.setNow('2026-10-08T06:25:00Z');
  await runner.runScheduler();
  assert.equal(notifications(db).length, 1); // send once
  assert.equal(markers(db, 'missed_check_in').length, 1);

  // the shift ends with still no check-in → the server-created day is closed as absent
  runner.setNow('2026-10-08T14:05:00Z');
  await runner.runScheduler();
  assert.equal(lastOf(day(db, '2026-10-08'), 'Attendance_Status'), 'absent');
});

test('runner: a marker written by the old CLIENT sweep (same id) blocks the server send', async () => {
  const db = seed();
  db.put(`${TT}/Notification_Log/${SARA}_2026-10-08__missed_check_in__${ms('2026-10-08T06:15:00Z')}`, historyDoc({ Event_Key: 'missed_check_in' }));
  const { runner } = runnerFor(db, '2026-10-08T06:20:00Z');
  await runner.runCompany(CID);
  assert.equal(notifications(db).length, 0);
});

test('runner: no Check_In_And_Out → claimed as no_permission, no notification, no day created', async () => {
  const db = seed({ checkIn: false });
  const { runner } = runnerFor(db, '2026-10-08T06:20:00Z');
  const report = await runner.runCompany(CID);
  assert.equal(report.counts.no_permission, 1);
  assert.equal(notifications(db).length, 0);
  assert.equal(day(db, '2026-10-08'), undefined);
  assert.equal(lastOf(markers(db, 'missed_check_in')[0].data, 'Outcome'), 'no_permission');
});

test('runner: approved whole-day leave silences the missed check-in (D3)', async () => {
  const db = seed();
  db.put(`${TT}/Requests/L1`, requestDoc({ requester: SARA, status: 'approved', steps: [{ step: 'manager', approver: MONA, decision: 'approved' }], start: '2026-10-08T00:00:00+03:00', end: '2026-10-08T23:59:00+03:00' }));
  const { runner } = runnerFor(db, '2026-10-08T06:20:00Z');
  await runner.runCompany(CID);
  assert.equal(notifications(db).length, 0);
  assert.equal(lastOf(markers(db, 'missed_check_in')[0].data, 'Outcome'), 'on_leave');
});

test('runner: Notification Control OFF → no notification, but the alert record is still written', async () => {
  const db = seed();
  db.put(`${ROOT}/Modules/notification/notification_templates/time_tracker_missed_check_in`, { isEnabled: false, selectedNotificationTypes: ['push'] });
  const { runner, messaging } = runnerFor(db, '2026-10-08T06:20:00Z');
  await runner.runCompany(CID);
  assert.equal(notifications(db).length, 0);
  assert.equal(messaging.sent.length, 0);
  assert.equal(unwrap(lastOf(day(db, '2026-10-08'), 'Alerts'))[0].Alert_Type, 'missed_check_in');
});

test('runner: break overrun → employee + direct MANAGER (with name), HR never; alert on the day', async () => {
  const db = seed();
  db.put(`${TT}/Attendance/${SARA}_2026-10-08`, attendanceDoc({ email: SARA, dayKey: '2026-10-08', sessions: [session({ checkIn: '2026-10-08T06:00:00Z', breaks: [['2026-10-08T10:00:00Z', null]] })] }));
  const { runner } = runnerFor(db, '2026-10-08T10:40:00Z');
  await runner.runCompany(CID);
  const sent = notifications(db);
  const toSara = sent.filter((n) => n.Reciver_Email === SARA).map((n) => n.title).sort();
  assert.deepEqual(toSara, ['Authorised Break Duration Exceeded', 'Break Period Concluded']);
  const toMona = sent.filter((n) => n.Reciver_Email === MONA);
  assert.equal(toMona.length, 1);
  assert.equal(toMona[0].body, 'Sara Ali has exceeded the permitted break duration of 30 minutes and is still on break. The overrun has been recorded in their attendance alerts.');
  assert.ok(toMona[0].body_ar.startsWith('تجاوز سارة علي مدة الاستراحة'));
  assert.equal(sent.some((n) => n.Reciver_Email === HALA), false);
  const completed = sent.find((n) => n.title === 'Break Period Concluded');
  assert.ok(completed.body.includes('1:30 PM'));
  assert.ok(completed.body_ar.includes('1:30 م'));
  const alerts = unwrap(lastOf(day(db, '2026-10-08'), 'Alerts'));
  assert.deepEqual(alerts.map((a) => [a.Alert_Type, a.Minutes_Over]), [['break_exceeded', 10]]);

  // the break ends at 10:50 → the next run writes the final overrun (20) — no new notification
  const stored = day(db, '2026-10-08');
  const sessions = unwrap(lastOf(stored, 'Sessions'));
  sessions[0].Breaks[0].End = require('./helpers').ts('2026-10-08T10:50:00Z');
  const { appendRow, wrap } = require('../src/history');
  db.put(`${TT}/Attendance/${SARA}_2026-10-08`, appendRow(stored, { Sessions: wrap(sessions) }, ms('2026-10-08T10:50:00Z')));
  runner.setNow('2026-10-08T10:55:00Z');
  await runner.runCompany(CID);
  assert.equal(notifications(db).length, 3);
  assert.deepEqual(unwrap(lastOf(day(db, '2026-10-08'), 'Alerts')).map((a) => a.Minutes_Over), [20]);
});

test('runner: pause past the location\'s Allowed_Pause_Minutes → pause_duration_exceeded + pause_exceeded alert', async () => {
  const db = seed();
  db.put(`${TT}/Attendance/${SARA}_2026-10-08`, attendanceDoc({ email: SARA, dayKey: '2026-10-08', sessions: [session({ checkIn: '2026-10-08T06:00:00Z', pauses: [['2026-10-08T11:00:00Z', null]] })] }));
  const { runner } = runnerFor(db, '2026-10-08T11:20:00Z');
  await runner.runCompany(CID);
  const sent = notifications(db);
  assert.deepEqual(sent.map((n) => n.title), ['Pause Duration Exceeded']);
  assert.ok(sent[0].body.includes('permitted 15 minutes'));
  assert.equal(unwrap(lastOf(day(db, '2026-10-08'), 'Alerts'))[0].Alert_Type, 'pause_exceeded');
});

test('runner: auto check-out closes the session at the SHIFT END with the indicator; then silent', async () => {
  const db = seed();
  db.put(`${TT}/Attendance/${SARA}_2026-10-08`, attendanceDoc({ email: SARA, dayKey: '2026-10-08', sessions: [session({ checkIn: '2026-10-08T06:05:00Z' })] }));
  const { runner } = runnerFor(db, '2026-10-08T16:05:00Z');
  await runner.runCompany(CID);
  const stored = day(db, '2026-10-08');
  const s = unwrap(lastOf(stored, 'Sessions'))[0];
  assert.equal(s.Check_Out_Date_Time.toMillis(), ms('2026-10-08T14:00:00Z'));
  assert.equal(s.Is_Auto_Check_Out, true);
  assert.equal(lastOf(stored, 'Total_Work_Minutes'), 475);
  assert.equal(lastOf(stored, 'Modified_By'), 'system');
  const sent = notifications(db);
  assert.equal(sent.length, 1);
  assert.equal(sent[0].title, 'Automatic Check-Out Recorded');
  assert.ok(sent[0].body.includes('shift end time, 5:00 PM.'));
  assert.ok(sent[0].body_ar.includes('الساعة 5:00 م.'));
  assert.deepEqual(unwrap(lastOf(stored, 'Alerts')).map((a) => a.Alert_Type), ['auto_check_out']);
  runner.setNow('2026-10-08T16:10:00Z');
  await runner.runCompany(CID);
  assert.equal(notifications(db).length, 1);
});

test('runner: an event that stopped being due inside the transaction is dropped (stale)', async () => {
  const db = seed();
  const id = `${TT}/Attendance/${SARA}_2026-10-08`;
  db.put(id, attendanceDoc({ email: SARA, dayKey: '2026-10-08', sessions: [session({ checkIn: '2026-10-08T06:05:00Z' })] }));
  const { runner } = runnerFor(db, '2026-10-08T14:02:00Z'); // shift_end_reminder due
  const original = db.runTransaction.bind(db);
  let first = true;
  db.runTransaction = async (fn) => {
    if (first) {
      first = false; // the employee checks out between the scheduler's read and its transaction
      db.put(id, attendanceDoc({ email: SARA, dayKey: '2026-10-08', sessions: [session({ checkIn: '2026-10-08T06:05:00Z', checkOut: '2026-10-08T14:01:00Z' })] }));
    }
    return original(fn);
  };
  const report = await runner.runCompany(CID);
  assert.equal(report.counts.stale, 1);
  assert.equal(notifications(db).length, 0);
  assert.equal(markers(db, 'shift_end_reminder').length, 0);
});

test('runner: HR company — no missed check-in (unknown week), but auto check-out still applies', async () => {
  const db = seed({ hr: true });
  db.put(`${ROOT}/Modules/hr/Shifts/sh1`, { Id: 'sh1', Location_Ids: ['L1'], Start_Minutes: [540], End_Minutes: [1020] });
  db.put(`${ROOT}/Modules/hr/Shift_Assignments/1`, { Id: '1', Employee_Id: ['1'], Shift_Id: ['sh1'] });
  const { runner } = runnerFor(db, '2026-10-08T06:20:00Z');
  const report = await runner.runCompany(CID);
  assert.equal(report.employees, 1);
  assert.equal(notifications(db).length, 0);
  db.put(`${TT}/Attendance/${SARA}_2026-10-08`, attendanceDoc({ email: SARA, dayKey: '2026-10-08', sessions: [session({ checkIn: '2026-10-08T06:05:00Z' })] }));
  runner.setNow('2026-10-08T16:01:00Z');
  await runner.runCompany(CID);
  assert.deepEqual(notifications(db).map((n) => n.title), ['Automatic Check-Out Recorded']);
});

test('trigger: new request → its manager with the REAL count (count bug fixed); retry is silent', async () => {
  const db = seed();
  for (const [id, who] of [['a', 'x@co.com'], ['b', 'y@co.com'], ['c', 'z@co.com']]) {
    db.put(`${TT}/Requests/${id}`, requestDoc({ requester: who, steps: [{ step: 'manager', approver: MONA }, { step: 'hr' }] }));
  }
  const after = requestDoc({ requester: SARA, steps: [{ step: 'manager', approver: MONA }, { step: 'hr' }], writeAt: '2026-10-08T07:00:00Z' });
  db.put(`${TT}/Requests/new`, after);
  const { runner } = runnerFor(db, '2026-10-08T07:00:01Z');
  const report = await runner.onRequestWritten({ cid: CID, requestId: 'new', before: null, after, eventTimeMs: ms('2026-10-08T07:00:00Z') });
  assert.deepEqual(report.receivers, [MONA]);
  const sent = notifications(db);
  assert.equal(sent.length, 1);
  assert.equal(sent[0].Reciver_Email, MONA);
  // KP-TT-011 (9/10/2026): the count with its noun, both languages.
  assert.equal(sent[0].body, 'You have 4 requests awaiting your decision. Please review at your earliest convenience to avoid delays in the approval workflow.');
  assert.equal(sent[0].body_ar, 'لديك 4 طلبات بانتظار قرارك. يرجى المراجعة في أقرب وقت لتفادي التأخير في سير عمل الموافقة.');
  assert.equal(sent[0].Is_Reminder, false);
  assert.equal(sent[0].Request_Id, 'new');
  assert.equal(sent[0].name_of_page, 'TimeTrackerApprovalDetails');
  assert.equal(sent[0].Sender_Email, SARA); // the person who acted
  await runner.onRequestWritten({ cid: CID, requestId: 'new', before: null, after, eventTimeMs: ms('2026-10-08T07:00:00Z') });
  assert.equal(notifications(db).length, 1);
});

test('trigger: moved to the HR step → HR approvers only (not the manager who decided, not the requester)', async () => {
  const db = seed();
  const before = requestDoc({ requester: SARA, steps: [{ step: 'manager', approver: MONA }, { step: 'hr' }] });
  const after = requestDoc({
    requester: SARA,
    steps: [{ step: 'manager', approver: MONA, decision: 'approved', decidedAt: '2026-10-08T08:00:00Z' }, { step: 'hr' }],
    modifiedBy: MONA,
    writeAt: '2026-10-08T08:00:00Z',
  });
  db.put(`${TT}/Requests/r1`, after);
  const { runner } = runnerFor(db, '2026-10-08T08:00:01Z');
  await runner.onRequestWritten({ cid: CID, requestId: 'r1', before, after, eventTimeMs: ms('2026-10-08T08:00:00Z') });
  const sent = notifications(db);
  assert.deepEqual(sent.map((n) => n.Reciver_Email), [HALA]);
  // KP-TT-011: singular for one request (EN + AR).
  assert.ok(sent[0].body.startsWith('You have 1 request awaiting your decision.'));
  assert.ok(sent[0].body_ar.startsWith('لديك طلب واحد بانتظار قرارك.'));
  assert.equal(sent[0].Sender_Email, MONA);
});

test('trigger: "Send reminder" → Is_Reminder true + Reminder title; a comment write sends nothing', async () => {
  const db = seed();
  const before = requestDoc({ requester: SARA, steps: [{ step: 'manager', approver: MONA }] });
  const after = requestDoc({ requester: SARA, steps: [{ step: 'manager', approver: MONA }], lastReminder: '2026-10-08T09:00:00Z', writeAt: '2026-10-08T09:00:00Z' });
  db.put(`${TT}/Requests/r1`, after);
  const { runner } = runnerFor(db, '2026-10-08T09:00:01Z');
  await runner.onRequestWritten({ cid: CID, requestId: 'r1', before, after, eventTimeMs: ms('2026-10-08T09:00:00Z') });
  const sent = notifications(db);
  assert.equal(sent.length, 1);
  assert.equal(sent[0].Is_Reminder, true);
  assert.equal(sent[0].title, 'Reminder — Pending Approval Requests');
  assert.ok(sent[0].body.startsWith('Reminder: you still have 1 request awaiting your decision.'));
  assert.ok(sent[0].body_ar.startsWith('تذكير: لا يزال لديك طلب واحد بانتظار قرارك.'));
  const report = await runner.onRequestWritten({ cid: CID, requestId: 'r1', before: after, after, eventTimeMs: ms('2026-10-08T09:30:00Z') });
  assert.equal(report.counts.no_transition, 1);
  assert.equal(notifications(db).length, 1);
});

test('scheduler: daily pending-approvals reminder once a day for requests waiting > 2 days', async () => {
  const db = seed();
  db.put(`${TT}/Requests/old`, requestDoc({ requester: 'x@co.com', steps: [{ step: 'manager', approver: MONA }], createdAt: '2026-10-04T08:00:00Z' }));
  db.put(`${TT}/Requests/new`, requestDoc({ requester: 'y@co.com', steps: [{ step: 'manager', approver: MONA }], createdAt: '2026-10-08T08:00:00Z' }));
  const { runner } = runnerFor(db, '2026-10-09T05:59:00Z'); // 08:59 Riyadh — too early
  await runner.runCompany(CID);
  assert.equal(notifications(db).filter((n) => n.Reciver_Email === MONA).length, 0);
  runner.setNow('2026-10-09T06:05:00Z'); // 09:05 Riyadh
  await runner.runCompany(CID);
  const toMona = notifications(db).filter((n) => n.Reciver_Email === MONA);
  assert.equal(toMona.length, 1);
  assert.equal(toMona[0].Is_Reminder, true);
  assert.equal(toMona[0].Request_Id, 'old');
  assert.ok(toMona[0].body.includes('still have 2 requests awaiting')); // the REAL total, not only the overdue one
  assert.ok(toMona[0].body_ar.includes('طلبان بانتظار قرارك')); // KP-TT-011: Arabic dual
  runner.setNow('2026-10-09T09:00:00Z');
  await runner.runCompany(CID);
  assert.equal(notifications(db).filter((n) => n.Reciver_Email === MONA).length, 1);
});

test('runner: an employee Custom_Rules (Is_Custom) overrides the location — pause not allowed → no pause event', async () => {
  const db = seed({ assignment: { customRules: { Is_Custom: true, Is_Break_Allowed: true, Allowed_Break_Minutes: 30, Is_Pause_Allowed: false } } });
  db.put(`${TT}/Attendance/${SARA}_2026-10-08`, attendanceDoc({ email: SARA, dayKey: '2026-10-08', sessions: [session({ checkIn: '2026-10-08T06:00:00Z', pauses: [['2026-10-08T11:00:00Z', null]] })] }));
  const { runner } = runnerFor(db, '2026-10-08T11:20:00Z');
  await runner.runCompany(CID);
  assert.equal(notifications(db).length, 0);
});

test('runner: location without Time_Zone → the company record Demo/{cid}/Companys/{cid}.Time_Zone (Cairo winter)', async () => {
  const db = seed({ locationTimeZone: null });
  db.put(`${ROOT}/Companys/${CID}`, { Company_Name: { Company_Name: ['Bayanatz'] }, Time_Zone: { Time_Zone: ['Africa/Cairo'], Timestamp: [1] } });
  const { runner } = runnerFor(db, '2026-12-10T06:20:00Z'); // Thu 09:20 Riyadh but 08:20 Cairo
  await runner.runCompany(CID);
  assert.equal(notifications(db).length, 0);
  runner.setNow('2026-12-10T07:20:00Z'); // 09:20 Cairo (UTC+2)
  await runner.runCompany(CID);
  assert.equal(notifications(db).length, 1);
  assert.equal(markers(db, 'missed_check_in')[0].id, `${SARA}_2026-12-10__missed_check_in__${ms('2026-12-10T07:15:00Z')}`);
});

test('runner: company zone — Demo/{cid}/Companies/{cid} (approved rename) when Companys has none', async () => {
  const db = seed({ locationTimeZone: null });
  db.put(`${ROOT}/Companys/${CID}`, { Company_Name: { Company_Name: ['Bayanatz'] } }); // record without a zone
  db.put(`${ROOT}/Companies/${CID}`, { Time_Zone: { Time_Zone: ['Africa/Cairo'], Timestamp: [1] } });
  const { runner } = runnerFor(db, '2026-12-10T06:20:00Z');
  await runner.runCompany(CID);
  assert.equal(notifications(db).length, 0); // Cairo 08:20 — not due yet
});

test('runner: company zone — Companys wins over Companies', async () => {
  const db = seed({ locationTimeZone: null });
  db.put(`${ROOT}/Companys/${CID}`, { Time_Zone: ['Asia/Riyadh'] });
  db.put(`${ROOT}/Companies/${CID}`, { Time_Zone: ['Africa/Cairo'] });
  const { runner } = runnerFor(db, '2026-12-10T06:20:00Z');
  await runner.runCompany(CID);
  assert.equal(notifications(db).length, 1); // Riyadh 09:20 — due
});

test('runner: top-level Companys/{cid} and Companies/{cid} are NOT read (not company-scoped) → env default', async () => {
  const db = seed({ locationTimeZone: null });
  db.put(`Companys/${CID}`, { Time_Zone: 'Africa/Cairo' });
  db.put(`Companies/${CID}`, { Time_Zone: 'Africa/Cairo' });
  const { runner } = runnerFor(db, '2026-12-10T06:20:00Z'); // TT_DEFAULT_TIME_ZONE = Asia/Riyadh → 09:20, due
  await runner.runCompany(CID);
  assert.equal(notifications(db).length, 1);
});
