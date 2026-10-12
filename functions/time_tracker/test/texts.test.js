'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');

const t = require('../src/texts');
const { markerId, markerDoc, approverSubject, dailySubject } = require('../src/rules/dedupe');
const { notificationDoc, pushMessage, topicForEmail } = require('../src/notifications');
const { lastOf } = require('../src/history');
const { plainTimestamp } = require('../src/timestamp');
const { formatClock } = require('../src/rules/time');
const { ms } = require('./helpers');

const SERVER_EVENTS = [
  'break_completed',
  'break_duration_exceeded',
  'break_policy_violation_manager',
  'pause_duration_exceeded',
  'automatic_check_out_applied',
  'missed_check_in',
  'missed_check_out',
  'shift_start_reminder',
  'shift_end_reminder',
  'pending_approvals',
];

test('texts: every server event has EN + AR title and body, placeholders = declared variables', () => {
  for (const key of SERVER_EVENTS) {
    const tpl = t.TEMPLATES[key];
    assert.ok(tpl, key);
    for (const f of ['titleEn', 'titleAr', 'bodyEn', 'bodyAr']) assert.ok(tpl[f].trim().length > 0, `${key}.${f}`);
    const used = new Set([...`${tpl.bodyEn} ${tpl.bodyAr}`.matchAll(/\{\{(\w+)\}\}/g)].map((m) => m[1]));
    assert.deepEqual([...used].sort(), [...tpl.variables].sort(), key);
  }
});

test('texts: EN / AR rendering with variables (time in the location zone, both languages stored)', () => {
  const at = ms('2026-10-08T10:30:00Z');
  const tpl = t.resolveTemplate('break_completed');
  const r = t.renderBoth(tpl, { time: formatClock(at, 'Asia/Riyadh', 'en') }, { time: formatClock(at, 'Asia/Riyadh', 'ar') });
  assert.equal(r.title, 'Break Period Concluded');
  assert.equal(r.title_ar, 'انتهاء فترة الاستراحة');
  assert.equal(
    r.body,
    'Your permitted break period ended at 1:30 PM. Please end your break and resume work. Any time beyond the permitted duration will be recorded as a break overrun.',
  );
  assert.equal(
    r.body_ar,
    'انتهت فترة الاستراحة المسموح بها في 1:30 م. يرجى إنهاء الاستراحة واستئناف العمل. سيُسجَّل أي وقت يتجاوز المدة المسموح بها كتجاوز للاستراحة.',
  );
});

test('texts: manager violation names the employee in each language; pending count is count-safe', () => {
  const v = t.renderBoth(t.resolveTemplate('break_policy_violation_manager'), { employeeName: 'Sara Ali', minutes: '30' }, { employeeName: 'سارة علي' });
  assert.equal(v.body, 'Sara Ali has exceeded the permitted break duration of 30 minutes and is still on break. The overrun has been recorded in their attendance alerts.');
  assert.equal(v.body_ar, 'تجاوز سارة علي مدة الاستراحة المسموح بها وهي 30 دقيقة ولا يزال في استراحة. تم تسجيل التجاوز في تنبيهات الحضور الخاصة به.');
  // KP-TT-011 (9/10/2026): singular / plural in both languages.
  const one = t.pendingCountVariables(1);
  const p = t.renderBoth(t.resolveTemplate('pending_approvals'), one.en, one.ar);
  assert.equal(p.body, 'You have 1 request awaiting your decision. Please review at your earliest convenience to avoid delays in the approval workflow.');
  assert.equal(p.body_ar, 'لديك طلب واحد بانتظار قرارك. يرجى المراجعة في أقرب وقت لتفادي التأخير في سير عمل الموافقة.');
  const four = t.pendingCountVariables(4);
  const rem = t.renderBoth(t.resolveTemplate('pending_approvals', { isReminder: true }), four.en, four.ar);
  assert.equal(rem.title, 'Reminder — Pending Approval Requests');
  assert.equal(rem.title_ar, 'تذكير — طلبات بانتظار الموافقة');
  assert.ok(rem.body.startsWith('Reminder: you still have 4 requests awaiting your decision.'));
  assert.ok(rem.body_ar.startsWith('تذكير: لا يزال لديك 4 طلبات بانتظار قرارك.'));
  for (const r of [p, rem]) {
    assert.ok(!`${r.body} ${r.body_ar}`.includes('{{'), 'no placeholder left');
    assert.ok(!/\b1 requests\b/.test(r.body) && !r.body_ar.includes('1 طلبات'));
  }
});

