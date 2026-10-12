'use strict';
/**
 * `pending_approvals` (decision 7): ONE event, always a pending requirement;
 * `Is_Reminder` = true for "Send reminder" and the daily overdue reminder.
 * `{{count}}` = the approver's REAL pending total, counted on the server at
 * send time (the count bug: the requester's device cannot read company
 * requests, so approvers always got "1").
 *
 * Port of `ApprovalRouter` (roundStart / currentStepOf / decidedInRound),
 * `RequestCycleRules.actionableStep`, `ApprovalInbox.waitsFor / waitingCount`
 * and `TimeTrackerHomeStatsRules.waitingSince`.
 *
 * Receivers (decision 5): the approver(s) of the CURRENT step — the direct
 * manager stored on a manager step, or every HR approver
 * (`Approve_And_Reject` + `Approvals_All_Departments`) on an HR step
 * (a request reaching HR, or a cancellation round at its HR step). Never
 * the requester; never whoever decided the manager step of the same round.
 */

const { lastOf, lastWriteMs } = require('../history');
const { F } = require('../schema');
const { str, bool, norm, toMillis, lastOfAny, listOfAny, isPlainObject } = require('../fields');

const STATUSES = Object.freeze(['pending', 'approved', 'rejected', 'under_review', 'canceled', 'canceled_by_hr']);
const STEP_KINDS = Object.freeze(['manager', 'hr']);
const DECISIONS = Object.freeze(['pending', 'approved', 'rejected', 'skipped']);

function parseStep(raw) {
  if (!isPlainObject(raw)) return null;
  const kind = str(raw[F.step]);
  if (!STEP_KINDS.includes(kind)) return null; // unknown step kinds are dropped
  const decision = str(raw[F.decision]);
  let decidedAtMs = null;
  for (const key of F.decidedAt) if (raw[key] !== undefined && decidedAtMs === null) decidedAtMs = toMillis(raw[key]);
  return {
    step: kind,
    approverEmail: norm(raw[F.approverEmail]),
    decision: DECISIONS.includes(decision) ? decision : 'pending', // unknown → pending
    decidedAtMs,
    isCancellation: bool(raw[F.isCancellationStep]),
  };
}

function lastReminderMsOf(doc) {
  const direct = toMillis(lastOfAny(doc, F.lastReminder));
  if (direct !== null) return direct;
  const reminders = listOfAny(doc, F.reminders).filter(isPlainObject);
  if (reminders.length === 0) return null;
  return toMillis(reminders[reminders.length - 1].Sent_At);
}

/** `Requests/{id}` → plain object (null for a missing document). */
function parseRequest(id, doc) {
  if (!doc) return null;
  const status = str(lastOfAny(doc, F.requestStatus));
  const writeMs = lastWriteMs(doc);
  return {
    id,
    requesterEmail: norm(lastOfAny(doc, F.requesterEmail)),
    isTransaction: bool(lastOfAny(doc, F.isTransaction)),
    status,
    // `TimeTrackerRequestModel.hasKnownStatus`: an odd document is skipped.
    isKnown: STATUSES.includes(status),
    steps: listOfAny(doc, F.approvalSteps).map(parseStep).filter((s) => s !== null),
    startMs: toMillis(lastOfAny(doc, F.start)),
    endMs: toMillis(lastOfAny(doc, F.end)),
    isAllDay: bool(lastOfAny(doc, F.isAllDay)),
    lastReminderMs: lastReminderMsOf(doc),
    createdMs: toMillis(lastOfAny(doc, F.requestedAt)),
    updatedMs: writeMs !== null ? writeMs : toMillis(lastOfAny(doc, F.updatedAt)),
    writeMs,
    modifiedBy: norm(lastOfAny(doc, F.modifiedBy)),
  };
}

const isPending = (s) => s.decision === 'pending';
const isSkipped = (s) => s.decision === 'skipped';

/** Where the LATEST round starts (every cancellation round copies the original steps). */
function roundStart(steps) {
  const size = steps.filter((s) => !s.isCancellation).length;
  if (size <= 0 || steps.length <= size) return 0;
  return size * Math.trunc((steps.length - size) / size);
}

/** Where the round holding [index] starts. */
function roundStartOf(steps, index) {
  const size = steps.filter((s) => !s.isCancellation).length;
  if (size <= 0 || index < size) return 0;
  return size * Math.trunc(index / size);
}

/** {index, step} of the first pending step of the latest round, or null. */
function currentStepOf(steps) {
  for (let i = roundStart(steps); i < steps.length; i++) {
    if (isPending(steps[i])) return { index: i, step: steps[i] };
  }
  return null;
}

/** The step waiting for a decision — only while pending or under review. */
function actionableStep(request) {
  if (!request || !request.isKnown) return null;
  if (request.status !== 'pending' && request.status !== 'under_review') return null;
  return currentStepOf(request.steps);
}

/** [email] already decided a step of the round holding [index]. */
function decidedInRound(steps, index, email) {
  const who = norm(email);
  if (who === '' || index < 0) return false;
  for (let i = roundStartOf(steps, index); i < index; i++) {
    const s = steps[i];
    if (!isPending(s) && !isSkipped(s) && s.approverEmail === who) return true;
  }
  return false;
}

const isRequester = (request, email) => norm(email) !== '' && request.requesterEmail === norm(email);

