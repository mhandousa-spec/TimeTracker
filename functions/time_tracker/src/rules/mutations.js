'use strict';
/**
 * The attendance write that goes with a notification (or an upkeep fix) —
 * pure: stored document in, document to write out.
 *
 * Every write appends ONE indexed-history row carrying every field
 * (history.appendRow + the audit trio, Modified_By = "system"), exactly like
 * the app's `appendRow` transaction. A history entry that is itself a list is
 * wrapped `{Values:[…]}` (Firestore forbids arrays inside arrays), so per
 * revision: `Sessions` = {Values:[session, …]} and
 * `Alerts` = {Values:[{Alert_Type, At, Minutes_Over}, …]}. Session maps are
 * rewritten key-for-key so fields the server does not know survive. A stored
 * document without `timestamps` is upgraded to the history shape (its values
 * become one-entry histories) — the server never writes plain lists.
 *
 * A day that does not exist yet (missed check-in alert) is created in the
 * app's exact row shape so the app's next check-in appends to it normally.
 */

const { appendRow, nextAudit, wrap } = require('../history');
const { F } = require('../schema');
const { listOfAny } = require('../fields');
const { parseDay, parseSession, totals } = require('./attendance');
const { dayStartMs } = require('./time');
const { finalOverrunUpdates, nextStoredAlerts } = require('./alerts');
const { breakLimitMinutes, pauseLimitMinutes } = require('./schedule');
const { applyAutoCheckOut } = require('./autoCheckOut');

/**
 * @param {object} p
 * @param {string} p.id          attendance doc id `{email}_{dayKey}`
 * @param {object|null} p.doc    stored data (null = missing)
 * @param {object} p.setup       work set-up (zone, email, rules)
 * @param {string} p.dayKey
 * @param {object} p.changes     {alertsToAdd?, alertUpdates?, autoCheckOut?, markAbsent?}
 * @param {number} p.nowMs
 * @param {string} p.actor
 * @param {function} p.toTimestamp
 * @returns {{data: object, merge: boolean, created: boolean}|null} null = nothing to write
 */
function attendanceWrite({ id, doc, setup, dayKey, changes, nowMs, actor, toTimestamp, allowCreate = false }) {
  const c = changes || {};
  if (!doc && !allowCreate) return null;
  const day = parseDay(id, doc || {});
  const values = {};

  let rawSessions = doc ? listOfAny(doc, F.sessions) : [];
  let sessions = day.sessions;
  if (c.autoCheckOut) {
    rawSessions = applyAutoCheckOut(rawSessions, c.autoCheckOut.sessionIndex, c.autoCheckOut.checkOutMs, toTimestamp);
    sessions = rawSessions
      .map((raw, i) => (raw && typeof raw === 'object' ? parseSession(raw, i) : null))
      .filter((s) => s && s.checkInMs !== null);
    values[F.sessions[0]] = wrap(rawSessions);
    const t = totals(sessions, nowMs);
    values[F.totalWorkMinutes[0]] = t.workMinutes;
    if (day.hasPausedMinutesField) {
      // Target schema: Break_Minutes = breaks taken, Paused_Minutes = pauses.
      values[F.breakMinutes[0]] = t.breakMinutes;
      values[F.pausedMinutes[0]] = t.pauseMinutes;
    } else {
      // App today: Break_Minutes = Σ pauses ("Pause = Break").
      values[F.breakMinutes[0]] = t.pauseMinutes + t.breakMinutes;
    }
  }

  const rawAlerts = doc ? listOfAny(doc, F.alerts) : [];
  const limits = { breakMinutes: breakLimitMinutes(setup), pauseMinutes: pauseLimitMinutes(setup) };
  const updates = [...(c.alertUpdates || [])];
  if (c.autoCheckOut) {
    for (const u of finalOverrunUpdates(sessions, day.alerts, limits)) {
      if (!updates.some((x) => x.index === u.index)) updates.push(u);
    }
  }
  const nextAlerts = nextStoredAlerts(rawAlerts, day.alerts, { added: c.alertsToAdd || [], updates }, toTimestamp);
  const alertsChanged = nextAlerts.length !== rawAlerts.length || updates.length > 0;
  if (alertsChanged) values[F.alerts[0]] = wrap(nextAlerts);

  if (c.markAbsent && day.status === null && day.sessions.length === 0) {
    values[F.attendanceStatus[0]] = 'absent';
  }

  if (Object.keys(values).length === 0) return null;

  if (!doc) {
    const base = {
      Attendance_Id: id,
      [F.employeeEmail[0]]: setup.email,
      [F.attendanceDate[0]]: toTimestamp(dayStartMs(dayKey, setup.timeZone)),
      [F.sessions[0]]: wrap([]),
      [F.attendanceStatus[0]]: null,
      [F.lateMinutes[0]]: 0,
      [F.breakMinutes[0]]: 0,
      [F.totalWorkMinutes[0]]: 0,
      [F.isCorrected[0]]: false,
      [F.sourceRequestId[0]]: '',
      [F.alerts[0]]: wrap([]),
    };
    const data = appendRow(null, { ...base, ...values, ...nextAudit(null, actor, nowMs, { toTimestamp }) }, nowMs, { toTimestamp });
    return { data, merge: false, created: true };
  }

  const data = appendRow(doc, { ...values, ...nextAudit(doc, actor, nowMs, { toTimestamp }) }, nowMs, { toTimestamp });
  return { data, merge: false, created: false };
}

module.exports = { attendanceWrite };
