'use strict';
/**
 * "Send once" markers in `Modules/time_tracker/Notification_Log` — the same
 * scheme as the app (`TimeTrackerFirestorePaths.notificationLogDocId` +
 * `TimeTrackerNotificationLogRepository`): the marker is CREATED in the same
 * transaction that writes the notification; only the run that created it
 * sends, so overlapping runs, retries and the old client sweep stay silent.
 *
 * Marker id = `{subject}__{event}__{occurrenceMs}` — exactly the app's
 * `{refId}__{eventKey}__{dueMillis}` (subject = attendance day id,
 * `{requestId}_{approver}`, or `approvals_{email}`; occurrence = the due
 * time the event belongs to). Same id as the client sweep for
 * missed_check_in / missed_check_out, so the two can never double-send
 * while the client sweep is being retired.
 *
 * The marker body is an indexed-history document like every Time Tracker
 * document (one row): Notification_Log_Id, Reference_Id, Event_Key,
 * Due_Date, Due_Date_Millis, Receiver_Email + audit trio + timestamps, plus
 * `Outcome` (sent · disabled · no_receiver · no_permission · on_leave ·
 * not_due) for support.
 */

const { appendRow, nextAudit } = require('../history');
const { norm } = require('../fields');

const OCCURRENCE = /^-?\d+$/;

/** `{subject}__{event}__{occurrenceMs}`. */
function markerId(subject, event, occurrenceMs) {
  const s = String(subject || '').trim();
  const e = String(event || '').trim();
  if (s === '' || e === '') throw new Error('A marker needs a subject and an event.');
  if (s.includes('/') || e.includes('/')) throw new Error(`Invalid marker part: "${s}" / "${e}".`);
  if (!Number.isFinite(occurrenceMs) || !OCCURRENCE.test(String(Math.trunc(occurrenceMs)))) {
    throw new Error(`Invalid occurrence: ${occurrenceMs}`);
  }
  return `${s}__${e}__${Math.trunc(occurrenceMs)}`;
}

/** Subject of a per-approver pending_approvals marker. */
function approverSubject(requestId, approverEmail) {
  return `${String(requestId).trim()}_${norm(approverEmail)}`;
}

/** Subject of the daily reminder (same as the client's `approvals_{email}`). */
function dailySubject(approverEmail) {
  return `approvals_${norm(approverEmail)}`;
}

/** The marker document (one history row). */
function markerDoc({ id, subject, event, occurrenceMs, receiverEmail, outcome, nowMs, actor, toTimestamp }) {
  return appendRow(
    null,
    {
      Notification_Log_Id: id,
      Reference_Id: subject,
      Event_Key: event,
      Due_Date: toTimestamp(occurrenceMs),
      Due_Date_Millis: Math.trunc(occurrenceMs),
      Receiver_Email: norm(receiverEmail),
      Outcome: outcome,
      ...nextAudit(null, actor, nowMs, { toTimestamp }),
    },
    nowMs,
    { toTimestamp },
  );
}

module.exports = { markerId, approverSubject, dailySubject, markerDoc };