test('texts: countedRequests — EN 1 request / N requests; AR number agreement (KP-TT-011)', () => {
  assert.equal(t.countedRequests(1, 'en'), '1 request');
  assert.equal(t.countedRequests(0, 'en'), '0 requests');
  assert.equal(t.countedRequests(2, 'en'), '2 requests');
  assert.equal(t.countedRequests(21, 'en'), '21 requests');
  const ar = (n) => t.countedRequests(n, 'ar');
  assert.equal(ar(1), 'طلب واحد');
  assert.equal(ar(2), 'طلبان');
  assert.equal(ar(3), '3 طلبات');
  assert.equal(ar(10), '10 طلبات');
  assert.equal(ar(11), '11 طلبا');
  assert.equal(ar(99), '99 طلبا');
  assert.equal(ar(100), '100 طلب');
  assert.equal(ar(101), '101 طلب');
  assert.equal(ar(102), '102 طلب');
  assert.equal(ar(103), '103 طلبات');
  assert.equal(ar(111), '111 طلبا');
  assert.equal(ar(200), '200 طلب');
  assert.equal(ar(0), '0 طلب');
  assert.ok(![1, 2, 3, 11, 100].some((n) => /[\u064B-\u0652]/.test(ar(n))), 'no tanween / diacritics');
  assert.deepEqual(t.pendingCountVariables(3), { en: { count: '3', countedRequests: '3 requests' }, ar: { countedRequests: '3 طلبات' } });
});

test('templates: the earlier count-only pending wording, stored as seeded, is replaced (KP-TT-011)', () => {
  const seeded = t.resolveTemplate('pending_approvals', {
    stored: { isEnabled: true, selectedNotificationTypes: ['push'], subjectEnglish: 'Action Required — Pending Approval Requests', subjectArabic: 'مطلوب إجراء — طلبات بانتظار الموافقة', bodyEnglish: t.SUPERSEDED.pending_approvals[0], bodyArabic: t.SUPERSEDED.pending_approvals[1] },
  });
  assert.equal(seeded.bodyEn, t.TEMPLATES.pending_approvals.bodyEn);
  assert.equal(seeded.bodyAr, t.TEMPLATES.pending_approvals.bodyAr);
});

test('texts: missed_check_out body = the app text with "30" replaced by {{minutes}}', () => {
  const tpl = t.TEMPLATES.missed_check_out;
  assert.equal(tpl.bodyEn.replace('{{minutes}}', '30'), t.SUPERSEDED.missed_check_out[0]);
  assert.equal(tpl.bodyAr.replace('{{minutes}}', '30'), t.SUPERSEDED.missed_check_out[1]);
});

test('templates: admin text wins; a superseded seeded default is replaced; disabled switch; channels', () => {
  const edited = t.resolveTemplate('shift_end_reminder', {
    stored: { isEnabled: true, selectedNotificationTypes: ['email'], subjectEnglish: 'Go home', subjectArabic: '', bodyEnglish: 'Bye at {{time}}', bodyArabic: 'وداعاً {{time}}' },
  });
  assert.equal(edited.titleEn, 'Go home');
  assert.equal(edited.titleAr, 'انتهت الوردية — يرجى تسجيل الانصراف'); // empty → default
  assert.equal(edited.bodyEn, 'Bye at {{time}}');
  assert.equal(edited.push, false);
  const seeded = t.resolveTemplate('break_completed', {
    stored: { isEnabled: true, selectedNotificationTypes: ['email', 'push'], subjectEnglish: 'Break Period Concluded', subjectArabic: 'انتهاء فترة الاستراحة', bodyEnglish: t.SUPERSEDED.break_completed[0], bodyArabic: t.SUPERSEDED.break_completed[1] },
  });
  assert.equal(seeded.bodyEn, t.TEMPLATES.break_completed.bodyEn);
  assert.equal(seeded.bodyAr, t.TEMPLATES.break_completed.bodyAr);
  assert.equal(seeded.push, true);
  assert.equal(t.resolveTemplate('missed_check_in', { stored: { isEnabled: false } }).enabled, false);
  assert.equal(t.resolveTemplate('missed_check_in').push, true); // no doc → email + push
});

