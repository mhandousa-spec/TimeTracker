'use strict';
/**
 * `Attendance.Alerts[] {Alert_Type, At, Minutes_Over}` (decision 2a) — one
 * record per alert per employee per day, written by the server with the
 * alert notifications. HR / the manager count them by type over a period.
 *
 *   break_exceeded   At = break start + allowed + grace;  Minutes_Over = overrun beyond the
 *                    allowed length (final value once the break ends)
 *   pause_exceeded   At = pause start + allowed;          Minutes_Over = idem
 *   auto_check_out   At = when the system closed it;      Minutes_Over = 0
 *   late_arrival     At = first check-in;                 Minutes_Over = late minutes
 *   missed_check_in  At = start + Late After;             Minutes_Over = 0
 *   missed_check_out At = shift end + 30 min;             Minutes_Over = 0
 *
 * An overrun alert is matched to its break / pause by its `At` falling
 * inside that interval (intervals never overlap), so no extra key is needed.
 */

const { F } = require('../schema');
const { minutesBetween } = require('./time');

const ALERT_TYPES = Object.freeze({
  breakExceeded: 'break_exceeded',
  pauseExceeded: 'pause_exceeded',
  autoCheckOut: 'auto_check_out',
  lateArrival: 'late_arrival',
  missedCheckIn: 'missed_check_in',
  missedCheckOut: 'missed_check_out',
});

const ALL_ALERT_TYPES = Object.freeze(Object.values(ALERT_TYPES));

function makeAlert(type, atMs, minutesOver = 0) {
  if (!ALL_ALERT_TYPES.includes(type)) throw new Error(`Unknown alert type "${type}".`);
  return { type, atMs, minutesOver: Math.max(0, Math.trunc(minutesOver || 0)) };
}

/** True when [alerts] already hold this record (same type and same `At`). */
function hasAlert(alerts, type, atMs) {
  return alerts.some((a) => a.type === type && a.atMs === atMs);
}

/** True when an alert of [type] has its `At` inside [startMs, endMs] (end null = open). */
function hasAlertWithin(alerts, type, startMs, endMs) {
  return alerts.some(
    (a) => a.type === type && a.atMs !== null && a.atMs >= startMs && (endMs === null || a.atMs <= endMs),
  );
}

/** Overrun beyond the allowed length of an interval ending at [endMs]. */
function overrunMinutes(startMs, endMs, allowedMinutes) {
  return Math.max(0, minutesBetween(startMs, endMs) - allowedMinutes);
}

/**
 * Overrun alerts whose break / pause has ENDED, with their final
 * `Minutes_Over` (only those whose stored value differs).
 *
 * @param {object[]} sessions  parsed sessions (attendance.parseDay)
 * @param {object[]} alerts    parsed alerts
 * @param {{breakMinutes:number, pauseMinutes:number}} limits
 * @returns {{index:number, minutesOver:number}[]} indexes into the STORED list
 */
function finalOverrunUpdates(sessions, alerts, limits) {
  const updates = [];
  alerts.forEach((alert, position) => {
    const index = alert.rawIndex !== undefined ? alert.rawIndex : position;
    if (alert.atMs === null) return;
    const isBreak = alert.type === ALERT_TYPES.breakExceeded;
    const isPause = alert.type === ALERT_TYPES.pauseExceeded;
    if (!isBreak && !isPause) return;
    const allowed = isBreak ? limits.breakMinutes : limits.pauseMinutes;
    if (!(allowed > 0)) return;
    for (const s of sessions) {
      for (const iv of isBreak ? s.breaks : s.pauses) {
        if (iv.endMs === null) continue;
        if (alert.atMs < iv.startMs || alert.atMs > iv.endMs) continue;
        const final = overrunMinutes(iv.startMs, iv.endMs, allowed);
        if (final !== alert.minutesOver) updates.push({ index, minutesOver: final });
        return;
      }
    }
  });
  return updates;
}

/** Plain alert → the stored map. */
function toStored(alert, toTimestamp) {
  return {
    [F.alertType]: alert.type,
    [F.alertAt]: alert.atMs === null ? null : toTimestamp(alert.atMs),
    [F.alertMinutesOver]: alert.minutesOver,
  };
}

/**
 * The new stored Alerts list: [rawAlerts] (kept untouched — unknown keys
 * survive), plus [added] (skipped when the same type + At is already there),
 * with [updates] applied to `Minutes_Over`.
 */
function nextStoredAlerts(rawAlerts, parsedAlerts, { added = [], updates = [] }, toTimestamp) {
  const out = rawAlerts.map((raw) => (raw && typeof raw === 'object' ? { ...raw } : raw));
  for (const u of updates) {
    const raw = out[u.index];
    if (raw && typeof raw === 'object') raw[F.alertMinutesOver] = u.minutesOver;
  }
  const known = parsedAlerts.slice();
  for (const alert of added) {
    if (hasAlert(known, alert.type, alert.atMs)) continue;
    out.push(toStored(alert, toTimestamp));
    known.push(alert);
  }
  return out;
}

module.exports = {
  ALERT_TYPES,
  ALL_ALERT_TYPES,
  makeAlert,
  hasAlert,
  hasAlertWithin,
  overrunMinutes,
  finalOverrunUpdates,
  toStored,
  nextStoredAlerts,
};
