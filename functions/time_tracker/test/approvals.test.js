'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');

const a = require('../src/rules/approvals');
const { ms, requestDoc } = require('./helpers');

const MGR = 'mona@co.com';
const HR1 = 'hala@co.com';
const HR2 = 'hadi@co.com';
const HR = new Set([HR1, HR2]);

const req = (id, opts) => a.parseRequest(id, requestDoc(opts));
const atManager = (id, requester, extra = {}) =>
  req(id, { requester, steps: [{ step: 'manager', approver: MGR }, { step: 'hr' }], ...extra });
const atHr = (id, requester, decidedBy = MGR, extra = {}) =>
  req(id, {
    requester,
    steps: [{ step: 'manager', approver: decidedBy, decision: 'approved', decidedAt: '2026-10-02T08:00:00Z' }, { step: 'hr' }],
    ...extra,
  });

test('approvals: current step = first pending step of the LATEST round; only while pending / under review', () => {
  const r = atManager('r1', 'sara@co.com');
  assert.equal(a.actionableStep(r).step.step, 'manager');
  assert.equal(a.actionableStep(atHr('r2', 'sara@co.com')).step.step, 'hr');
  const approved = req('r3', { requester: 'x@co.com', status: 'approved', steps: [{ step: 'manager', approver: MGR }] });
  assert.equal(a.actionableStep(approved), null);
  // cancellation round: the original round's leftover pending step never waits again
  const steps = [
    { step: 'manager', approver: MGR, decision: 'approved' },
    { step: 'hr', decision: 'pending' },
    { step: 'manager', approver: MGR, decision: 'approved', cancel: true },
    { step: 'hr', decision: 'pending', cancel: true },
  ];
  const review = req('r4', { requester: 'x@co.com', status: 'under_review', steps });
  assert.equal(a.roundStart(review.steps), 2);
  assert.deepEqual([a.actionableStep(review).index, a.actionableStep(review).step.isCancellation], [3, true]);
});

test('approvals: unknown status is skipped (hasKnownStatus)', () => {
  assert.equal(req('r', { requester: 'x@co.com', status: 'weird', steps: [{ step: 'hr' }] }).isKnown, false);
  assert.equal(a.actionableStep(req('r', { requester: 'x@co.com', status: 'weird', steps: [{ step: 'hr' }] })), null);
});

test('COUNT BUG FIX: the approver gets his REAL pending total, not "1"', () => {
  const all = [
    atManager('r1', 'a@co.com'),
    atManager('r2', 'b@co.com'),
    atManager('r3', 'c@co.com'),
    atHr('r4', 'd@co.com'),
    req('r5', { requester: 'e@co.com', status: 'approved', steps: [{ step: 'manager', approver: MGR, decision: 'approved' }] }),
  ];
  assert.equal(a.waitingCount(all, MGR, false), 3);
  assert.equal(a.waitingCount(all, HR1, true), 1);
  // the manager who decided the manager step never decides the HR step of that round
  assert.equal(a.waitingCount(all, MGR, true), 3);
  // a manager who is ALSO an HR approver: real total covers both queues
  const both = [...all, atHr('r6', 'f@co.com', 'other@co.com')];
  assert.equal(a.waitingCount(both, MGR, true), 4);
});

test('receivers: manager step → only the direct manager; HR step → every HR approver; never the requester', () => {
  assert.deepEqual(a.stepReceivers(atManager('r1', 'sara@co.com'), HR), [{ email: MGR, as: 'manager' }]);
  assert.deepEqual(a.stepReceivers(atHr('r2', 'sara@co.com'), HR).map((r) => r.email), [HR2, HR1].sort());
  // HR's own request at the HR step: the requester is excluded
  assert.deepEqual(a.stepReceivers(atHr('r3', HR1), HR).map((r) => r.email), [HR2]);
  // the HR approver who decided the manager step is excluded from the HR step
  assert.deepEqual(a.stepReceivers(atHr('r4', 'sara@co.com', HR2), HR).map((r) => r.email), [HR1]);
  // a manager step pointing at the requester (bad data) → nobody
  assert.deepEqual(a.stepReceivers(atManager('r5', MGR), HR), []);
});