/** `ApprovalInbox.waitsFor`: the current step waits for [email]. */
function waitsFor(request, email, isHrApprover) {
  const current = actionableStep(request);
  if (!current || isRequester(request, email)) return false;
  if (current.step.step === 'manager') return current.step.approverEmail === norm(email);
  return !!isHrApprover && !decidedInRound(request.steps, current.index, email);
}

/** The approver's REAL pending total over [requests]. */
function waitingCount(requests, email, isHrApprover) {
  return requests.filter((r) => waitsFor(r, email, isHrApprover)).length;
}

/** When the current step started waiting (`TimeTrackerHomeStatsRules.waitingSince`). */
function waitingSince(request) {
  const current = actionableStep(request);
  if (!current) return null;
  let latest = null;
  for (let i = roundStartOf(request.steps, current.index); i < current.index; i++) {
    const s = request.steps[i];
    if (s.isCancellation !== current.step.isCancellation || s.decidedAtMs === null) continue;
    if (latest === null || s.decidedAtMs > latest) latest = s.decidedAtMs;
  }
  if (latest !== null) return latest;
  return current.step.isCancellation
    ? request.updatedMs !== null ? request.updatedMs : request.createdMs
    : request.createdMs !== null ? request.createdMs : request.updatedMs;
}

/** Stable identity of the waiting step: a different identity = the request entered a step. */
function stepIdentity(request) {
  const c = actionableStep(request);
  return c ? `${c.index}|${c.step.step}|${c.step.isCancellation ? 'c' : 'o'}` : null;
}

/**
 * Should this write send `pending_approvals`?
 *   * the request ENTERED a step (created, moved manager → HR, cancellation
 *     round opened) → { isReminder: false };
 *   * the same step, and the requester's "Send reminder" moved
 *     `Last_Reminder_Date_Time` forward → { isReminder: true };
 *   * anything else (comments, decisions that close the cycle …) → null.
 */
function pendingApprovalsTrigger(before, after) {
  if (!after || !actionableStep(after)) return null;
  const idAfter = stepIdentity(after);
  const idBefore = before ? stepIdentity(before) : null;
  if (idAfter !== idBefore) return { isReminder: false };
  const was = before ? before.lastReminderMs : null;
  if (after.status === 'pending' && after.lastReminderMs !== null && (was === null || after.lastReminderMs > was)) {
    return { isReminder: true };
  }
  return null;
}

/**
 * Who must act on the current step (decision 5): the manager on a manager
 * step; every HR approver on an HR step. Never the requester.
 *
 * @param {Set<string>} hrApprovers  lower-cased emails (Approve_And_Reject + All Departments)
 * @returns {{email:string, as:'manager'|'hr'}[]}
 */
function stepReceivers(request, hrApprovers) {
  const current = actionableStep(request);
  if (!current) return [];
  if (current.step.step === 'manager') {
    const manager = current.step.approverEmail;
    return manager !== '' && !isRequester(request, manager) ? [{ email: manager, as: 'manager' }] : [];
  }
  return [...hrApprovers]
    .map(norm)
    .filter((email) => email !== '' && waitsFor(request, email, true))
    .sort()
    .map((email) => ({ email, as: 'hr' }));
}

/** Any request of [requests] currently waits at an HR step (HR approvers needed). */
function anyWaitingAtHr(requests) {
  return requests.some((r) => {
    const c = actionableStep(r);
    return c !== null && c.step.step === 'hr';
  });
}

/** [requests] with [request] replacing its stored copy (the request as just written). */
function withLatest(requests, request) {
  return [...requests.filter((r) => r.id !== request.id), request];
}

/**
 * The once-a-day reminder: every approver with at least one request waiting
 * MORE than [overdueMs] → { count: real pending total, requestId: oldest overdue }.
 *
 * @returns {Map<string, {count:number, overdue:number, requestId:string}>}
 */
function dailyApprovalReminders(requests, hrApprovers, nowMs, overdueMs) {
  const candidates = new Set([...hrApprovers].map(norm).filter(Boolean));
  for (const r of requests) {
    const c = actionableStep(r);
    if (c && c.step.step === 'manager' && c.step.approverEmail) candidates.add(c.step.approverEmail);
  }
  const out = new Map();
  for (const email of [...candidates].sort()) {
    const isHr = hrApprovers.has(email);
    const waiting = requests.filter((r) => waitsFor(r, email, isHr));
    const overdue = waiting
      .map((r) => ({ r, since: waitingSince(r) }))
      .filter((x) => x.since !== null && nowMs - x.since > overdueMs)
      .sort((a, b) => a.since - b.since || (a.r.id < b.r.id ? -1 : a.r.id > b.r.id ? 1 : 0));
    if (overdue.length === 0) continue;
    out.set(email, { count: waiting.length, overdue: overdue.length, requestId: overdue[0].r.id });
  }
  return out;
}

/** The actor of the latest write (the notification's sender), '' when unknown. */
function actorOf(doc) {
  return norm(lastOf(doc || {}, 'Modified_By')) || norm(lastOf(doc || {}, 'Updated_By'));
}

module.exports = {
  STATUSES,
  parseStep,
  parseRequest,
  roundStart,
  roundStartOf,
  currentStepOf,
  actionableStep,
  decidedInRound,
  waitsFor,
  waitingCount,
  waitingSince,
  stepIdentity,
  pendingApprovalsTrigger,
  stepReceivers,
  anyWaitingAtHr,
  withLatest,
  dailyApprovalReminders,
  actorOf,
};