test('templates: renamed keys honour the LEGACY switch (never its old text)', () => {
  const r = t.resolveTemplate('pending_approvals', { legacy: { isEnabled: false, bodyEnglish: 'You currently have {{count}} requests' } });
  assert.equal(r.enabled, false);
  assert.equal(r.bodyEn, t.TEMPLATES.pending_approvals.bodyEn);
  assert.equal(t.LEGACY_KEYS.break_policy_violation_manager, 'break_policy_violation_manager_hr');
});

test('dedupe: marker id = the app\'s {refId}__{eventKey}__{dueMillis}', () => {
  assert.equal(markerId('sara@co.com_2026-10-08', 'missed_check_in', 1791000000000), 'sara@co.com_2026-10-08__missed_check_in__1791000000000');
  assert.equal(approverSubject('REQ1', 'Mona@Co.com'), 'REQ1_mona@co.com');
  assert.equal(dailySubject('Mona@co.com'), 'approvals_mona@co.com');
  assert.throws(() => markerId('a/b', 'x', 1));
  assert.throws(() => markerId('', 'x', 1));
});

test('dedupe: marker body mirrors TimeTrackerNotificationLogRepository (one history row)', () => {
  const doc = markerDoc({ id: 'i', subject: 's', event: 'missed_check_in', occurrenceMs: 1000, receiverEmail: 'A@b.c', outcome: 'sent', nowMs: 2000, actor: 'system', toTimestamp: plainTimestamp });
  assert.equal(lastOf(doc, 'Notification_Log_Id'), 'i');
  assert.equal(lastOf(doc, 'Reference_Id'), 's');
  assert.equal(lastOf(doc, 'Event_Key'), 'missed_check_in');
  assert.equal(lastOf(doc, 'Due_Date').toMillis(), 1000);
  assert.equal(lastOf(doc, 'Due_Date_Millis'), 1000);
  assert.equal(lastOf(doc, 'Receiver_Email'), 'a@b.c');
  assert.equal(lastOf(doc, 'Created_By'), 'system');
  assert.equal(doc.timestamps.length, 1);
});

test('notifications: the in-app document and the push match the app shape', () => {
  const rendered = { title: 'T', body: 'B', title_ar: 'ع', body_ar: 'ب' };
  const d = notificationDoc({ rendered, senderEmail: 'System@Company.com', receiverEmail: 'Sara@Co.com', pageKey: 'TimeTrackerMainPage', nowMs: 5 });
  assert.deepEqual(d, {
    title: 'T',
    body: 'B',
    title_ar: 'ع',
    body_ar: 'ب',
    Name_of_module: 'time_tracker',
    Sender_Email: 'system@company.com',
    Reciver_Email: 'sara@co.com',
    name_of_page: 'TimeTrackerMainPage',
    Pin: false,
    timestamp: 5,
    isRead: false,
    isClean: false,
  });
  const withReq = notificationDoc({ rendered, senderEmail: 's', receiverEmail: 'r', pageKey: 'TimeTrackerApprovalDetails', nowMs: 5, requestId: 'R1', isReminder: true });
  assert.equal(withReq.Request_Id, 'R1');
  assert.equal(withReq.Is_Reminder, true);
  assert.equal(topicForEmail('First.Last+x@Co.com'), 'first_dot_last_plus_x_at_co_dot_com');
  assert.deepEqual(pushMessage({ rendered, receiverEmail: 'a@b.c', pageKey: 'P' }).data, { route: 'time_tracker', module: 'time_tracker', name_of_page: 'P' });
});