test('trigger: entering a step → instant (Is_Reminder false)', () => {
  const created = atManager('r1', 'sara@co.com');
  assert.deepEqual(a.pendingApprovalsTrigger(null, created), { isReminder: false });
  const toHr = atHr('r1', 'sara@co.com');
  assert.deepEqual(a.pendingApprovalsTrigger(created, toHr), { isReminder: false });
  const approvedReq = req('r1', {
    requester: 'sara@co.com',
    status: 'approved',
    steps: [{ step: 'manager', approver: MGR, decision: 'approved' }, { step: 'hr', decision: 'approved', approver: HR1 }],
  });
  const cancelRound = req('r1', {
    requester: 'sara@co.com',
    status: 'under_review',
    steps: [
      { step: 'manager', approver: MGR, decision: 'approved' },
      { step: 'hr', decision: 'approved', approver: HR1 },
      { step: 'manager', approver: MGR, cancel: true },
      { step: 'hr', cancel: true },
    ],
  });
  assert.deepEqual(a.pendingApprovalsTrigger(approvedReq, cancelRound), { isReminder: false });
});

test('trigger: "Send reminder" on the same step → Is_Reminder true; other writes → nothing', () => {
  const before = atManager('r1', 'sara@co.com');
  const reminded = atManager('r1', 'sara@co.com', { lastReminder: '2026-10-05T08:00:00Z' });
  assert.deepEqual(a.pendingApprovalsTrigger(before, reminded), { isReminder: true });
  assert.equal(a.pendingApprovalsTrigger(reminded, reminded), null); // a comment, same reminder time
  const rejected = req('r1', { requester: 'sara@co.com', status: 'rejected', steps: [{ step: 'manager', approver: MGR, decision: 'rejected' }] });
  assert.equal(a.pendingApprovalsTrigger(before, rejected), null);
  assert.equal(a.pendingApprovalsTrigger(before, null), null); // deleted
});

test('daily reminder: approvers with a request waiting > 2 days; count = REAL total; oldest request linked', () => {
  const now = ms('2026-10-09T09:00:00Z');
  const all = [
    atManager('old', 'a@co.com', { createdAt: '2026-10-05T08:00:00Z' }),
    atManager('older', 'b@co.com', { createdAt: '2026-10-04T08:00:00Z' }),
    atManager('fresh', 'c@co.com', { createdAt: '2026-10-08T08:00:00Z' }),
    atHr('hrFresh', 'd@co.com', MGR, { createdAt: '2026-10-01T08:00:00Z' }), // waits at HR since the manager decided on 2 Oct
  ];
  const due = a.dailyApprovalReminders(all, new Set([HR1]), now, 2 * 24 * 60 * 60000);
  assert.deepEqual(due.get(MGR), { count: 3, overdue: 2, requestId: 'older' });
  assert.deepEqual(due.get(HR1), { count: 1, overdue: 1, requestId: 'hrFresh' });
  const later = a.dailyApprovalReminders([atManager('fresh', 'c@co.com', { createdAt: '2026-10-08T08:00:00Z' })], new Set(), now, 2 * 24 * 60 * 60000);
  assert.equal(later.size, 0);
});

test('waitingSince: decision time of the previous step, else the request date', () => {
  assert.equal(a.waitingSince(atHr('r', 'x@co.com')), ms('2026-10-02T08:00:00Z'));
  assert.equal(a.waitingSince(atManager('r', 'x@co.com', { createdAt: '2026-10-03T08:00:00Z' })), ms('2026-10-03T08:00:00Z'));
});

test('parseRequest: target-schema names (Status, Decided_At, Reminders, Requested_At)', () => {
  const r = a.parseRequest('t1', {
    Requester_Email: 'Sara@Co.com',
    Status: 'pending',
    Approval_Steps: [{ Step: 'manager', Approver_Email: MGR, Decision: 'pending', Decided_At: null, Is_Cancellation_Step: false }],
    Reminders: [{ Sent_By: 'sara@co.com', Sent_At: { seconds: 1791000000, nanoseconds: 0 } }],
    Requested_At: { seconds: 1790000000, nanoseconds: 0 },
    Updated_At: { seconds: 1791000000, nanoseconds: 0 },
  });
  assert.equal(r.requesterEmail, 'sara@co.com');
  assert.equal(a.actionableStep(r).step.approverEmail, MGR);
  assert.equal(r.lastReminderMs, 1791000000000);
  assert.equal(r.createdMs, 1790000000000);
  assert.equal(r.updatedMs, 1791000000000);
});
